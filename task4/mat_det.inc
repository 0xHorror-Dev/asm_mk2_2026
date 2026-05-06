_mat_det proc near
    push bp
    mov bp, sp
    sub sp, 20064
    push si
    push di
    ;
    ; {
    ;     char buf1[20];
    ;     short n = mat_rows1;          /* matrix size (rows == cols) */
    ;
    mov ax, word ptr es:[MAT_DATA_OFFSET]
    mov word ptr [bp-2], ax
    ;
    ;     short a[100][100];            /* local copy of the matrix */
    ;     short i, j, k;                /* loop counters */
    ;     short sign = 1;               /* sign changes from row swaps */
    ;
    mov word ptr [bp-6], 1
    ;
    ;     short prev_pivot;             /* denominator from previous step */
    ;     short pivot;                  /* current pivot element */
    ;     short pivot_row;              /* row index of non‑zero pivot */
    ;     short tmp;                    /* temporary for row swap */
    ;     short numerator;              /* temporary for exact division */
    ;     short det;                    /* final determinant */
    ;
    ;     /* If not square (should not happen), return 0 and print it. */
    ;     if (mat_rows1 != mat_cols1) {
    ;
    mov ax, word ptr es:[MAT_DATA_OFFSET]
    cmp ax, word ptr es:[MAT_DATA_OFFSET+2]
    je mat_det_square_ok
    ;
    ;         char buf[6] = "0";
    ;
	lea  di, word ptr [bp-24]      ; DI points to buf[0]
	mov  byte ptr [di], '0'        ; buf[0] = '0'
	mov  byte ptr [di+1], 0        ; buf[1] = '\0'
	mov  byte ptr [di+2], 0        ; buf[2] = '\0'
	mov  byte ptr [di+3], 0        ; buf[3] = '\0'
	mov  byte ptr [di+4], 0        ; buf[4] = '\0'
	mov  byte ptr [di+5], 0        ; buf[5] = '\0'
    ;
    ;         putstr(buf);
    ;
    lea ax, word ptr [bp-24]
    push ax
    call near ptr _putstr
    pop cx
    ;
    ;         return 0;
    ;
    xor ax, ax
mat_det_return_zero:
    jmp mat_det_done
mat_det_square_ok:
    ;
    ;     }
    ;
    ;     /* Copy global matrix into local 2D array. */
    ;     for (i = 0; i < n; ++i) {
    ;
    xor di, di
    jmp short mat_det_copy_i_next
mat_det_copy_i_loop:
    ;
    ;         for (j = 0; j < n; ++j) {
    ;
    xor si, si
    jmp short mat_det_copy_j_next
mat_det_copy_j_loop:
    ;
    ;             a[i][j] = mat_data1[i][j];
    ;
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    mov bx, ax
    mov ax, word ptr es:[bx]
    push ax
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    pop ax
    mov word ptr [bx], ax
    inc si
mat_det_copy_j_next:
    cmp si, word ptr [bp-2]
    jl mat_det_copy_j_loop
    inc di
mat_det_copy_i_next:
    cmp di, word ptr [bp-2]
    jl mat_det_copy_i_loop
    ;
    ;         }
    ;     }
    ;
    ;     /* Trivial case: 1x1 matrix. */
    ;     if (n == 1) {
    ;
    cmp word ptr [bp-2], 1
    jne mat_det_size_one_done
mat_det_size_one:
    ;
    ;         det = a[0][0];
    ;
    mov ax, word ptr [bp-20044]
    mov word ptr [bp-18], ax
    ;
    ;         stoa(det, buf1);
    ;
    lea ax, word ptr [bp-44]
    push ax
    push word ptr [bp-18]
    call near ptr _stoa
    pop cx
    pop cx
    ;
    ;         putstr(buf1);
    ;
    lea ax, word ptr [bp-44]
    jmp mat_det_print_buffer
mat_det_size_one_done:
    ;
    ;         return det;
    ;     }
    ;
    ;     /* Bareiss algorithm (fraction‑free elimination). */
    ;     prev_pivot = 1;   /* denominator for the first step (k = 0) */
    ;
    mov word ptr [bp-8], 1
    ;
    ;
    ;     for (k = 0; k < n - 1; ++k) {
    ;
    mov word ptr [bp-4], 0
    jmp mat_det_k_loop_next
mat_det_k_loop_start:
    ;
    ;         /* Find a non‑zero pivot in column k (from row k downwards). */
    ;         pivot_row = -1;
    ;
    mov word ptr [bp-12], 65535
    ;
    ;         for (i = k; i < n; ++i) {
    ;
    mov di, word ptr [bp-4]
    jmp short mat_det_find_pivot_check
mat_det_find_pivot_i_loop:
    ;
    ;             if (a[i][k] != 0) {
    ;
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, word ptr [bp-4]
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    cmp word ptr [bx], 0
    je mat_det_find_pivot_next_i
    ;
    ;                 pivot_row = i;
    ;
    mov word ptr [bp-12], di
    ;
    ;                 break;
    ;
    jmp mat_det_pivot_found
mat_det_find_pivot_next_i:
    inc di
mat_det_find_pivot_check:
    cmp di, word ptr [bp-2]
    jl mat_det_find_pivot_i_loop
mat_det_pivot_found:
    ;
    ;             }
    ;         }
    ;         /* If no non‑zero pivot found, determinant is zero. */
    ;         if (pivot_row == -1) {
    ;
    cmp word ptr [bp-12], 65535
    jne mat_det_no_pivot_skip
mat_det_no_pivot:
    ;
    ;             sign = 0;
    ;
    mov word ptr [bp-6], 0
    ;
    ;             break;
    ;
    jmp mat_det_k_loop_end
mat_det_no_pivot_skip:
    ;
    ;         }
    ;
    ;         /* Swap rows if needed and adjust sign. */
    ;         if (pivot_row != k) {
    ;
    mov ax, word ptr [bp-12]
    cmp ax, word ptr [bp-4]
    jne mat_det_do_swap
    jmp mat_det_swap_done
mat_det_do_swap:
    ;
    ;             for (j = 0; j < n; ++j) {
    ;
    xor si, si
    jmp short mat_det_swap_j_next
mat_det_swap_j_loop:
    ;
    ;                 tmp = a[k][j];
    ;
    mov ax, word ptr [bp-4]
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    mov ax, word ptr [bx]
    mov word ptr [bp-14], ax
    ;
    ;                 a[k][j] = a[pivot_row][j];
    ;
    mov ax, word ptr [bp-12]
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    mov ax, word ptr [bx]
    push ax
    mov ax, word ptr [bp-4]
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    pop ax
    mov word ptr [bx], ax
    ;
    ;                 a[pivot_row][j] = tmp;
    ;
    mov ax, word ptr [bp-12]
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov dx, word ptr [bp-14]
    mov bx, ax
    mov word ptr [bx], dx
    inc si
mat_det_swap_j_next:
    cmp si, word ptr [bp-2]
    jl mat_det_swap_j_loop
    ;
    ;             }
    ;             sign = -sign;
    ;
    mov ax, word ptr [bp-6]
    neg ax
    mov word ptr [bp-6], ax
mat_det_swap_done:
    ;
    ;         }
    ;
    ;         pivot = a[k][k];   /* current pivot (guaranteed non‑zero) */
    ;
    mov ax, word ptr [bp-4]
    mov dx, 200
    imul dx
    mov dx, word ptr [bp-4]
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    mov ax, word ptr [bx]
    mov word ptr [bp-10], ax
    ;
    ;
    ;         /* Update the trailing submatrix. */
    ;         for (i = k + 1; i < n; ++i) {
    ;
    mov ax, word ptr [bp-4]
    inc ax
    mov di, ax
    jmp mat_det_update_i_next
mat_det_update_i_loop:
    ;
    ;             for (j = k + 1; j < n; ++j) {
    ;
    mov ax, word ptr [bp-4]
    inc ax
    mov si, ax
    jmp short mat_det_update_j_next
mat_det_update_j_loop:
    ;
    ;                 /* a[i][j] = (a[i][j] * pivot - a[i][k] * a[k][j]) / prev_pivot */
    ;                 numerator = a[i][j] * pivot - a[i][k] * a[k][j];
    ;
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, word ptr [bp-4]
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    mov ax, word ptr [bx]
    push ax
    mov ax, word ptr [bp-4]
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    pop ax
    imul word ptr [bx]
    push ax
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    mov ax, word ptr [bx]
    imul word ptr [bp-10]
    pop dx
    sub ax, dx
    mov word ptr [bp-16], ax
    ;
    ;                 a[i][j] = numerator / prev_pivot;
    ;
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, si
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    push ax
    mov ax, word ptr [bp-16]
    cwd
    idiv word ptr [bp-8]
    pop bx
    mov word ptr [bx], ax
    inc si
mat_det_update_j_next:
    cmp si, word ptr [bp-2]
    jge mat_det_update_j_done
    jmp mat_det_update_j_loop
mat_det_update_j_done:
    ;
    ;             }
    ;             /* Set elements below the pivot to zero (optional, improves readability). */
    ;             a[i][k] = 0;
    ;
    mov ax, di
    mov dx, 200
    imul dx
    mov dx, word ptr [bp-4]
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20044]
    add ax, dx
    mov bx, ax
    mov word ptr [bx], 0
    inc di
mat_det_update_i_next:
    cmp di, word ptr [bp-2]
    jge mat_det_update_i_done
    jmp mat_det_update_i_loop
mat_det_update_i_done:
    ;
    ;         }
    ;         prev_pivot = pivot;   /* store pivot for next denominator */
    ;
    mov ax, word ptr [bp-10]
    mov word ptr [bp-8], ax
    inc word ptr [bp-4]
mat_det_k_loop_next:
    mov ax, word ptr [bp-2]
    dec ax
    cmp ax, word ptr [bp-4]
    jle mat_det_k_loop_exit
    jmp mat_det_k_loop_start
mat_det_k_loop_exit:
mat_det_k_loop_end:
    ;
    ;     }
    ;
    ;     /* Determinant = sign * last diagonal element. */
    ;     if (sign == 0)
    ;
    cmp word ptr [bp-6], 0
    jne mat_det_sign_nonzero
    ;
    ;         det = 0;
    ;
    mov word ptr [bp-18], 0
    jmp mat_det_det_computed
mat_det_sign_nonzero:
    ;
    ;     else
    ;         det = sign * a[n - 1][n - 1];
    ;
    mov ax, word ptr [bp-2]
    mov dx, 200
    imul dx
    mov dx, word ptr [bp-2]
    shl dx, 1
    add ax, dx
    lea dx, word ptr [bp-20246]
    add ax, dx
    mov bx, ax
    mov ax, word ptr [bx]
    imul word ptr [bp-6]
    mov word ptr [bp-18], ax
mat_det_det_computed:
    ;
    ;
    ;     /* Convert determinant to string and print it. */
    ;     {
    ;         char buffer[20];
    ;         stoa(det, buffer);
    ;
    lea ax, word ptr [bp-20064]
    push ax
    push word ptr [bp-18]
    call near ptr _stoa
    pop cx
    pop cx
    ;
    ;         putstr(buffer);
    ;
    lea ax, word ptr [bp-20064]
mat_det_print_buffer:
    push ax
    call near ptr _putstr
    pop cx
    ;
    ;     }
    ;
    ;     return det;
    ;
    mov ax, word ptr [bp-18]
    jmp mat_det_return_zero
mat_det_done:
    ;
    ; }
    ;
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_mat_det endp