.386

stack_seg segment para stack 'stack' use16
    db 65535 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
    formated_string_buffer db 256 dup(0)
    formated_string_buffer2 db 256 dup(0)
    formated_string_buffer3 db 256 dup(0)

    input_expression db 1024 dup (?)
; msgs
    enter_num_sys_msg db 'enter input numerical system(h - hex, d - decimal):', 0
    enter_exp_msg db 'enter expression(for example: "-f + 1", "2 + 2"):', 0
    output_dec_msg db 'decimal: ', 0
    output_hex_msg db 'hex: ', 0

; errors
    overflow_msg db 'Overflow error',  0dh, 0ah, 0
    invalid_exp_msg db 'Invalid expression format',  0dh, 0ah, 0
    invalid_exp_operation_msg db 'Invalid operation',  0dh, 0ah, 0
    divide_by_zero db 'Divide by zero',  0dh, 0ah, 0
    invalid_number_msg db 'Invalid number',  0dh, 0ah, 0

    msg_vec dw offset overflow_msg, offset invalid_exp_msg, offset invalid_exp_operation_msg
            dw offset divide_by_zero, offset invalid_number_msg

    ERROR_OVERFLOW equ 0
    ERROR_INVALID_EXPRESSION equ 1
    ERROR_INVALID_EXPRESSION_OP equ 2
    ERROR_DIVIDE_BY_ZERO equ 3
    ERROR_INVALID_NUMBER equ 4

; global variables
    atoi_ptr     dw 0
    result_a     dw 0
    result_b     dw 0
    result_op    db 0

data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg


;----------------------------------------------------------------------
; puts - Print a zero‑terminated string to standard output (using DOS function 02h)
; Input:
;   [bp+4] = address of the string
; Output: none
;----------------------------------------------------------------------
puts:
    push bp
    mov bp, sp

    mov di, word ptr [bp+4]

    mov ah, 02h

puts_loop:
    mov dl, byte ptr [di]
    int 21h

    inc di
    test dl, dl
    jnz puts_loop

    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; itoa_hex - Convert a 16‑bit signed integer to a hexadecimal string
; Input:
;   [bp+4] = output buffer (near pointer)
;   [bp+6] = number to convert (16‑bit signed)
; Output:
;   Buffer contains null‑terminated hex string (uppercase)
;   AX = number of characters written (always 4 digits for positive, 5 with sign)
;----------------------------------------------------------------------
itoa_hex:
    push bp
    mov bp, sp
    
    mov di, [bp+4] ; get string address
    mov bx, [bp+6] ; get number

    test bx, bx
    jnz itoa_hex_not_zero
    ; zero case
    mov byte ptr [di], '0'
    inc di
    mov ax, 0       ; (original code, maybe return value)
    jmp itoa_hex_done
itoa_hex_not_zero:
    ; check sign
    test bx, bx
    jns itoa_hex_positive
    ; negative: print '-' and take absolute value
    mov byte ptr [di], '-'
    inc di
    neg bx          ; now bx holds the magnitude
itoa_hex_positive:
    mov cx, 4
itoa_hex_loop:
    rol bx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 10  
    jl digit    
    add al, 'A' - 10
    jmp put_char
digit:
    add al, '0'
put_char:
    mov byte ptr [di], al
    inc di
    loop itoa_hex_loop

    mov byte ptr [di], 0
itoa_hex_done:
    mov ax, 8
    pop bp
    ret

;----------------------------------------------------------------------
; itoa_dec - Convert a 16‑bit signed integer to a decimal string
; Input:
;   [bp+4] = output buffer (near pointer)
;   [bp+6] = number to convert (16‑bit signed)
; Output:
;   AX = number of characters written (not counting null terminator)
;----------------------------------------------------------------------
itoa_dec:
    push bp
    mov  bp, sp

    mov  di, word ptr [bp+4]   ; pointer to output buffer
    mov  ax, word ptr [bp+6]   ; the number to convert

    ; --- handle zero separately (no sign) ---
    test ax, ax
    jnz  itoa_not_zero

    mov  byte ptr [di], '0'    ; write '0'
    mov  ax, 1                 ; output size = 1
    jmp  itoa_done

itoa_not_zero:
    xor  bx, bx
    cmp  ax, 0
    jge  itoa_positive
    mov  bx, 1 
    neg  ax    

itoa_positive:
    xor  cx, cx
    mov  si, 10

itoa_divide_loop:
    xor  dx, dx
    div  si                    ; ax = quotient, dx = remainder (digit)
    push dx                    ; store digit
    inc  cx
    test ax, ax
    jnz  itoa_divide_loop

    mov  di, word ptr [bp+4]   ; reset pointer to start of buffer
    test bx, bx
    jz   itoa_no_sign
    mov  byte ptr [di], '-'    ; write minus sign
    inc  di                    ; advance pointer

itoa_no_sign:
    mov  bx, cx
    jcxz itoa_skip_write   

itoa_write_loop:
    pop  dx
    add  dl, '0'
    mov  byte ptr [di], dl
    inc  di
    loop itoa_write_loop

    mov byte ptr [di], 0
itoa_skip_write:

    mov  ax, bx                
    test bx, bx                
    jz   itoa_done_size
    inc  ax

itoa_done_size:
itoa_done:
    mov  sp, bp
    pop  bp
    ret

;----------------------------------------------------------------------
; itoa_hex32 - Convert a signed 32‑bit integer to a hexadecimal string
; Input:
;   [bp+4] = output buffer (near pointer)
;   [bp+6] = high word (DX)
;   [bp+8] = low word (AX)
; Output:
;   Buffer contains null‑terminated hex string (uppercase)
;   AX = number of characters written (including sign)
;----------------------------------------------------------------------
itoa_hex32:
    push    bp
    mov     bp, sp
    push    si
    push    di
    push    bx

    ; Load arguments
    mov     di, [bp+4]          ; DI = output buffer
    mov     dx, [bp+6]          ; DX = high word
    mov     ax, [bp+8]          ; AX = low word

    ; Sign handling (same as itoa_dec32)
    xor     bh, bh              ; BH = sign flag (0 = positive, 1 = negative)
    test    dx, dx
    jns     itoa_hex32_positive ; JNS - jump if not signed

    ; Negative number: write '-' and negate the 32‑bit value
    mov     bh, 1
    mov     byte ptr [di], '-'
    inc     di
    not     dx
    not     ax
    add     ax, 1
    adc     dx, 0

itoa_hex32_positive:
    xor     bl, bl
    mov     cx, 16

itoa_hex32_digit_loop:
    push    ax                  ; save low word
    mov     ax, dx              ; move high word to AX
    xor     dx, dx              ; clear DX for division
    div     cx                  ; AX = high/16, DX = high%16
    mov     si, ax              ; SI = high quotient
    pop     ax                  ; restore low word
    div     cx                  ; DX:AX / 16 -> AX = low quotient, DX = digit
    push    dx                  ; store digit on stack
    inc     bl                  ; one more digit
    mov     dx, si              ; DX = high quotient
    mov     si, ax              ; SI = low quotient
    or      si, dx              ; check if any part of the quotient is non‑zero
    jnz     itoa_hex32_digit_loop

    xor     ch, ch
    mov     cl, bl              ; CX = digit count
itoa_hex32_write_loop:
    pop     dx                  ; DX = digit (0..15)
    add     dl, '0'             ; convert to ASCII digit
    cmp     dl, '9'
    jbe     itoa_hex32_store
    add     dl, 'A'-'0'-10      ; adjust to 'A'..'F' if digit > 9
itoa_hex32_store:
    mov     byte ptr [di], dl
    inc     di
    dec     cx
    jnz     itoa_hex32_write_loop

    ; Null‑terminate the string
    mov     byte ptr [di], 0

    ; Return total characters written (sign + digits)
    mov     al, bl              ; digit count
    add     al, bh              ; add sign if any
    xor     ah, ah

    ; Restore registers and return
    pop     bx
    pop     di
    pop     si
    mov     sp, bp
    pop     bp
    ret

;----------------------------------------------------------------------
; itoa_dec32 - Convert a signed 32‑bit integer to a decimal string
; Input:
;   [bp+4] = output buffer (near pointer)
;   [bp+6] = high word (DX)
;   [bp+8] = low word (AX)
; Output:
;   AX = number of characters written (including sign)
;----------------------------------------------------------------------
itoa_dec32:
    push    bp
    mov     bp, sp
    push    si
    push    di
    push    bx

    ; Load arguments
    mov     di, [bp+4]          ; DI = output buffer
    mov     dx, [bp+6]          ; DX = high word
    mov     ax, [bp+8]          ; AX = low word

    ; Sign handling
    xor     bh, bh              ; BH = 0 (positive)
    test    dx, dx
    jns     itoa_dec32_positive

    ; Negative number: write '-' and negate the 32‑bit value
    mov     bh, 1               ; BH = 1 (negative)
    mov     byte ptr [di], '-'
    inc     di
    not     dx
    not     ax
    add     ax, 1
    adc     dx, 0

itoa_dec32_positive:
    ; Convert absolute value to digits
    xor     bx, bx              ; BX = digit count (0..10)
    mov     cx, 10              ; divisor

itoa_dec32_digit_loop:
    push    ax                  ; save low word
    mov     ax, dx              ; high word into AX
    xor     dx, dx              ; clear DX for division
    div     cx                  ; AX = high/10, DX = high%10
    mov     si, ax              ; SI = high quotient
    pop     ax                  ; restore low word
    div     cx                  ; DX:AX / 10 -> AX = low quotient, DX = digit
    push    dx                  ; store digit on stack
    inc     bl                  ; increment digit count
    mov     dx, si              ; DX = high quotient
    mov     si, ax              ; SI = low quotient
    or      si, dx              ; check if any part of quotient is non-zero
    jnz     itoa_dec32_digit_loop

    ; Write digits in reverse order
    mov     cx, bx              ; CX = digit count
itoa_dec32_write_loop:
    pop     dx
    add     dl, '0'
    mov     [di], dl
    inc     di
    dec     cx
    jnz     itoa_dec32_write_loop

    ; Null-terminate the string
    mov     byte ptr [di], 0

    ; Return total characters written (sign + digits)
    mov     al, bl              ; digit count
    add     al, bh              ; add sign if present
    xor     ah, ah

    pop     bx
    pop     di
    pop     si
    mov     sp, bp
    pop     bp
    ret

;----------------------------------------------------------------------
; atoi_dec - Convert a decimal string to a signed 16‑bit integer
; Input:
;   [bp+4] = pointer to string
;   [bp+6] = length of string (in bytes)
; Output:
;   AX = converted number (if successful)
;   CF = 0 on success, 1 on overflow
;   On overflow, AX = ERROR_OVERFLOW
;----------------------------------------------------------------------
atoi_dec:
    push bp
    mov  bp, sp
    push si
    push di
    push bx
    push dx

    ; Load arguments
    mov  si, word ptr [bp+4]          ; SI = pointer to string
    mov  cx, word ptr [bp+6]          ; CX = length

    xor  ax, ax              ; result = 0
    xor  di, di              ; sign = 0 (positive)

    test cx, cx
    jz   atoi_dec_end_convert

    ; Check '-' sign
    mov  bl, byte ptr [si]
    cmp  bl, '-'
    jne  atoi_dec_no_sign

    inc  di                  ; sign = negative
    inc  si
    dec  cx

    test cx, cx
    jz   atoi_dec_end_convert

atoi_dec_no_sign:

atoi_dec_convert_loop:
    mov  bl, byte ptr [si]

    cmp  bl, 0dh
    jb   atoi_dec_end_convert
    cmp  bl, '0'
    jb   atoi_dec_invalid_number
    cmp  bl, '9'
    ja   atoi_dec_invalid_number


    sub  bl, '0'
    mov  bh, 0               ; BX = digit

    ; ---- OVERFLOW CHECK BEFORE *10 ----
    ; AX must be <= 3276

    mov  dx, ax
    cmp  dx, 3276
    ja   atoi_dec_overflow

    jne  atoi_dec_safe_mul

    ; AX == 3276 → digit limit check

    cmp  di, 0
    jne  atoi_dec_neg_limit

    ; positive limit digit ≤ 7
    cmp  bl, 7
    ja   atoi_dec_overflow
    jmp  atoi_dec_safe_mul

atoi_dec_neg_limit:
    ; negative limit digit ≤ 8
    cmp  bl, 8
    ja   atoi_dec_overflow

atoi_dec_safe_mul:
    ; AX = AX * 10
    mov  dx, 10
    mul  dx                  ; DX:AX = AX * 10

    test dx, dx
    jnz  atoi_dec_overflow

    ; AX += digit
    add  ax, bx
    jc   atoi_dec_overflow

    inc  si
    dec  cx
    jnz  atoi_dec_convert_loop

atoi_dec_end_convert:
    ; Apply sign with special case for -32768
    test di, di
    clc
    jz   atoi_dec_done

    cmp  ax, 32768           ; Check if absolute value is 32768
    clc
    jne  atoi_dec_neg_normal

    ; It's -32768, set result directly
    mov  ax, -32768
    clc
    jmp  atoi_dec_done

atoi_dec_neg_normal:
    neg  ax
    clc
    jo   atoi_dec_overflow   ; should not happen for valid values, but keep

atoi_dec_done:
    pop  dx
    pop  bx
    pop  di
    pop  si
    mov  sp, bp
    pop  bp
    ret

atoi_dec_overflow:
    ; Return saturated value depending on sign
    cmp  di, 0
    jne  atoi_dec_overflow_neg
    ; Positive overflow → return 32767
    mov  ax, ERROR_OVERFLOW
    stc
    jmp  atoi_dec_done

atoi_dec_overflow_neg:
    ; Negative overflow → return -32768
    ;mov  ax, -32768
    mov  ax, ERROR_OVERFLOW
    stc    
    
    jmp  atoi_dec_done

atoi_dec_invalid_number:
    mov  ax, ERROR_INVALID_NUMBER
    stc
    jmp  atoi_dec_done

;----------------------------------------------------------------------
; atoi_hex - Convert a hexadecimal string to a signed 16‑bit integer
; Input:
;   [bp+4] = pointer to string
;   [bp+6] = length of string (in bytes)
; Output:
;   AX = converted number (if successful)
;   CF = 0 on success, 1 on overflow
;   On overflow, AX = ERROR_OVERFLOW
;----------------------------------------------------------------------
atoi_hex:
    push bp
    mov  bp, sp
    push si
    push di
    push bx
    push dx

    mov  si, word ptr [bp+4]   ; pointer to string
    mov  cx, word ptr [bp+6]   ; length of string

    xor  ax, ax                ; result = 0
    xor  di, di                ; sign = 0 (0 = positive, 1 = negative)

    ; Empty string -> invalid
    test cx, cx
    jz   atoi_hex_invalid_number

    ; Optional leading '-'
    mov  bl, byte ptr [si]
    cmp  bl, '-'
    jne  atoi_hex_no_sign

    inc  di                    ; remember negative sign
    inc  si
    dec  cx

    test cx, cx                ; after sign there must be at least one character
    jz   atoi_hex_invalid_number

atoi_hex_no_sign:

    ; Skip optional '0x' or '0X' prefix
    cmp  cx, 2
    jb   atoi_hex_no_prefix

    mov  bl, byte ptr [si]
    cmp  bl, '0'
    jne  atoi_hex_no_prefix

    mov  bl, byte ptr [si+1]
    cmp  bl, 'x'
    je   atoi_hex_prefix_skip
    cmp  bl, 'X'
    jne  atoi_hex_no_prefix

atoi_hex_prefix_skip:
    add  si, 2
    sub  cx, 2

    test cx, cx                ; after '0x' there must be at least one hex digit
    jz   atoi_hex_invalid_number

atoi_hex_no_prefix:

atoi_hex_convert_loop:
    mov  bl, byte ptr [si]

    ; Check for '0'..'9'
    cmp  bl, '0'
    jb   atoi_hex_invalid_number
    cmp  bl, '9'
    jbe  atoi_hex_digit_0_9

    ; Check for 'A'..'F'
    cmp  bl, 'A'
    jb   atoi_hex_invalid_number
    cmp  bl, 'F'
    jbe  atoi_hex_digit_bA_F

    ; Check for 'a'..'f'
    cmp  bl, 'a'
    jb   atoi_hex_invalid_number
    cmp  bl, 'f'
    jbe  atoi_hex_digit_a_f

    ; Any other character -> invalid
    jmp  atoi_hex_invalid_number

atoi_hex_digit_0_9:
    sub  bl, '0'
    jmp  atoi_hex_got_digit

atoi_hex_digit_bA_F:
    sub  bl, 'A'
    add  bl, 10
    jmp  atoi_hex_got_digit

atoi_hex_digit_a_f:
    sub  bl, 'a'
    add  bl, 10

atoi_hex_got_digit:
    ; Multiply current result by 16 (shift left 4 bits)
    mov  dx, ax
    shl  dx, 4

    ; Check for overflow before adding the new digit
    cmp  di, 0
    je   atoi_hex_check_pos_mul

    ; Negative number: result must not exceed -32768 in absolute value
    cmp  dx, 8000h
    ja   atoi_hex_overflow
    jmp  atoi_hex_add_digit

atoi_hex_check_pos_mul:
    cmp  dx, 7FFFh
    ja   atoi_hex_overflow

atoi_hex_add_digit:
    xor  bh, bh
    add  dx, bx

    ; Check overflow after addition
    cmp  di, 0
    je   atoi_hex_check_pos_add

    cmp  dx, 8000h
    ja   atoi_hex_overflow

    ; Special case: -32768 is allowed only if it's the complete number
    cmp  dx, 8000h
    jne  atoi_hex_store_negative_result
    cmp  cx, 1
    jne  atoi_hex_overflow

atoi_hex_store_negative_result:
    mov  ax, dx
    jmp  atoi_hex_digit_done

atoi_hex_check_pos_add:
    cmp  dx, 7FFFh
    ja   atoi_hex_overflow
    mov  ax, dx

atoi_hex_digit_done:
    inc  si
    dec  cx
    jnz  atoi_hex_convert_loop

    ; Normal termination: processed all characters successfully
atoi_hex_end_convert:
    test di, di
    jz   atoi_hex_done

    ; Apply negative sign (except for -32768 which is already correct)
    cmp  ax, 8000h
    je   atoi_hex_done
    neg  ax

atoi_hex_done:
    pop  dx
    pop  bx
    pop  di
    pop  si
    mov  sp, bp
    pop  bp
    clc
    ret

; Return error: invalid hex digit or missing digits
atoi_hex_invalid_number:
    pop  dx
    pop  bx
    pop  di
    pop  si
    mov  sp, bp
    pop  bp
    mov  ax, ERROR_INVALID_NUMBER
    stc
    ret

; Return error: numeric overflow
atoi_hex_overflow:
    pop  dx
    pop  bx
    pop  di
    pop  si
    mov  sp, bp
    pop  bp
    mov  ax, ERROR_OVERFLOW
    stc
    ret


;----------------------------------------------------------------------
; error_handler - Display an error message based on error code
; Input:
;   [bp+4] = error code (one of ERROR_* constants)
; Output: none (program exits with return code 0xFF)
;----------------------------------------------------------------------
error_handler:
    push bp
    mov  bp, sp

    push dx

    mov  ax, word ptr [bp+4]        ; AX = error_code
    mov  bx, ax
    shl  bx, 1
    mov  dx, word ptr [msg_vec + bx] 

    push dx
    call puts
    add sp, 2

    ; mov  ah, 09h
    ; int  21h
    jmp handler_end


handler_end: 
    mov ax, 4cFFh
    int 21h

handler_exit:
    pop  dx

    mov  sp, bp
    pop  bp
    ret

;----------------------------------------------------------------------
; parse_expression - Parse a string like "a + b" into result_a, result_b, result_op
; Input:
;   [bp+4] = pointer to expression string
;   [bp+6] = length of string (in bytes)
; Output:
;   CF = 0 on success, 1 on error (with error code in AX)
;   On success, global variables result_a, result_b, result_op are set.
;----------------------------------------------------------------------
parse_expression:
    push bp
    mov  bp, sp
    sub sp, 2+1+2+2 ; 1:2bytes - first value, 2: 1 byte - operation, 3: 2 bytes - second ptr, 4: 2 bytes - second value

    mov di, [bp+4]
    mov cx, [bp+6]

    mov ax, 0
    mov word ptr [bp-7], ax

parse_expression_loop:
    inc di
    cmp byte ptr [di], ' '
    je parse_expression_loop_white_space
    cmp  byte ptr [di], 0Dh
    je parse_expression_loop_end
    loop parse_expression_loop

    parse_expression_loop_white_space:
        mov ax, word ptr [bp+4]
        mov si, di
        sub di, ax
        clc
        mov ax, di
        mov di, si

        push ax
        push [bp+4]
        call atoi_ptr
        jc parse_number_failed
        add sp, 4
        clc

        mov word ptr [result_a], ax

        inc di
        mov al, byte ptr [di]
        
        ; Validate operation
        cmp al, '+'
        je parse_expression_op_valid
        cmp al, '-'
        je parse_expression_op_valid
        cmp al, '*'
        je parse_expression_op_valid
        cmp al, '/'
        je parse_expression_op_valid
        cmp al, '%'
        je parse_expression_op_valid
        jmp parse_expression_invalid_op
        
    parse_expression_op_valid:
        mov byte ptr [result_op], al ; save op

        inc di ; skipping operation
        inc di 
        mov word ptr [bp-5], di
        dec di

        mov ax, word ptr [bp-7]
        cmp ax, 1
        je parse_expression_invalid_format

        mov ax, 1
        mov word ptr [bp-7], ax

    loop parse_expression_loop

    parse_expression_loop_end:
        mov ax, word ptr [bp-7]
        cmp ax, 1
        jne parse_expression_invalid_format

        mov word ptr [bp-7], ax
        mov ax, 1

        mov ax, word ptr [bp-5]
        sub di, ax
        clc
        mov ax, word ptr [bp-5]
        
        ; Validate second operand exists
        cmp di, 0
        je parse_expression_invalid_second_operand
        
        push di
        push ax
        call atoi_ptr
        jc parse_number_failed
        add sp, 4
        clc

        mov word ptr [result_b], ax
        dec di

    mov  sp, bp
    pop  bp
    xor ax, ax  ; Return 0 for success
    clc
    ret

parse_number_failed:
    add sp, 4
    ; mov ax, ERROR_OVERFLOW
    stc
    mov  sp, bp
    pop  bp
    ret

parse_expression_failed:
    add sp, 4
    mov ax, ERROR_INVALID_EXPRESSION
    stc
    mov  sp, bp
    pop  bp
    ret

parse_expression_invalid_op:
    add sp, 4
    mov ax, ERROR_INVALID_EXPRESSION_OP
    stc
    mov sp, bp
    pop bp
    ret

parse_expression_invalid_second_operand:
    add sp, 4
    mov ax, ERROR_INVALID_EXPRESSION
    stc
    mov sp, bp
    pop bp
    ret

parse_expression_invalid_format:
    mov ax, ERROR_INVALID_EXPRESSION
    stc
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; calculate - Perform arithmetic operation on two 16‑bit signed numbers
; Input:
;   [bp+4] = first number (WORD)
;   [bp+6] = second number (WORD)
;   [bp+8] = operation (BYTE: '+', '-', '*', '/', '%')
; Output:
;   For +, -, /, %: result in AX (16-bit), DX = 0
;   For *: result in DX:AX (32-bit)
;   On error: CF=1, AX = error code (ERROR_OVERFLOW or ERROR_DIVIDE_BY_ZERO)
;----------------------------------------------------------------------
calculate:
    push bp
    mov  bp, sp
    sub  sp, 2                ; Reserve local variable (unused)

    mov  ax, word ptr [bp+4]           ; First operand
    mov  bx, word ptr [bp+6]           ; Second operand
    mov  cl, byte ptr [bp+8]           ; Operator

    cmp  cl, '+'
    je   op_add
    cmp  cl, '-'
    je   op_sub
    cmp  cl, '*'
    je   op_mul
    cmp  cl, '/'
    je   op_div
    cmp  cl, '%'
    je   op_mod
    jmp  invalid_op

op_add:
    add  ax, bx
    jo   overflow_err         ; Signed overflow
    xor  dx, dx               ; DX = 0 for 16‑bit result
    clc
    jmp  done

op_sub:
    sub  ax, bx
    jo   overflow_err
    xor  dx, dx
    clc
    jmp  done

op_mul:
    imul bx                   ; DX:AX = AX * BX (signed 32‑bit result)
    clc
    jmp  done

op_div:
    test bx, bx
    jz   div_by_zero
    cmp  bx, -1               ; Check for overflow: dividing -32768 by -1
    jne  do_div
    cmp  ax, -32768
    je   overflow_err
do_div:
    cwd                       ; Sign extend AX to DX:AX
    idiv bx                   ; AX = quotient, DX = remainder
    xor  dx, dx               ; For 16‑bit result, clear DX
    clc
    jmp  done

op_mod:
    test bx, bx
    jz   div_by_zero
    cmp  bx, -1
    jne  do_mod
    cmp  ax, -32768
    je   overflow_err
do_mod:
    cwd
    idiv bx
    mov  ax, dx               ; Remainder -> AX
    xor  dx, dx
    clc
    jmp  done

overflow_err:
    mov  ax, ERROR_OVERFLOW
    stc
    jmp  done

div_by_zero:
    mov  ax, ERROR_DIVIDE_BY_ZERO
    stc
    jmp  done

invalid_op:
    mov  ax, ERROR_INVALID_EXPRESSION
    stc

done:
    mov  sp, bp
    pop  bp
    ret

start:
    mov ax, data_seg
    mov ds, ax

    mov ax, stack_seg 
    mov ss, ax

    mov bp, sp
    sub sp, 4


    push offset enter_num_sys_msg
    call puts
    add sp, 2

    mov ah, 01h
    int 21h       

    cmp al, 'h'
    je set_hex
    mov word ptr [atoi_ptr], offset atoi_dec
    r_set_hex:

    mov dl, 0DH
    mov ah, 02h
    int 21h    
    mov dl, 0AH
    int 21h

    push offset enter_exp_msg
    call puts
    add sp, 2


    ; read from input descriptor
	mov bx, 0
	mov cx, 1023
	lea dx, input_expression
	mov ah, 3Fh
	int 21h		; ax - read len


    push ax
    push offset [input_expression]
    call parse_expression
    jc failed_parsing_expression
    add sp, 4

    mov ax, word ptr [result_a]
    mov bx, word ptr [result_b]
    mov cl, byte ptr [result_op]
    xor ch, ch

    push cx
    push word ptr [result_b]
    push word ptr [result_a]
    call calculate
    jc failed_to_calculate
    add sp, 6

    mov cl, byte ptr [result_op]
    cmp cl, '*'
    je print_32
    jne print_16

print_32:
    mov word ptr [bp-2], dx
    mov word ptr [bp-4], ax
    push dx
    push ax

    push offset [output_dec_msg]
    call puts
    add sp, 2

    pop ax
    pop dx

    push dx
    push ax

    push ax
    push dx
    push offset [formated_string_buffer]
    call itoa_dec32
    add sp, 6

    push offset [formated_string_buffer]
    call puts
    add sp, 2

    mov dl, 0DH
    mov ah, 02h
    int 21h    
    mov dl, 0AH
    int 21h

    push offset [output_hex_msg]
    call puts
    add sp, 2

    pop dx
    pop ax

    push dx          ; high word
    push ax          ; low word
    push offset [formated_string_buffer2]
    call itoa_hex32
    add sp, 6

    push offset [formated_string_buffer2]
    call puts
    add sp, 2

    mov dl, 0DH
    mov ah, 02h
    int 21h    
    mov dl, 0AH
    int 21h

    mov sp, bp
    ; terminate program with return code 0
    mov ax, 4c00h
    int 21h

print_16:
    push ax

    push offset [output_dec_msg]
    call puts
    add sp, 2

    pop  ax
    push ax

    push ax
    push offset [formated_string_buffer]
    call itoa_dec
    add sp, 4

    push offset [formated_string_buffer]
    call puts
    add sp, 2

    mov dl, 0DH
    mov ah, 02h
    int 21h    
    mov dl, 0AH
    int 21h

    pop ax
    push ax
    push offset [formated_string_buffer2]
    call itoa_hex
    add sp, 4

    push offset [output_hex_msg]
    call puts
    add sp, 2

    push offset [formated_string_buffer2]
    call puts
    add sp, 2

    mov dl, 0DH
    mov ah, 02h
    int 21h    
    mov dl, 0AH
    int 21h

    mov sp, bp
    ; terminate program with return code 0
    mov ax, 4c00h
    int 21h

failed_to_calculate:
    add sp, 4
failed_parsing_expression:
    add sp, 4
    push ax
    call error_handler
    add sp, 2

    mov sp, bp
    ; terminate program with return code -1
    mov ax, 4cFFh           
    int 21h

set_hex:
    mov word ptr [atoi_ptr], offset atoi_hex
    jmp r_set_hex

code_seg ends

end start