.8086

stack_seg segment para stack 'stack'
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data'
    msg db 241 dup(?)
data_seg ends

code_seg segment para 'code'
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:	; initialize ds to point to our data segment
	mov ax, data_seg
	mov ds, ax

	; read from input descriptor
	mov bx, 0
	mov cx, 240
	lea dx, msg
	mov ah, 3Fh
	int 21h		; ax - read len
	
	; write into output descriptor 
	mov cx, ax
	mov bx, 1
	lea dx, msg
	mov ah, 40h 
	int 21h

	; terminate program with return code 0
	mov ax, 4c00h           
	int 21h

code_seg ends

end start
