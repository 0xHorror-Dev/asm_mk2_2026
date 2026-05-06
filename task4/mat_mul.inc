_mat_mul proc near
    push bp
    mov bp, sp
    sub sp, 18
    push si
    push di
    ;	
    ;	    short r, c, k, len;       
    ;	    int sum;           
    ;	    char num_buf[7];  
    ;	    char space = ' ';
    ;	
    mov byte ptr [bp-15], ' '
    ;	
    ;	    char newline[] = "\r\n";
    ;	
    mov byte ptr [bp-18], 13   ; newline[0]
    mov byte ptr [bp-17], 10   ; newline[1]
    mov byte ptr [bp-16], 0    ; newline[2]

    ;	
    ;	
    ;	    if (mat_cols1 != mat_rows2) {
    ;	
    mov ax, word ptr ds:[MAT_DATA_OFFSET+2]
    cmp ax, word ptr es:[MAT_DATA_OFFSET]
    je short mat_mul_dimensions_ok
    ;	
    ;	        asm { stc }        
    ;	
    stc
    ;	
    ;	        return;
    ;	
    jmp mat_mul_exit

mat_mul_dimensions_ok:
    ;	    }
    ;	
    ;	    for (r = 0; r < mat_rows1; r++) {
    ;	
    mov word ptr [bp-2], 0
    jmp mat_mul_check_rows

mat_mul_row_loop:
    ;	
    ;	        for (c = 0; c < mat_cols2; c++) {
    ;	
    xor si, si
    jmp mat_mul_check_cols

mat_mul_col_loop:
    ;	            sum = 0;
    ;	
    mov word ptr [bp-6], 0
    ;	
    ;	            for (k = 0; k < mat_cols1; k++) {
    ;	
    xor di, di
    jmp short mat_mul_check_k

mat_mul_k_loop:
    ;	                sum += mat_data1[k][r] * mat_data2[c][k];
    ;	
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, word ptr [bp-2]
    shl dx, 1
    add ax, dx
    mov bx, ax
    mov ax, word ptr ds:[bx]
    push ax
    mov ax, si
    mov dx, 200
    imul dx
    mov dx, di
    shl dx, 1
    add ax, dx
    mov bx, ax
    pop ax
    imul word ptr es:[bx]
    add word ptr [bp-6], ax
    inc di

mat_mul_check_k:
    cmp di, word ptr es:[MAT_DATA_OFFSET+2]
    jl short mat_mul_k_loop
    ;	            }
    ;	
    ;	            stoa((short)sum, num_buf);
    ;	
    
    push ds
    mov ax, ss
    mov ds, ax

    lea ax, word ptr [bp-14]
    push ax
    push word ptr [bp-6]
    call near ptr _stoa
    pop cx
    pop cx
    
    pop ds
    ;	
    ;	            len = strlen(num_buf);
    ;	
    push ds
    mov ax, ss
    mov ds, ax

    lea ax, word ptr [bp-14]
    push ax
    call near ptr _strlen
    pop cx
    mov word ptr [bp-4], ax

    pop ds
    ;	
    ;	            fwrite(fd, num_buf, len);
    ;	
    push ds
    mov ax, ss
    mov ds, ax

    push word ptr [bp-4]
    lea ax, word ptr [bp-14]
    push ax
    push word ptr [bp+4]
    call near ptr _fwrite
    add sp, 6
    
    pop ds
    ;	
    ;	
    ;	            if (c < mat_cols2 - 1) {
    ;	
    mov ax, word ptr es:[MAT_DATA_OFFSET+2]
    dec ax
    cmp ax, si
    jle short mat_mul_next_col
    ;	
    ;	                fwrite(fd, &space, 1);
    ;	

    push ds
    mov ax, ss
    mov ds, ax

    mov ax, 1
    push ax
    lea ax, word ptr [bp-15]
    push ax
    push word ptr [bp+4]
    call near ptr _fwrite
    add sp, 6

    pop ds
mat_mul_next_col:
    inc si

mat_mul_check_cols:
    cmp si, word ptr es:[MAT_DATA_OFFSET + 2]
    jge mat_mul_end_col_loop
    jmp mat_mul_col_loop

mat_mul_end_col_loop:
    ;	            }
    ;	        }
    ;	
    ;	        fwrite(fd, newline, 2);
    ;	
    push ds
    mov ax, ss
    mov ds, ax

    mov ax, 2
    push ax
    lea ax, word ptr [bp-18]
    push ax
    push word ptr [bp+4]
    call near ptr _fwrite
    add sp, 6
    inc word ptr [bp-2]

    pop ds

mat_mul_check_rows:
    mov ax, word ptr [bp-2]
    cmp ax, word ptr ds:[MAT_DATA_OFFSET]
    jge mat_mul_end_row_loop
    jmp mat_mul_row_loop

mat_mul_end_row_loop:
    ;	    }
    ;	
    ;	    asm { clc }          
    ;	
    clc
    ;	
    ;	    return;
    ;	
    jmp short mat_mul_exit

mat_mul_exit:
    ;	
    ;	}
    ;	
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_mat_mul endp