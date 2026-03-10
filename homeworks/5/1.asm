.386

stack_seg segment para stack 'stack' use16
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
    input_string db 241 dup(?)
    new_line db 0dh, 0ah
    repeat_string_n db 10
    counter     db 10
    string_size db ?
data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:  ; initialize ds to point to our data segment
        mov ax, data_seg
        mov ds, ax

		mov bx, 0
		mov cx, 240
		lea dx, input_string
		mov ah, 3Fh
		int 21h		; ax - read len

        mov cx, ax
        mov [string_size], byte ptr al

reverse_print_loop:
        mov bx, cx
        dec bx
        mov ah, 02h
        mov dl, [input_string+bx-1]
        int 21h

        test cx, cx
        dec cx
        jnz reverse_print_loop
        
        ;print new line
        lea dx, new_line
        mov bx, 1
        mov cx, 2
        mov ah, 40h
        int 21h 


print_multiple_times:
        mov bl, byte ptr [counter]
        test bl, bl
        jz print_multiple_end

        mov cx, 0
        mov cl, [string_size]
        mov bx, 1
        lea dx, input_string
        mov ah, 40h 
        int 21h

        lea dx, new_line
        mov bx, 1
        mov cx, 2
        mov ah, 40h
        int 21h 

        mov bl, byte ptr [counter]
        dec bl
        mov byte ptr [counter], bl
        jmp print_multiple_times 
        
print_multiple_end:

        ; terminate program with return code 0
        mov ax, 4c00h           
        int 21h

code_seg ends

end start
