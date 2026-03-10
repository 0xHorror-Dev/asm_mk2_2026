.386

stack_seg segment para stack 'stack' use16
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
	sym_pos equ 7
	src_string db "Try find symbol!"
	new_line db 0dh, 0ah, "$"
	src_len dw ?
	success_str db "Symbol - was found!", 0dh, 0ah, "$"
	error_str db "Symbol - wasn't found (((", 0dh, 0ah, "$"
	reserved byte 0
    ask_counter db 0
	enter_counter db 0
data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:
    mov ax, data_seg
    mov ds, ax
    mov ax, stack_seg
    mov ss, ax
	nop

ask:

	mov ah, 01h
	int 21h

	cmp al, 0Dh
	je enter_input
	
	xor ah, ah
	mov [enter_counter], ah	

	mov byte ptr [reserved], al
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov al, byte ptr [reserved]
	mov cx, offset new_line
	mov bx, offset src_string
	sub cx, bx	; cx = длина строки
	mov word ptr [src_len], cx
	
	dec bx
search:
	inc bx
	cmp al, byte ptr [bx]
	loopne search			
		; cx--; завершение цикла, если cx == 0 или al == byte ptr [bx] (ZF==1)
	
	je found
	
	mov bl,		byte ptr [reserved]
	mov [error_str+sym_pos],  bl
	
	lea dx, error_str
	jmp print
found:
	mov bl,		byte ptr [reserved]
	mov [success_str+sym_pos],  bl

	mov dx, offset success_str
print:
	mov ah, 09h
	int 21h

    mov ah, [ask_counter]
    inc ah
    mov [ask_counter], ah 
    
    cmp ah, 05h
    je print_src_string

    jmp ask

exit:
	mov ax, 4c00h
	int 21h

print_src_string:
    mov ah, 0
    mov [ask_counter], ah

	mov bx, 1
	mov cx, [src_len]
	lea dx, src_string
	mov ah, 40h 
	int 21h

	mov cx, 2
	lea dx, new_line
	mov ah, 40h 
	int 21h

    jmp ask

enter_input:

	mov ah, [enter_counter]
	test ah, ah 
	jnz exit

	inc ah
	mov [enter_counter], ah
	jmp ask
code_seg ends

end start
