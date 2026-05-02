; пример рисования точки напрямую в видеопамять
; код взят отсюда http://lib.ru/TECHBOOKS/JURDAIN/jourdain.txt - Глава 4.4.2

.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

stack segment para stack
db 65530 dup(?)
stack ends

data segment para public
color db 0
save_mode db ?
index dw 0
data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

include strings.inc

_draw_line_x	proc	near
	push	bp
	mov	bp,sp
	push	si

	xor	si,si
	jmp	short draw_line_x_check
draw_line_x_loop:
	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp+4]
	add	ax,si
	push	ax
	push	word ptr [bp+6]
	call	near ptr _set_dot
	add	sp,6
	inc	si
draw_line_x_check:
	cmp	si,word ptr [bp+8]
	jl	short draw_line_x_loop
	pop	si
	pop	bp
	ret	
_draw_line_x	endp

; ---------------------------------------------------------------------

_draw_line_y	proc	near
	push	bp
	mov	bp,sp
	push	si
	xor	si,si
	jmp	short draw_line_y_check
draw_line_y_loop:
	mov	al,byte ptr [bp+10]
	push	ax
	push	word ptr [bp+4]
	mov	ax,word ptr [bp+6]
	add	ax,si
	push	ax
	call	near ptr _set_dot
	add	sp,6
	inc	si
draw_line_y_check:
	cmp	si,word ptr [bp+8]
	jl	short draw_line_y_loop
	pop	si
	pop	bp
	ret	
_draw_line_y	endp


; void drawpixel(int row, int column, int color)
; рисование пикселя (код цвета в младшем байте аргумента)    
_drawpixel proc near
    push bp
    mov bp, sp
    pusha
	
    mov bh, 0
    mov dx, word ptr [bp + arg1]
    mov cx, word ptr [bp + arg2]
    mov ax, word ptr [bp + arg3]
    mov ah, 0ch
    int 10h
    
	popa
    mov sp, bp
    pop bp
    ret
_drawpixel endp  

; void set_dot(word row, word column, byte color)
; функция рисования пикселя через прямую запись в видеопамять
; ТОЛЬКО ДЛЯ РЕЖИМОВ 4-6	
_set_dot proc near
	push bp
	mov bp, sp
	sub sp, 4*2
	pusha
	
	mov cx, word ptr [bp+arg1]
	test cl,1              ;номер строки нечетный?
	jz   even_row          ;если нет, то вперед
	mov  bx,2000h          ;смещение для нечетных строк
	jmp  short continue    ;переход вперед
even_row:   
	xor bx, bx             ;смещение для четных строк
continue:   
	shr  cx,1              ;делим число строк на 2
	mov  al,80             ;умножаем на 80
	mul  cl                ;в ax - число байтов
;---определяем положение пары бит в байте
	mov dx, word ptr [bp+arg2]
	mov  cx, dx	;копируем номер столбца
	not  cl                ;обращаем биты
	and  cl,00000011b      ;в cl - позиция битов (0-3)
	shl  cl,1              ;позиция первого бита пары	
;---подсчитываем смещение столбца в байтах
	shr  dx,1              ;делим номер столбца на 4
	shr  dx,1              ;(нужны два младших бита)
;---вычисляем смещение для изменяемого байта
	add  ax,dx             ;складываем все три смещения
	add  bx,ax             ;	
;---изменяем биты нужного байта
	mov  ah,es:[bx]        ;читаем нужный байт
	ror  ah,cl             ;сдвигаем нужные биты вниз
	and  ah,11111100b      ;чистим младшие 2 бита
	mov  al,byte ptr [bp+arg3]  ;изменяем их на цвет палетты
	or   ah,al             ;
	rol  ah,cl             ;обратное вращение
	mov  es:[bx], ah        ;возвращаем байт
	
	popa
	mov sp, bp
	pop bp
	ret
_set_dot endp

; void setmode(int mode)
; установка видеорежима (номер режима в младшем байте аргумента)    
_setmode proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 00h
    int 10h
    
    mov sp, bp
    pop bp
    ret
_setmode endp 

; byte getmode()
; получить текущий видеорежим
_getmode proc near
	push bp
	mov bp, sp

	mov ah, 0fh
	int 10h
	
	movzx ax, al

	mov sp, bp
	pop bp
	ret
_getmode endp

_print_window	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	mov	si,word ptr [bp+12]   ; depthFrame
	mov	ax,word ptr [bp+4]    ; xLeftUp
	cmp	ax,word ptr [bp+8]    ; xRightDown
	jge	short exit_invalid
	mov	ax,word ptr [bp+6]    ; yLeftUp
	cmp	ax,word ptr [bp+10]   ; yRightDown
	jge	short exit_invalid
	or	si,si
	jg	short check_depth
exit_invalid:
	jmp	exit
check_depth:
	mov	ax,word ptr [bp+4]    ; xLeftUp
	add	ax,si                 ; +depthFrame
	mov	dx,word ptr [bp+8]    ; xRightDown
	sub	dx,si                 ; -depthFrame
	inc	dx                    ; +1
	cmp	ax,dx
	jg	short exit_depth
	mov	ax,word ptr [bp+6]    ; yLeftUp
	add	ax,si                 ; +depthFrame
	mov	dx,word ptr [bp+10]   ; yRightDown
	sub	dx,si                 ; -depthFrame
	inc	dx
	cmp	ax,dx
	jle	short init_y
exit_depth:
	jmp	short exit
init_y:
	mov	di,word ptr [bp+6]
	jmp	short check_y_loop
y_loop_body:
	mov	ax,word ptr [bp+4]
	mov	word ptr [bp-2],ax
	jmp	short check_x_loop
x_loop_body:
	mov	ax,di                 ; y
	sub	ax,word ptr [bp+6]    ; - yLeftUp
	cmp	ax,si                 ; < depthFrame?
	jl	short border_true
	mov	ax,word ptr [bp+10]   ; yRightDown
	sub	ax,di                 ; - y
	cmp	ax,si
	jl	short border_true
	mov	ax,word ptr [bp-2]    ; x
	sub	ax,word ptr [bp+4]    ; - xLeftUp
	cmp	ax,si
	jl	short border_true
	mov	ax,word ptr [bp+8]    ; xRightDown
	sub	ax,word ptr [bp-2]    ; - x
	cmp	ax,si
	jge	short border_false
border_true:
	mov	ax,1
	jmp	short store_border
border_false:
	xor	ax,ax
store_border:
	mov	byte ptr [bp-3],al
	cmp	byte ptr [bp-3],0
	je	short inside_color
	mov	al,byte ptr [bp+14]   ; frameColor
	jmp	short store_color
inside_color:
	mov	al,byte ptr [bp+16]   ; insideColor
store_color:
	mov	byte ptr [bp-4],al
	mov	al,byte ptr [bp-4]
	push	ax
	push	word ptr [bp-2]       ; x
	push	di                    ; y
	call	near ptr _set_dot
	add	sp,6
	inc	word ptr [bp-2]        ; ++x
check_x_loop:
	mov	ax,word ptr [bp-2]
	cmp	ax,word ptr [bp+8]     ; x <= xRightDown ?
	jle	short x_loop_body
	inc	di                    ; ++y
check_y_loop:
	cmp	di,word ptr [bp+10]    ; y <= yRightDown ?
	jle	short y_loop_body
exit:
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_print_window	endp

_draw_circle	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
	cmp	word ptr [bp+8],0
	jge	short skip_neg_radius
	mov	ax,word ptr [bp+8]
	neg	ax
	mov	word ptr [bp+8],ax
skip_neg_radius:
	mov	ax,word ptr [bp+4]
	mov	word ptr [bp-2],ax

	mov	ax,word ptr [bp+6]
	mov	word ptr [bp-4],ax

	xor	si,si

	mov	di,word ptr [bp+8]

	mov	ax,1
	sub	ax,word ptr [bp+8]
	mov	word ptr [bp-6],ax
	jmp	check_while_cond
while_loop:

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	add	ax,si
	push	ax
	mov	ax,word ptr [bp-4]
	add	ax,di
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	sub	ax,si
	push	ax
	mov	ax,word ptr [bp-4]
	add	ax,di
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	add	ax,si
	push	ax
	mov	ax,word ptr [bp-4]
	sub	ax,di
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	sub	ax,si
	push	ax
	mov	ax,word ptr [bp-4]
	sub	ax,di
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	add	ax,di
	push	ax
	mov	ax,word ptr [bp-4]
	add	ax,si
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	sub	ax,di
	push	ax
	mov	ax,word ptr [bp-4]
	add	ax,si
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	add	ax,di
	push	ax
	mov	ax,word ptr [bp-4]
	sub	ax,si
	push	ax
	call	near ptr _set_dot
	add	sp,6

	mov	al,byte ptr [bp+10]
	push	ax
	mov	ax,word ptr [bp-2]
	sub	ax,di
	push	ax
	mov	ax,word ptr [bp-4]
	sub	ax,si
	push	ax
	call	near ptr _set_dot
	add	sp,6

	inc	si

	cmp	word ptr [bp-6],0
	jge	short d_ge_zero

	mov	ax,si
	jmp	short update_d
d_ge_zero:

	dec	di

	mov	ax,si
	sub	ax,di
update_d:
	shl	ax,1
	inc	ax
	add	word ptr [bp-6],ax
check_while_cond:
	cmp	si,di
	jg	exit_loop
	jmp	while_loop
exit_loop:

	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_draw_circle	endp

_enter	proc	near
	push	bp
	mov	bp,sp
	mov	al,2
	push	ax
	mov	ax,320
	push	ax
	mov	ax,100
	push	ax
	xor	ax,ax
	push	ax
	call	near ptr _draw_line_x
	add	sp,8
   ;	
   ;	    draw_line_y(160, 0, 200, 2);   
   ;	
	mov	al,2
	push	ax
	mov	ax,200
	push	ax
	xor	ax,ax
	push	ax
	mov	ax,160
	push	ax
	call	near ptr _draw_line_y
	add	sp,8
   ;	
   ;	    print_window(10, 5, 50, 20, 3, 2, 1);
   ;	
	mov	al,1
	push	ax
	mov	al,2
	push	ax
	mov	ax,3
	push	ax
	mov	ax,20
	push	ax
	mov	ax,50
	push	ax
	mov	ax,5
	push	ax
	mov	ax,10
	push	ax
	call	near ptr _print_window
	add	sp,14
   ;	
   ;	    draw_circle(160, 100, 30, 2);
   ;	
	mov	al,2
	push	ax
	mov	ax,30
	push	ax
	mov	ax,100
	push	ax
	mov	ax,160
	push	ax
	call	near ptr _draw_circle
	add	sp,8
	pop	bp
	ret	
_enter	endp

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    nop
	
	call _getmode
	mov [save_mode], al
	
	mov dx, 4
    push dx
    call _setmode  
    add sp, 2
	
	mov ax, 0B800H 
	mov es, ax
	;int 3
	xor cx, cx
	xor si, si

    call _enter

	call _getchar
	
	; Возвращаем изначальный видеорежим
    movzx dx, byte ptr [save_mode]
    push dx
    call _setmode
    add sp, 2
    
	
    call _exit0

code ends
end start