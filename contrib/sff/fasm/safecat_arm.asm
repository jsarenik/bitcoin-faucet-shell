; This is my safecat, inspired by Len's maildir (DJB-inpired)
; ARMFASM needed to compile this

format ELF64 executable 3
processor cpu64_v8
entry _start

segment readable executable

_start:
    ldr     x19, [sp]           ; argc
    add     x20, sp, 8          ; argv
    cmp     x19, 2
    b.lt    .usage

    ldr     x0, [x20, 8]        ; argv[1]
    ldrh    w1, [x0]            ; load first 2 bytes
    mov     w2, 0x612d          ; "-a" in little endian
    cmp     w1, w2
    b.ne    .set_target
    mov     x21, 1              ; append flag = 1
    ldr     x0, [x20, 16]       ; argv[2]
    cbz     x0, .usage
    b       .set_target

.set_target:
    mov     x22, x0             ; target path pointer

    adr     x1, path_buf
    mov     x2, x22
.copy_path:
    ldrb    w3, [x2], 1
    strb    w3, [x1], 1
    cbnz    w3, .copy_path

    ; --- Step 1: Manual Symlink Resolution Loop ---
.sym_loop:
    cmp     x23, 20
    b.ge    .err_loop

    mov     x8, 79              ; sys_newfstatat
    mov     x0, -100            ; AT_FDCWD
    adr     x1, path_buf
    adr     x2, stat_buf
    mov     x3, 0x100           ; AT_SYMLINK_NOFOLLOW
    svc     0
    cbnz    x0, .check_done

    adr     x5, stat_buf
    ldr     w1, [x5, 16]        ; st_mode offset (16 on ARM64)
    mov     w6, 0xf000          ; Mask for file type bits
    and     w1, w1, w6
    mov     w7, 0xa000          ; S_ISLNK pattern
    cmp     w1, w7
    b.ne    .check_done

    mov     x8, 78              ; sys_readlinkat
    mov     x0, -100
    adr     x1, path_buf
    adr     x2, link_buf
    mov     x3, 4096
    svc     0
    cmn     x0, #1
    b.mi    .err_tmp
    adr     x1, link_buf
    strb    wzr, [x1, x0]

    ldrb    w2, [x1]
    cmp     w2, '/'
    b.eq    .abs_link

    adr     x1, path_buf
    mov     x2, xzr
    mov     x3, xzr
.find_slash:
    ldrb    w4, [x1, x2]
    cbz     w4, .slash_found
    cmp     w4, '/'
    csel    x3, x2, x3, eq
    add     x2, x2, 1
    b       .find_slash

.slash_found:
    cbz     x3, .abs_link
    add     x3, x3, 1
    mov     x2, x3
    b       .stitch_path

.abs_link:
    mov     x2, xzr

.stitch_path:
    adr     x1, path_buf
    add     x1, x1, x2
    adr     x4, link_buf
.copy_link:
    ldrb    w5, [x4], 1
    strb    w5, [x1], 1
    cbnz    w5, .copy_link

    add     x23, x23, 1
    b       .sym_loop

.check_done:
    ; --- Step 2: Grab Permissions ---
    mov     x8, 79              ; sys_newfstatat
    mov     x0, -100
    adr     x1, path_buf
    adr     x2, stat_buf
    mov     x3, 0
    svc     0
    cmn     x0, #1
    b.mi    .create_default

    adr     x5, stat_buf
    ldr     w1, [x5, 16]        ; st_mode offset (16 on ARM64)
    mov     w6, 0x0fff          ; Lower 12 bits mask
    and     w1, w1, w6
    mov     x24, 1              ; exists = 1
    b       .prepare_temp

.create_default:
    mov     x24, 0              ; exists = 0

.prepare_temp:
    ; --- Step 3: Initialize DJB-Style Temp File ---
    adr     x1, path_buf
    adr     x2, tmp_buf
.copy_to_tmp:
    ldrb    w3, [x1], 1
    strb    w3, [x2], 1
    cbnz    w3, .copy_to_tmp

    adr     x1, tmp_buf
    mov     x2, xzr
    mov     x3, xzr
.find_last_slash:
    ldrb    w4, [x1, x2]
    cbz     w4, .last_slash_found
    cmp     w4, '/'
    csel    x3, x2, x3, eq
    add     x2, x2, 1
    b       .find_last_slash

.last_slash_found:
    cbz     x3, .use_current_dir
    add     x3, x3, 1
    strb    wzr, [x1, x3]
    adr     x2, tmp_buf
    add     x2, x2, x3
    b       .append_prefix

.use_current_dir:
    adr     x2, tmp_buf

.append_prefix:
    adr     x1, tmp_prefix
.copy_prefix:
    ldrb    w3, [x1], 1
    strb    w3, [x2], 1
    cbnz    w3, .copy_prefix
    sub     x2, x2, 1

    mov     x8, 172             ; sys_getpid
    svc     0
    mov     x10, x0
    bl      .num_to_str

    mov     w3, '.'
    strb    w3, [x2], 1

    mov     x8, 169             ; sys_gettimeofday
    adr     x0, stat_buf
    mov     x1, xzr
    svc     0
    adr     x3, stat_buf
    ldr     x10, [x3]
    bl      .num_to_str

    adr     x1, tmp_suffix
.copy_suffix:
    ldrb    w3, [x1], 1
    strb    w3, [x2], 1
    cbnz    w3, .copy_suffix

    mov     x8, 56              ; sys_openat
    mov     x0, -100
    adr     x1, tmp_buf
    mov     x2, 0102o           ; O_CREAT | O_WRONLY
    mov     x3, 0644o           ; Correct octal permissions
    svc     0
    cmn     x0, #1
    b.mi    .err_tmp
    mov     x26, x0             ; tmp_fd

    ; --- Step 4: Atomic Append Processing ---
    cbz     x21, .read_stdin
    cbz     x24, .read_stdin

    mov     x8, 56              ; sys_openat
    mov     x0, -100
    adr     x1, path_buf
    mov     x2, 0               ; O_RDONLY
    mov     x3, 0
    svc     0
    cmn     x0, #1
    b.mi    .read_stdin
    mov     x27, x0             ; target_fd

.copy_old_loop:
    mov     x8, 63              ; sys_read
    mov     x0, x27
    adr     x1, io_buffer
    mov     x2, 4096
    svc     0
    cmn     x0, #1
    b.mi    .err_cleanup
    cbz     x0, .close_old

    mov     x2, x0
    mov     x8, 64              ; sys_write
    mov     x0, x26
    adr     x1, io_buffer
    svc     0
    b       .copy_old_loop

.close_old:
    mov     x8, 57              ; sys_close
    mov     x0, x27
    svc     0

    ; --- Step 5: Read standard input stream loop ---
.read_stdin:
    mov     x8, 63              ; sys_read
    mov     x0, 0               ; STDIN
    adr     x1, io_buffer
    mov     x2, 4096
    svc     0
    cmn     x0, #1
    b.mi    .err_cleanup
    cbz     x0, .finish_stream

    mov     x2, x0
    mov     x8, 64              ; sys_write
    mov     x0, x26
    adr     x1, io_buffer
    svc     0
    b       .read_stdin

.finish_stream:
    mov     x8, 52              ; sys_fchmod
    mov     x0, x26
    mov     x1, 0644o           ; Correct octal permissions
    svc     0

    mov     x8, 57              ; sys_close
    mov     x0, x26
    svc     0

    ; --- Step 6: Perform Atomic Exchange Swap ---
    mov     x8, 38              ; sys_renameat
    mov     x0, -100
    adr     x1, tmp_buf
    mov     x2, -100
    adr     x3, path_buf
    svc     0
    cmn     x0, #1
    b.mi    .err_unlink

    mov     x8, 93              ; sys_exit
    mov     x0, 0
    svc     0

.num_to_str:
    mov     x11, 10
    mov     x12, x2
.div_loop:
    udiv    x13, x10, x11
    msub    x14, x13, x11, x10
    add     w14, w14, '0'
    strb    w14, [x2], 1
    mov     x10, x13
    cbnz    x10, .div_loop
    sub     x15, x2, 1
.rev_loop:
    cmp     x12, x15
    b.ge    .rev_done
    ldrb    w16, [x12]
    ldrb    w17, [x15]
    strb    w17, [x12]
    strb    w16, [x15]
    add     x12, x12, 1
    sub     x15, x15, 1
    b       .rev_loop
.rev_done:
    ret

.usage:
    mov     x8, 64
    mov     x0, 2
    adr     x1, msg_usage
    mov     x2, msg_usage_len
    svc     0
    mov     x8, 93
    mov     x0, 1
    svc     0

.err_loop:
    adr     x1, msg_err_loop
    mov     x2, msg_err_loop_len
    b       .fail

.err_cleanup:
    mov     x8, 57
    mov     x0, x26
    svc     0
.err_unlink:
.err_tmp:
    adr     x1, msg_err_swap
    mov     x2, msg_err_swap_len

.fail:
    mov     x8, 64
    mov     x0, 2
    svc     0
    mov     x8, 93
    mov     x0, 1
    svc     0

segment readable writeable

tmp_prefix     db '.safecat.', 0
tmp_suffix     db '.tmp', 0

msg_usage      db 'safecat v1.6.4 (ARM64)', 10
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
