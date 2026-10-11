#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <libgen.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define VERSION "1.7.0"
#define MAX_DEPTH 20
#define BUFFER_SIZE 4096

/* Global tracking variable for signal cleanup handler */
static char *global_tmp_path = NULL;

static void usage(const char *prog) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "  Local update:  %s [options] [--] <file>\n", prog);
    fprintf(stderr, "  Version check: %s -V\n\n", prog);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -a, --append   Append stdin to target atomically\n");
    fprintf(stderr, "  -h, --help     Show this usage screen\n");
}

/* Signal handler ensuring no orphan temporary files are left behind */
static void cleanup_handler(int sig) {
    if (global_tmp_path) {
        unlink(global_tmp_path);
    }
    if (sig != 0) {
        _exit(1);
    }
}

int main(int argc, char *argv[]) {
    char *target = NULL;
    char *prog_name = NULL;
    int append_mode = 0;
    int arg_idx = 1;

    prog_name = basename(argv[0]);

    /* Parse incoming options manually to match shell behavior */
    while (arg_idx < argc) {
        if (strcmp(argv[arg_idx], "--") == 0) {
            arg_idx++;
            break;
        } else if (strcmp(argv[arg_idx], "-a") == 0 ||
                   strcmp(argv[arg_idx], "--append") == 0) {
            append_mode = 1;
            arg_idx++;
        } else if (strcmp(argv[arg_idx], "-V") == 0 ||
                   strcmp(argv[arg_idx], "--version") == 0) {
            printf("safecat C edition version %s\n", VERSION);
            return 0;
        } else if (strcmp(argv[arg_idx], "-h") == 0 ||
                   strcmp(argv[arg_idx], "--help") == 0) {
            usage(prog_name);
            return 0;
        } else if (argv[arg_idx][0] == '-') {
            fprintf(stderr, "Error: Unknown option '%s'\n", argv[arg_idx]);
            fprintf(stderr, "Use '%s --help' for usage info.\n", prog_name);
            return 1;
        } else {
            break;
        }
    }

    if (arg_idx < argc) {
        target = argv[arg_idx];
    }

    if (!target) {
        fprintf(stderr, "Error: Missing target file parameter.\n");
        usage(prog_name);
        return 1;
    }

    /* Set up robust symlink resolution loop */
    char resolved[PATH_MAX];
    char current_target[PATH_MAX];
    int depth = 0;

    snprintf(current_target, sizeof(current_target), "%s", target);

    struct stat st;
    while (lstat(current_target, &st) == 0 && S_ISLNK(st.st_mode)) {
        if (depth >= MAX_DEPTH) {
            fprintf(stderr, "Error: Symlink loop exceeded limits.\n");
            return 1;
        }

        ssize_t len = readlink(current_target, resolved, sizeof(resolved)-1);
        if (len == -1) {
            perror("Error: Failed reading symlink");
            return 1;
        }
        resolved[len] = '\0';

        if (resolved[0] == '/') {
            snprintf(current_target, sizeof(current_target), "%s",
                     resolved);
        } else {
            char t_copy[PATH_MAX];
            snprintf(t_copy, sizeof(t_copy), "%s", current_target);
            char *d_name = dirname(t_copy);
            snprintf(current_target, sizeof(current_target), "%s/%s",
                     d_name, resolved);
        }
        depth++;
    }

    /* Extract directory safely to check writability context */
    char target_copy[PATH_MAX];
    char target_copy2[PATH_MAX];
    snprintf(target_copy, sizeof(target_copy), "%s", current_target);
    snprintf(target_copy2, sizeof(target_copy2), "%s", current_target);

    char *dir_part = dirname(target_copy);
    char *base_part = basename(target_copy2);

    if (access(dir_part, W_OK) != 0) {
        fprintf(stderr, "Error: Directory '%s' is not writable.\n",
                dir_part);
        return 1;
    }

    /* Dynamically evaluate file permissions & root ownership rules */
    mode_t perms = 0644;
    uid_t owner = (uid_t)-1;
    gid_t group = (gid_t)-1;
    int file_exists = (stat(current_target, &st) == 0);
    int is_root = (getuid() == 0);

    if (file_exists) {
        if (access(current_target, W_OK) != 0) {
            fprintf(stderr, "Error: Target '%s' is not writable.\n",
                    current_target);
            return 1;
        }
        perms = st.st_mode & 07777;
        if (is_root) {
            owner = st.st_uid;
            group = st.st_gid;
        }
    }

    /* Initialize staging file inside target directory */
    char tmp_template[PATH_MAX];
    snprintf(tmp_template, sizeof(tmp_template), "%s/tmp-safecat.XXXXXX",
             dir_part);

    int tmp_fd = mkstemp(tmp_template);
    if (tmp_fd == -1) {
        perror("Error: Failed to create temporary file");
        return 1;
    }

    global_tmp_path = tmp_template;
    atexit(cleanup_handler);
    signal(SIGINT, cleanup_handler);
    signal(SIGTERM, cleanup_handler);
    signal(SIGHUP, cleanup_handler);

    /* Atomic Append Logic: copy existing file contents into temp state */
    if (append_mode && file_exists) {
        int orig_fd = open(current_target, O_RDONLY);
        if (orig_fd != -1) {
            char buffer[BUFFER_SIZE];
            ssize_t n_read;
            while ((n_read = read(orig_fd, buffer, sizeof(buffer))) > 0) {
                if (write(tmp_fd, buffer, n_read) != n_read) {
                    perror("Error: Writing seed data to temporary file");
                    close(orig_fd);
                    close(tmp_fd);
                    return 1;
                }
            }
            close(orig_fd);
        }
    }

    /* Pipeline user's stdin stream right into the staging structure */
    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;
    while ((bytes_read = read(STDIN_FILENO, buffer, sizeof(buffer))) > 0) {
        if (write(tmp_fd, buffer, bytes_read) != bytes_read) {
            perror("Error: Writing input stream data to temporary file");
            close(tmp_fd);
            return 1;
        }
    }

    /* Sync file changes entirely down to storage medium layout */
    if (fchmod(tmp_fd, perms) != 0) {
        perror("Warning: Fchmod mapping failed");
    }

    if (is_root && owner != (uid_t)-1 && group != (gid_t)-1) {
        if (fchown(tmp_fd, owner, group) != 0) {
            perror("Warning: Ownership restoration failed");
        }
    }

    if (fsync(tmp_fd) != 0) {
        perror("Error: Fsync flushing operations dropped unexpectedly");
        close(tmp_fd);
        return 1;
    }
    close(tmp_fd);

    /* Atomically swap structural changes over the runtime target setup */
    if (rename(tmp_template, current_target) != 0) {
        perror("Error: Atomic rename block failed explicitly");
        return 1;
    }

    global_tmp_path = NULL;
    return 0;
}
