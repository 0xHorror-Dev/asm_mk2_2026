.386

stack_seg segment para stack 'stack' use16
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
    num dw 0DBCAh
	new_line db 0dh, 0ah
data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:
    mov ax, data_seg
    mov ds, ax

    mov bx, [num]
    mov cx, 4

print_hex:
    rol bx, 4              ; вращаем влево, чтобы старший полубайт оказался в младших 4 битах
    mov al, bl             
    and al, 0Fh            
    cmp al, 10             
    jl digit               
    add al, 'A' - 10       ; для A-F добавляем смещение
    jmp print_char
digit:
    add al, '0'            ; для 0-9 добавляем код '0'
print_char:
    mov ah, 02h
    mov dl, al
    int 21h
    loop print_hex         ; повторяем для следующего полубайта

	lea dx, new_line
	mov bx, 1
	mov cx, 2
	mov ah, 40h
	int 21h 

    mov ax, 4C00h
    int 21h

code_seg ends
end start