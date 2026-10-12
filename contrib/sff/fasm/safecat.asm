format ELF64 executable 3
entry _start

segment readable executable

_start:
    pop     rdi                 ; argc
    cmp     rdi, 2
    jl      .usage

    pop     rax                 ; Skip argv[0]
    pop     rax                 ; Get argv[1]

    cmp     byte [rax], '-'
    jne     .set_target

    cmp     word [rax], 0x612d  ; Check for "-a"
    je      .handle_append

    jmp     .usage              ; Invalid option

.handle_append:
    mov     qword [append], 1
    pop     rax
    test    rax, rax
    jz      .usage

.set_target:
    mov     [target], rax

    ; Copy base target path into parsing buffer
    mov     rsi, [target]
    mov     rdi, path_buf
.copy_path:
    lodsb
    stosb
    test    al, al
    jnz     .copy_path

    ; --- Step 1: Manual Symlink Resolution Loop ---
.sym_loop:
    mov     rax, [sym_depth]
    cmp     rax, 20
    jge     .err_loop

    mov     rax, 6              ; sys_lstat
    mov     rdi, path_buf
    mov     rsi, stat_buf
    syscall
    test    rax, rax
    js      .check_done         ; Target doesn't exist yet

    ; Validate if S_ISLNK (st_mode bit mask 0120000o)
    mov     eax, dword [stat_buf + 24]
    and     eax, 0170000o
    cmp     eax, 0120000o
    jne     .check_done

    ; Resolve link using sys_readlink
    mov     rax, 89             ; sys_readlink
    mov     rdi, path_buf
    mov     rsi, link_buf
    mov     rdx, 4096
    syscall
    test    rax, rax
    js      .err_tmp
    mov     byte [link_buf + rax], 0

    ; Check if path is absolute vs relative
    cmp     byte [link_buf], '/'
    je      .abs_link

    ; Relative link resolution: locate last slash
    mov     rdi, path_buf
    xor     rcx, rcx
    xor     rdx, rdx
.find_slash:
    mov     al, [rdi + rcx]
    test    al, al
    jz      .slash_found
    cmp     al, '/'
    cmove   rdx, rcx
    inc     rcx
    jmp     .find_slash

.slash_found:
    test    rdx, rdx
    jz      .abs_link
    inc     rdx
    mov     rcx, rdx
    jmp     .stitch_path

.abs_link:
    xor     rcx, rcx

.stitch_path:
    mov     rdi, path_buf
    add     rdi, rcx
    mov     rsi, link_buf
.copy_link:
    lodsb
    stosb
    test    al, al
    jnz     .copy_link

    inc     qword [sym_depth]
    jmp     .sym_loop

.check_done:
    ; --- Step 2: Grab Permissions If File Exists ---
    mov     rax, 4              ; sys_stat
    mov     rdi, path_buf
    mov     rsi, stat_buf
    syscall
    test    rax, rax
    js      .create_default

    mov     eax, dword [stat_buf + 24]
    and     eax, 07777o
    mov     [file_mode], rax
    mov     qword [exists], 1
    jmp     .prepare_temp

.create_default:
    mov     qword [file_mode], 0644o

.prepare_temp:
    ; --- Step 3: Initialize DJB-Style Unique Temp File ---
    mov     rsi, path_buf
    mov     rdi, tmp_buf
.copy_to_tmp:
    lodsb
    stosb
    test    al, al
    jnz     .copy_to_tmp

    mov     rdi, tmp_buf
    xor     rcx, rcx
    xor     rdx, rdx
.find_last_slash:
    mov     al, [rdi + rcx]
    test    al, al
    jz      .last_slash_found
    cmp     al, '/'
    cmove   rdx, rcx
    inc     rcx
    jmp     .find_last_slash

.last_slash_found:
    test    rdx, rdx
    jz      .use_current_dir
    inc     rdx
    mov     byte [tmp_buf + rdx], 0
    mov     rdi, tmp_buf
    add     rdi, rdx
    jmp     .append_prefix

.use_current_dir:
    mov     rdi, tmp_buf

.append_prefix:
    mov     rsi, tmp_prefix
.copy_prefix:
    lodsb
    stosb
    test    al, al
    jnz     .copy_prefix
    dec     rdi                 ; Back up over null terminator

    ; Append PID component
    mov     rax, 39             ; sys_getpid
    syscall
    call    .num_to_str

    mov     byte [rdi], '.'
    inc     rdi

    ; Append Timestamp seconds component
    mov     rax, 96             ; sys_gettimeofday
    mov     rsi, stat_buf
    xor     rdx, rdx
    syscall
    mov     rax, qword [stat_buf]
    call    .num_to_str

    ; Append suffix extension
    mov     rsi, tmp_suffix
.copy_suffix:
    lodsb
    stosb
    test    al, al
    jnz     .copy_suffix

    ; Open unique temporary staging file
    mov     rax, 2              ; sys_open
    mov     rdi, tmp_buf
    mov     rsi, 0102o          ; O_CREAT | O_WRONLY
    mov     rdx, [file_mode]
    syscall
    test    rax, rax
    js      .err_tmp
    mov     [tmp_fd], rax

    ; --- Step 4: Atomic Append Processing Engine ---
    mov     rax, [append]
    test    rax, rax
    jz      .read_stdin
    mov     rax, [exists]
    test    rax, rax
    jz      .read_stdin

    mov     rax, 2              ; sys_open
    mov     rdi, path_buf
    xor     rsi, rsi            ; O_RDONLY
    syscall
    test    rax, rax
    js      .read_stdin
    mov     [target_fd], rax

.copy_old_loop:
    mov     rax, 0              ; sys_read
    mov     rdi, [target_fd]
    mov     rsi, io_buffer
    mov     rdx, 4096
    syscall
    test    rax, rax
    jz      .close_old
    js      .err_cleanup

    mov     rdx, rax
    mov     rax, 1              ; sys_write
    mov     rdi, [tmp_fd]
    mov     rsi, io_buffer
    syscall
    jmp     .copy_old_loop

.close_old:
    mov     rax, 3              ; sys_close
    mov     rdi, [target_fd]
    syscall

    ; --- Step 5: Read standard input stream loop ---
.read_stdin:
    xor     rax, rax            ; sys_read
    xor     rdi, rdi            ; STDIN_FILENO
    mov     rsi, io_buffer
    mov     rdx, 4096
    syscall
    test    rax, rax
    jz      .finish_stream
    js      .err_cleanup

    mov     rdx, rax
    mov     rax, 1              ; sys_write
    mov     rdi, [tmp_fd]
    mov     rsi, io_buffer
    syscall
    jmp     .read_stdin

.finish_stream:
    mov     rax, 91             ; sys_fchmod
    mov     rdi, [tmp_fd]
    mov     rsi, [file_mode]
    syscall

    mov     rax, 3              ; sys_close
    mov     rdi, [tmp_fd]
    syscall

    ; --- Step 6: Perform Atomic Exchange Swap ---
    mov     rax, 82             ; sys_rename
    mov     rdi, tmp_buf
    mov     rsi, path_buf
    syscall
    test    rax, rax
    js      .err_unlink

    xor     rdi, rdi            ; Exit Code 0
    mov     rax, 60             ; sys_exit
    syscall

.num_to_str:
    push    rbx
    push    rcx
    push    rdx
    xor     rcx, rcx
    mov     rbx, 10
.div_loop:
    xor     rdx, rdx
    div     rbx
    push    rdx
    inc     rcx
    test    rax, rax
    jnz     .div_loop
.pop_loop:
    pop     rax
    add     al, '0'
    stosb
    dec     rcx
    jnz     .pop_loop
    pop     rdx
    pop     rcx
    pop     rbx
    ret

.usage:
    mov     rax, 1              ; sys_write
    mov     rdi, 2              ; stderr
    mov     rsi, msg_usage
    mov     rdx, msg_usage_len
    syscall
    mov     rdi, 1
    mov     rax, 60
    syscall

.err_loop:
    mov     rsi, msg_err_loop
    mov     rdx, msg_err_loop_len
    jmp     .fail

.err_cleanup:
    mov     rax, 3              ; sys_close
    mov     rdi, [tmp_fd]
    syscall
.err_unlink:
    mov     rax, 87             ; sys_unlink
    mov     rdi, tmp_buf
    syscall
.err_tmp:
    mov     rsi, msg_err_swap
    mov     rdx, msg_err_swap_len

.fail:
    mov     rax, 1              ; sys_write
    mov     rdi, 2              ; stderr
    syscall
    mov     rdi, 1
    mov     rax, 60
    syscall

segment readable writeable

target         dq 0
target_fd      dq 0
tmp_fd         dq 0
file_mode      dq 0
append         dq 0
exists         dq 0
sym_depth      dq 0

tmp_prefix     db '.safecat.', 0
tmp_suffix     db '.tmp', 0

msg_usage      db 'safecat v1.6.4', 10
               db 'Usage: safecat [-a] <target_file>', 10
msg_usage_len  = $ - msg_usage

msg_err_loop   db 'Error: Symlink depth loop protection triggered.', 10
msg_err_loop_len = $ - msg_err_loop

msg_err_swap   db 'Error: Transaction processing fault.', 10
msg_err_swap_len = $ - msg_err_swap

segment readable writeable
stat_buf       rb 144
path_buf       rb 4096
link_buf       rb 4096
tmp_buf        rb 4096
io_buffer      rb 4096
