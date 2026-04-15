_test_file proc near 
    push bp
    mov bp, sp
    sub sp, 4

    push OFFSET filename
    push ACCESS_READ
    call fopen
    jc  error_failed_to_open_exit          ; CF set -> error
    add sp, 4
    mov bx, ax  

    push bx
    call fsize
    jc  close_and_exit_fsize      ; error -> close & exit
    add sp, 2
    ; DX:AX = file size, assume size fits in 16 bits (AX)
    mov cx, ax              ; CX = number of bytes to read

    ; 3. Read entire file into a newly allocated string (freadtos)
    push bx                 ; file handle
    push cx                 ; count of bytes
    call freadtos
    jc  close_and_exit_freadtos      ; allocation/read error
    add sp, 4

    push offset msg_loaded_str
    call putstr
    add sp, 2

    push ds                 ; save original DS
    mov ds, ax              ; set DS to the allocated segment
    mov bx, ax
    push 0                  ; offset 0
    call putstr             ; print the string
    add sp, 2

    call putnewline

    push '|'
    push 0
    call strchr
    add sp, 4

    ; pop ds                  ; restore DS
    
    test ax, ax
    jz error_failed_to_find_chr

    ; push ds                 ; save original DS
    ; mov ds, bx              ; set DS to the allocated segment
    mov si, ax

    mov byte ptr es:[si], 0
    
    mov word ptr ss:[bp-2], 0
    mov word ptr ss:[bp-4], si
    inc word ptr ss:[bp-4]

    pop ds

    push ds

    mov ds, bx
    push word ptr [bp-2]
    push word ptr [bp-4]
    call strcmp
    add sp,4

    pop ds
    
    cmp  ax, 0
    je   equal
    jg   greater
    mov  dx, offset msg_less
    jmp  print
equal:
    mov  dx, offset msg_equal
    jmp  print
greater:
    mov  dx, offset msg_greater
print:
    push dx
    call putstr
    add sp, 2

    push ds

    mov bx, es
    mov ds, bx
    push word ptr [bp-2]
    push word ptr [bp-4]
    call stricmp
    add sp,4

    pop ds

    cmp  ax, 0
    je   equal_ic
    jg   greater_ic

    mov  dx, offset msg_less_ic
    jmp  print_ic
equal_ic:
    mov  dx, offset msg_equal_ic
    jmp  print_ic
greater_ic:
    mov  dx, offset msg_greater_ic
print_ic:
    push dx
    call putstr
    add sp, 2

_test_done_close_clear:
    push ax                 ; segment to free
    call FreeMem
    add sp, 2


    ; 5. Close file
    push bx
    call fclose
    add sp, 2

_test_done:
    mov sp, bp
    pop bp
    ret

error_exit:
    push offset error_msg
    call putstr
    add sp, 2
    jmp _test_done

error_failed_to_open_exit:
    mov cx, ax

    push offset filename
    call putstr
    add sp, 2

    push cx
    call fio_error_handler
    add sp, 2
    jmp _test_done

error_failed_to_fsize_file_exit:
    push ERROR_OPEN
    call error_handler
    add sp, 2
    jmp _test_done


close_and_exit_freadtos:
    add sp, 2

close_and_exit_fsize:
    add sp, 2

    push ax
    call fio_error_handler
    add sp, 2
    push bx
    call fclose
    add sp, 2
    jmp error_exit

error_failed_to_find_chr:
    pop ds

    call putnewline

    push offset msg_filed_to_find_delimiter
    call putstr
    add sp,2 

    jmp _test_done_close_clear
_test_file endp
