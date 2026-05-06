; ds - mat1 
; es - mat2
_mat_diff proc near
    push bp
    mov  bp, sp
    sub  sp, 16          ; allocate local variables
    push si
    push di

    ; Local variables:
    ;   short r, c, sum, len;
    ;   char num_buf[7];       ; buffer for string representation of short (max 6 chars + null)
    ;   char space = ' ';
    mov  byte ptr [bp-13], ' '

    ;   char newline[] = "\r\n";
    mov byte ptr [bp-16], 13   ; newline[0]
    mov byte ptr [bp-15], 10   ; newline[1]
    mov byte ptr [bp-14], 0    ; newline[2]

    ; Check that matrix dimensions match
    ; if (mat_cols1 != mat_cols2 || mat_rows1 != mat_rows2) {
    mov  ax, word ptr ds:[MAT_DATA_OFFSET+2]
    cmp  ax, word ptr es:[MAT_DATA_OFFSET+2]
    jne  mat_diff_dim_mismatch
    mov  ax, word ptr ds:[MAT_DATA_OFFSET]
    cmp  ax, word ptr es:[MAT_DATA_OFFSET]
    je   mat_diff_continue

mat_diff_dim_mismatch:
    stc                         ; set carry flag to indicate error
    jmp  mat_diff_return

mat_diff_continue:
    ; Loop over rows and columns in natural order
    ; for (r = 0; r < mat_rows1; r++) {
    xor  di, di                 ; di = r (row index)
    jmp  mat_diff_row_loop_continue

mat_diff_row_loop_start:
    ; for (c = 0; c < mat_cols1; c++) {
    xor  si, si                 ; si = c (column index)
    jmp  mat_diff_col_loop_continue

mat_diff_col_loop_start:
    ; sum = mat_data1[c][r] + mat_data2[c][r];
    ; Access: mat_data1[col][row]  (row-major? Actually column-major: [col][row])
    mov  ax, si                 ; column index
    mov  dx, 200
    imul dx                     ; dx:ax = column * 200
    mov  dx, di                 ; row index
    shl  dx, 1                  ; row * 2 (size of short)
    add  ax, dx                 ; offset in mat_data1
    mov  bx, ax
    mov  ax, word ptr ds:[bx]   ; mat1
    push ax                     ; save first element

    mov  ax, si
    mov  dx, 200              
    imul dx
    mov  dx, di
    shl  dx, 1
    add  ax, dx
    mov  bx, ax
    pop  ax
    sub  ax, word ptr es:[bx]   ; mat2
    mov  word ptr [bp-2], ax    ; store sum

    ; stoa(sum, num_buf);
    push ds
    mov ax, ss
    mov ds, ax

    lea  ax, word ptr [bp-12]   ; num_buf
    push ax
    push word ptr [bp-2]        ; sum
    call near ptr _stoa
    pop  cx
    pop  cx

    pop ds

    ; len = strlen(num_buf);
    push ds
    mov ax, ss
    mov ds, ax

    lea  ax, word ptr [bp-12]
    push ax
    call near ptr _strlen
    pop  cx
    mov  word ptr [bp-4], ax    ; store len

    pop ds


    push ds
    mov ax, ss
    mov ds, ax

    ; fwrite(fd, num_buf, len);
    push word ptr [bp-4]        ; len
    lea  ax, word ptr [bp-12]   ; num_buf
    push ax
    push word ptr [bp+4]        ; fd (file descriptor)
    call near ptr _fwrite
    add  sp, 6

    pop ds

    ; if (c < mat_cols1 - 1) fwrite(fd, &space, 1);
    mov  ax, word ptr ds:[MAT_DATA_OFFSET+2]
    dec  ax                     ; mat_cols1 - 1
    cmp  ax, si                 ; compare with current c
    jle  mat_diff_skip_space
    
    push ds
    mov ax, ss
    mov ds, ax
    
    push 1
    lea  ax, word ptr [bp-13]   ; &space
    push ax
    push word ptr [bp+4]        ; fd
    call near ptr _fwrite
    add  sp, 6

    pop ds

mat_diff_skip_space:
    inc  si                     ; c++

mat_diff_col_loop_continue:
    cmp  si, word ptr ds:[MAT_DATA_OFFSET+2]
    jl   mat_diff_col_loop_start

    ; End of row: write newline
    ; fwrite(fd, newline, 2);
    push ds
    mov ax, ss
    mov ds, ax
    push 2
    lea  ax, word ptr [bp-16]   ; newline
    push ax
    push word ptr [bp+4]        ; fd
    call near ptr _fwrite
    add  sp, 6
    pop ds

    inc  di                     ; r++

mat_diff_row_loop_continue:
    cmp  di, ds:[MAT_DATA_OFFSET]
    jl   mat_diff_row_loop_start

    ; Success: clear carry flag
    clc

mat_diff_return:
    pop  di
    pop  si
    mov  sp, bp
    pop  bp
    ret
_mat_diff endp