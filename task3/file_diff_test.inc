_compare_files proc near 
    push bp
    mov  bp, sp
    sub  sp, 24

    pushregs ds, es, si, di, bx, cx, dx

    mov ax, ds
    mov es, ax

    push offset msg_prompt1
    call putstr
    add sp, 2

    push offset test_buffer
    push 256
    call getstr
    add sp, 4

    push offset test_buffer
    push offset filename1
    call strcpy
    add sp, 4

    push offset msg_prompt2
    call putstr
    add sp, 2

    push offset test_buffer
    push 256
    call getstr
    add sp, 4

    push offset test_buffer
    push offset filename2
    call strcpy
    add sp, 4

    call putnewline

    push offset filename1
    push ACCESS_READ
    call fopen
    jc  cf_error_open1
    add sp, 4
    mov word ptr [bp-2], ax

    push word ptr [bp-2]
    call fsize
    jc  cf_error_size1
    add sp, 2
    mov word ptr [bp-10], ax

    push word ptr [bp-2]
    push word ptr [bp-10]
    call freadtos
    jc  cf_error_read1
    add sp, 4
    mov word ptr [bp-6], ax

    pusha
    push offset msg_loaded_file1
    call putstr
    add sp, 2

    call putnewline
    popa

    push ds
    mov ds, ax
    push 00000
    call putstr
    add sp, 2 
    pop ds

    call putnewline

    push ds
    push es
    mov  ds, word ptr [bp-6]
    push ax
    mov ax, ds 
    mov  es, ax
    pop ax
    xor  si, si
    xor  cx, cx
    mov  word ptr [bp-18], cx

cf_count_lines_1:
    mov  di, si
    call cf_strchr_lf
    test ax, ax
    jz   cf_count_last_1
    mov  dx, ax
    cmp  dx, si
    jbe  cf_count_no_cr1
    push bx
    mov bx, dx
    cmp  byte ptr [bx-1], 13
    pop bx
    jne  cf_count_no_cr1
    inc  cx
    mov  si, dx
    inc  si
    jmp  cf_count_next1
cf_count_no_cr1:
    inc  cx
    mov  si, dx
    inc  si
    jmp  cf_count_next1
cf_count_last_1:
    inc  cx
    jmp  cf_count_done1
cf_count_next1:
    cmp  byte ptr [si], 0
    jne  cf_count_lines_1
cf_count_done1:
    mov  word ptr [bp-18], cx
    pop  es
    pop  ds

    mov  ax, word ptr [bp-18]
    shl  ax, 2
    test ax, ax
    jz   cf_alloc_lines1_zero
    push ax
    call AllocMem
    add  sp, 2
    test ax, ax
    jz   cf_error_alloc_lines1
    mov  word ptr [bp-14], ax
    jmp  cf_alloc_lines1_done
cf_alloc_lines1_zero:
    mov  word ptr [bp-14], 0
cf_alloc_lines1_done:

    cmp  word ptr [bp-18], 0
    je   cf_parse_done1

    mov  es, word ptr [bp-14]
    xor  di, di
    push ds
    push es
    mov  ds, word ptr [bp-6]
    push ax
    mov ax, ds
    mov  es, ax
    pop ax

    xor  si, si

cf_parse_file1_loop:
    mov  bx, si
    mov  di, si
    call cf_strchr_lf
    mov  dx, ax
    test dx, dx
    jz   cf_last_line1

    cmp  dx, si
    jbe  cf_no_cr1
    push bx
    mov  bx, dx
    mov  cl, byte ptr [bx-1]
    pop  bx
    cmp  cl, 13
    jne  cf_no_cr1
    dec  dx
    mov  word ptr [bp-22], dx
    mov  ax, word ptr [bp-22]
    inc  ax
    mov  word ptr [bp-24], ax
    jmp  cf_line_end_handled1
cf_no_cr1:
    mov  word ptr [bp-22], dx
    mov  cx, dx
    inc  cx
    mov  word ptr [bp-24], cx
    jmp  cf_line_end_handled1
cf_last_line1:
    mov  dx, si
    add  dx, word ptr [bp-10]
    mov  word ptr [bp-22], dx
    mov  cx, dx
    mov  word ptr [bp-24], cx

cf_line_end_handled1:
    push bx
    mov  bx, dx
    mov  byte ptr [bx], 0
    pop  bx

    mov  di, si
    call cf_strchr_pipe
    mov  cx, ax

    push es
    mov  es, word ptr [bp-14]
    mov  ax, si
    stosw
    test cx, cx
    jz   cf_no_pipe1
    cmp  cx, word ptr [bp-22]
    jae  cf_no_pipe1
    push bx
    mov  bx, cx
    mov  byte ptr [bx], 0
    pop  bx
    mov  ax, cx
    inc  ax
    stosw
    jmp  cf_pipe_done1
cf_no_pipe1:
    xor  ax, ax
    stosw
cf_pipe_done1:
    pop  es

    mov  si, word ptr [bp-24]
    cmp  byte ptr [si], 0
    jz   cf_parse_done1
    cmp  di, word ptr [bp-18]
    jb   cf_parse_file1_loop
cf_parse_done1:
    pop  es
    pop  ds

    push offset filename2
    push ACCESS_READ
    call fopen
    jc  cf_error_open2
    add sp, 4
    mov word ptr [bp-4], ax

    push word ptr [bp-4]
    call fsize
    jc  cf_error_size2
    add sp, 2
    mov word ptr [bp-12], ax

    push word ptr [bp-4]
    push word ptr [bp-12]
    call freadtos
    jc  cf_error_read2
    add sp, 4
    mov word ptr [bp-8], ax

    pusha
    push offset msg_loaded_file2
    call putstr
    add sp,2

    call putnewline
    popa

    push ds
    mov ds, ax
    push 00000
    call putstr
    add sp, 2 
    pop ds

    call putnewline

    mov  es, word ptr [bp-8]
    mov  di, word ptr [bp-12]
    mov  byte ptr es:[di], 0

    push ds
    push es
    mov  ds, word ptr [bp-8]
    push ax
    mov ax, ds
    mov  es, ax
    pop ax
    xor  si, si
    xor  cx, cx
    mov  word ptr [bp-20], cx

cf_count_lines_2:
    mov  di, si
    call cf_strchr_lf
    test ax, ax
    jz   cf_count_last_2
    mov  dx, ax
    cmp  dx, si
    jbe  cf_count_no_cr2
    push bx
    mov bx, dx
    cmp  byte ptr [bx-1], 13
    pop bx
    jne  cf_count_no_cr2
    inc  cx
    mov  si, dx
    inc  si
    jmp  cf_count_next2
cf_count_no_cr2:
    inc  cx
    mov  si, dx
    inc  si
    jmp  cf_count_next2
cf_count_last_2:
    inc  cx
    jmp  cf_count_done2
cf_count_next2:
    cmp  byte ptr [si], 0
    jne  cf_count_lines_2
cf_count_done2:
    mov  word ptr [bp-20], cx
    pop  es
    pop  ds

    mov  ax, word ptr [bp-20]
    shl  ax, 2
    test ax, ax
    jz   cf_alloc_lines2_zero
    push ax
    call AllocMem
    add  sp, 2
    test ax, ax
    jz   cf_error_alloc_lines2
    mov  word ptr [bp-16], ax
    jmp  cf_alloc_lines2_done
cf_alloc_lines2_zero:
    mov  word ptr [bp-16], 0
cf_alloc_lines2_done:

    cmp  word ptr [bp-20], 0
    je   cf_parse_done2

    mov  es, word ptr [bp-16]
    xor  di, di
    push ds
    push es
    mov  ds, word ptr [bp-8]
    push ax
    mov ax, ds
    mov  es, ax
    pop ax
    xor  si, si

cf_parse_file2_loop:
    mov  bx, si
    mov  di, si
    call cf_strchr_lf
    mov  dx, ax
    test dx, dx
    jz   cf_last_line2

    cmp  dx, si
    jbe  cf_no_cr2b
    push bx
    mov  bx, dx
    mov  cl, byte ptr [bx-1]
    pop  bx
    cmp  cl, 13
    jne  cf_no_cr2b
    dec  dx
    mov  word ptr [bp-22], dx
    mov  ax, word ptr [bp-22]
    inc  ax
    mov  word ptr [bp-24], ax
    jmp  cf_line_end_handled2
cf_no_cr2b:
    mov  word ptr [bp-22], dx
    mov  cx, dx
    inc  cx
    mov  word ptr [bp-24], cx
    jmp  cf_line_end_handled2
cf_last_line2:
    mov  dx, si
    add  dx, word ptr [bp-12]
    mov  word ptr [bp-22], dx
    mov  cx, dx
    mov  word ptr [bp-24], cx
cf_line_end_handled2:
    push bx
    mov  bx, dx
    mov  byte ptr [bx], 0
    pop  bx

    mov  di, si
    call cf_strchr_pipe
    mov  cx, ax

    push es
    mov  es, word ptr [bp-16]
    mov  ax, si
    stosw
    test cx, cx
    jz   cf_no_pipe2
    cmp  cx, word ptr [bp-22]
    jae  cf_no_pipe2
    push bx
    mov  bx, cx
    mov  byte ptr [bx], 0
    pop  bx
    mov  ax, cx
    inc  ax
    stosw
    jmp  cf_pipe_done2
cf_no_pipe2:
    xor  ax, ax
    stosw
cf_pipe_done2:
    pop  es

    mov  si, word ptr [bp-24]
    cmp  byte ptr [si], 0
    jz   cf_parse_done2
    cmp  di, word ptr [bp-20]
    jb   cf_parse_file2_loop
cf_parse_done2:
    pop  es
    pop  ds

    mov  cx, word ptr [bp-18]
    cmp  cx, word ptr [bp-20]
    jbe  cf_use_min
    mov  cx, word ptr [bp-20]
cf_use_min:
    mov  word ptr [bp-22], cx

    push offset msg_loaded_str
    call putstr
    add sp, 2
    call putnewline

    mov  cx, word ptr [bp-22]
    test cx, cx
    jz   cf_no_lines

    mov  si, word ptr [bp-14]
    mov  di, word ptr [bp-16]
    mov  bx, 0

cf_compare_loop:
    inc  bx

    push ds
    push es
    mov  ax, word ptr [si]
    mov  dx, word ptr [bp-6]
    push dx
    pop  ds
    mov  dx, ax

    mov  ax, word ptr [di]

    mov  dx, word ptr [bp-8]
    push dx
    pop  es
    mov  ax, ax

    push ax
    push dx
    call strcmp
    add sp, 4

    push ds
    push es
    push ax
    push bx
    call cf_print_line_result
    add sp, 6
    pop  es
    pop  ds

    mov  ax, word ptr [si+2]
    test ax, ax
    jz   cf_right1_empty
    push word ptr [bp-6]
    pop  ds
    mov  dx, ax
    jmp  cf_right1_ok
cf_right1_empty:
    mov  dx, offset empty_str
cf_right1_ok:
    mov  ax, word ptr [di+2]
    test ax, ax
    jz   cf_right2_empty
    push word ptr [bp-8]
    pop  es
    mov  ax, ax
    jmp  cf_right2_ok
cf_right2_empty:
    mov  ax, offset empty_str
cf_right2_ok:
    push ax
    push dx
    call strcmp
    add sp, 4

    push ds
    push es
    push ax
    push bx
    call cf_print_line_result
    add sp, 6
    pop  es
    pop  ds

    add si, 4
    add di, 4
    dec  word ptr [bp-22]
    jnz  cf_compare_loop

cf_no_lines:
    call putnewline

    cmp  word ptr [bp-14], 0
    je   cf_skip_free1
    push word ptr [bp-14]
    call FreeMem
    add sp, 2
cf_skip_free1:
    cmp  word ptr [bp-16], 0
    je   cf_skip_free2
    push word ptr [bp-16]
    call FreeMem
    add sp, 2
cf_skip_free2:

    push word ptr [bp-6]
    call FreeMem
    add sp, 2
    push word ptr [bp-8]
    call FreeMem
    add sp, 2

    push word ptr [bp-2]
    call fclose
    add sp, 2
    push word ptr [bp-4]
    call fclose
    add sp, 2

    jmp cf_done

cf_error_open1:
    push offset msg_err_open1
    call putstr
    add sp, 2
    jmp cf_done
cf_error_size1:
    push offset msg_err_size1
    call putstr
    add sp, 2
    jmp cf_done
cf_error_read1:
    push offset msg_err_read1
    call putstr
    add sp, 2
    jmp cf_done
cf_error_alloc_lines1:
    push offset msg_err_split1
    call putstr
    add sp, 2
    jmp cf_done

cf_error_open2:
    push offset msg_err_open2
    call putstr
    add sp, 2
    jmp cf_done
cf_error_size2:
    push offset msg_err_size2
    call putstr
    add sp, 2
    jmp cf_done
cf_error_read2:
    push offset msg_err_read2
    call putstr
    add sp, 2
    jmp cf_done
cf_error_alloc_lines2:
    push offset msg_err_split2
    call putstr
    add sp, 2
    jmp cf_done

cf_done:
    popregs dx, cx, bx, di, si, es, ds
    mov sp, bp
    pop bp
    ret

cf_strchr_lf:
    push bp
    mov  bp, sp
    push bx
    mov  di, word ptr [bp+4]
    mov  al, 10
    call strchr
    pop  bx
    mov  sp, bp
    pop  bp
    ret

cf_strchr_pipe:
    push bp
    mov  bp, sp
    push bx
    mov  di, word ptr [bp+4]
    mov  al, '|'
    call strchr
    pop  bx
    mov  sp, bp
    pop  bp
    ret

_compare_files endp

cf_print_line_result proc near
    push bp
    mov bp, sp
    pushregs ax, bx, cx, dx

    mov bx, word ptr [bp+4]
    mov ax, word ptr [bp+6]

    push bx
    call cf_print_number
    add sp, 2

    push offset msg_colon_space
    call putstr
    add sp, 2

    cmp ax, 0
    je  cf_prequal
    jg  cf_prgreater
    mov dx, offset msg_less
    jmp cf_prprint
cf_prequal:
    mov dx, offset msg_equal
    jmp cf_prprint
cf_prgreater:
    mov dx, offset msg_greater
cf_prprint:
    push dx
    call putstr
    add sp, 2

    call putnewline

    popregs dx, cx, bx, ax
    mov sp, bp
    pop bp
    ret
cf_print_line_result endp

cf_print_number proc near
    push bp
    mov bp, sp
    pushregs ax, bx, cx, dx

    mov ax, word ptr [bp+4]
    mov bx, 10
    xor cx, cx
cf_num_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz cf_num_loop
cf_num_print:
    pop dx
    add dl, '0'
    push dx
    call putchar
    add sp, 2
    loop cf_num_print

    popregs dx, cx, bx, ax
    mov sp, bp
    pop bp
    ret
cf_print_number endp