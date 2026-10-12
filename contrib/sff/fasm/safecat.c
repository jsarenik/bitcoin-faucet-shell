#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>

#define VERSION "1.0.0"

/* Track the active temp path globally for signal/exit cleanups */
static char *global_tmp_path = NULL;

/* Clean exit handler registered via atexit */
static void atexit_handler(void) {
    if (global_tmp_path) {
        unlink(global_tmp_path);
    }
}

/* Signal intercept handler for unexpected interruptions */
static void signal_handler(int sig) {
    (void)sig;
    if (global_tmp_path) {
        unlink(global_tmp_path);
    }
    _exit(1);
}

static void print_usage(const char *prog_name) {
    printf("Usage:\n");
    printf("  %s [options] [--] <target_file>\n\n", prog_name);
    printf("Options:\n");
    printf("  -a, --append   Append stdin to target atomically\n");
    printf("  -h, --help     Show this usage screen\n");
    printf("  -v, --version  Print version information\n");
}

/* Helper to safely copy contents from source path to dest fd */
static int copy_file_contents(const char *src_path, int dest_fd) {
    int src_fd = open(src_path, O_RDONLY);
    if (src_fd < 0) return 0;

    char buffer[4096];
    ssize_t bytes_read;
    while ((bytes_read = read(src_fd, buffer, sizeof(buffer))) > 0) {
        ssize_t bytes_written = 0;
        while (bytes_written < bytes_read) {
            ssize_t written = write(dest_fd, buffer + bytes_written,
                                    (size_t)(bytes_read - bytes_written));
            if (written <= 0) {
                close(src_fd);
                return 0;
            }
            bytes_written += written;
        }
    }
    close(src_fd);
    return (bytes_read == 0);
}

int main(int argc, char **argv) {
    int append_mode = 0;
    char *target = NULL;
    int arg_idx = 1;

    while (arg_idx < argc) {
        if (strcmp(argv[arg_idx], "--") == 0) {
            arg_idx++;
            if (arg_idx < argc) target = argv[arg_idx];
            break;
        } else if (strcmp(argv[arg_idx], "-a") == 0 ||
                   strcmp(argv[arg_idx], "--append") == 0) {
            append_mode = 1;
        } else if (strcmp(argv[arg_idx], "-h") == 0 ||
                   strcmp(argv[arg_idx], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (strcmp(argv[arg_idx], "-v") == 0 ||
                   strcmp(argv[arg_idx], "--version") == 0) {
            printf("safecat version %s\n", VERSION);
            return 0;
        } else if (argv[arg_idx][0] == '-') {
            fprintf(stderr, "Error: Unknown option '%s'\n", argv[arg_idx]);
            print_usage(argv[0]);
            return 1;
        } else {
            target = argv[arg_idx];
            break;
        }
        arg_idx++;
    }

    if (!target) {
        fprintf(stderr, "Error: Missing target file parameter.\n");
        print_usage(argv[0]);
        return 1;
    }

    /* Extract directory path to ensure temp file lives on same dev */
    char *target_dir = strdup(target);
    char *last_slash = strrchr(target_dir, '/');
    if (last_slash) {
        *last_slash = '\0';
    } else {
        free(target_dir);
        target_dir = strdup(".");
    }

    /* Track default permissions or match existing file permissions */
    mode_t perms = 0644;
    uid_t owner = (uid_t)-1;
    gid_t group = (gid_t)-1;
    int target_exists = (access(target, F_OK) == 0);

    if (target_exists) {
        struct stat st;
        if (stat(target, &st) == 0) {
            perms = st.st_mode & 07777;
            if (getuid() == 0) {
                owner = st.st_uid;
                group = st.st_gid;
            }
        }
    }

    /* Dynamically construct standard mktemp naming template */
    size_t tmp_len = strlen(target_dir) + 20;
    char *tmp_template = malloc(tmp_len);
    snprintf(tmp_template, tmp_len, "%s/tmp-safecat.XXXXXX", target_dir);
    free(target_dir);

    int tmp_fd = mkstemp(tmp_template);
    if (tmp_fd < 0) {
        fprintf(stderr, "Error: Failed to create temporary file.\n");
        free(tmp_template);
        return 1;
    }

    /* Bind tracking fields before opening stream up to interruptions */
    global_tmp_path = tmp_template;
    atexit(atexit_handler);
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    signal(SIGHUP, signal_handler);

    /* Phase 1: Atomic Append Setup */
    if (append_mode && target_exists) {
        if (!copy_file_contents(target, tmp_fd)) {
            fprintf(stderr, "Error: Failed parsing base content.\n");
            close(tmp_fd);
            return 1;
        }
    }

    /* Phase 2: Stream Standard Input */
    char in_buf[4096];
    ssize_t r_bytes;
    while ((r_bytes = read(STDIN_FILENO, in_buf, sizeof(in_buf))) > 0) {
        ssize_t w_bytes = 0;
        while (w_bytes < r_bytes) {
            ssize_t written = write(tmp_fd, in_buf + w_bytes,
                                    (size_t)(r_bytes - w_bytes));
            if (written <= 0) {
                fprintf(stderr, "Error: Failed writing input to temp.\n");
                close(tmp_fd);
                return 1;
            }
            w_bytes += written;
        }
    }

    /* Synchronize metadata to match destination expectations */
    fchmod(tmp_fd, perms);
    if (getuid() == 0 && owner != (uid_t)-1 && group != (gid_t)-1) {
        (void)fchown(tmp_fd, owner, group);
    }
    close(tmp_fd);

    /* Perform the final atomic link replacement update */
    if (rename(tmp_template, target) != 0) {
        fprintf(stderr, "Error: Atomic swap replacement failed.\n");
        return 1;
    }

    global_tmp_path = NULL;
    free(tmp_template);
    return 0;
}
