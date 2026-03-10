.386

stack_seg segment para stack 'stack' use16
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
    input_string db 100 dup(?)
    new_line db 0dh, 0ah

    max db ?
    min db ?

    msg_max db 'Enter max!', 0dh, 0ah, '$'
    msg_min db 'Enter min!', 0dh, 0ah, '$'
    msg_err db 'Some character in the string is not within the specified range:', '$'
    msg_suc db 'All characters in a string within the specified range', 0dh, 0ah, '$'

    err_counter db 0
    reserved db ?
    counter dw ?
data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:

    ; initialize ds to point to our data segment
    mov ax, data_seg
    mov ds, ax

    mov dx, offset msg_min  
    mov ah, 9
    int 21h

    mov ah, 01
    int 21h
    mov [min], al

    ; flush the CR left in the buffer
    mov ah, 07h            ; direct console input, no echo
    int 21h                ; consumes the CR (or any next char)

    lea dx, new_line
    mov bx, 1
    mov cx, 2
    mov ah, 40h
    int 21h 

    mov dx, offset msg_max
    mov ah, 9
    int 21h

    mov ah, 01
    int 21h
    mov [max], al

    ; flush the CR
    mov ah, 07h
    int 21h

    lea dx, new_line
    mov bx, 1
    mov cx, 2
    mov ah, 40h
    int 21h 

	mov bx, 0
	mov cx, 99
	lea dx, input_string
	mov ah, 3Fh
	int 21h		; ax - read len

    test ax,ax
    jz exit
    mov cx, ax

    ; check if the last byte is CR (0Dh)
    mov bx, cx
    dec bx
    cmp byte ptr [input_string + bx], 0Dh
    jne check_all
    dec cx                 ; exclude the CR from checking
    jcxz exit           ; if only CR was entered, nothing to check

check_all:
    xor bx, bx             ; index = 0
search:

    mov dl, [input_string+bx]
	
	cmp dl, 0Dh
	je exit
	
    mov al, [min]  
    cmp dl, al   ; 97 
    jb err

    mov al, [max]
    cmp dl, al
    ja err

    inc bx
    loop search

exit:
    mov dl,err_counter 
    test dl, dl
    jnz err_exit

    lea dx, msg_suc      
    mov ah, 9
    int 21h

    ; terminate program with return code 0
    mov ax, 4c00h           
    int 21h
    
err_exit:
    ; terminate program with return code -1
    mov ax, 4cFFh           
    int 21h


err:
    mov dl, [err_counter]
    inc dl
    mov [err_counter], dl
    dec dl
    test dl, dl
    jnz print_err_char

    lea dx, msg_err
    mov ah, 9
    int 21h

print_err_char:
    mov ah, 02h

    mov dl, '['
    int 21h

    mov dl, [input_string+bx]
    int 21h

    mov dl, '-'
    int 21h
 
    xor dx, dx  
    xor ax, ax
    mov al, bl
    mov di, 10

    div di

    mov [reserved], dl

    mov ah, 02h
    add al, '0'
    mov dl, al
    int 21h

    mov ah, 02h
    mov dl, [reserved]
    add dl, '0'
    int 21h

    mov ah, 02h
    mov dl, ']'
    int 21h
    inc bx
    jmp search
    ; mov ax, 4cFFh
    ; int 21h


code_seg ends

end start
