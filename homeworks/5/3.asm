.386
stack_seg segment para stack 'stack' use16
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data' use16
    tens db 0     
    units db 0     
data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:
    mov ax, data_seg
    mov ds, ax

    ; ---------- Левое выравнивание ----------
    mov [tens], 0

outer_loop_left:
    cmp [tens], 9
    jg done_left       ; если >9, выход

    mov [units], 0

inner_loop_left:
    ; Вывод числа в поле шириной 2, выравнивание влево
    cmp [tens], 0
    jne print_tens_left
    ; Однозначное число: печатаем цифру, затем пробел
    mov dl, [units]
    add dl, '0'
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    jmp after_print_left
print_tens_left:
    ; Двузначное число: печатаем десятки и единицы
    mov dl, [tens]
    add dl, '0'
    int 21h
    mov dl, [units]
    add dl, '0'
    int 21h
after_print_left:
    ; Разделительный пробел между числами, если не последнее
    cmp [units], 9
    je skip_space_left
    mov dl, ' '
    int 21h
skip_space_left:
    inc [units]
    cmp [units], 10
    jl inner_loop_left

    ; Конец строки
    mov ah, 02h
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h

    inc [tens]
    jmp outer_loop_left

done_left:

    ; ---------- Правое выравнивание ----------
    mov [tens], 0

outer_loop_right:
    cmp [tens], 9
    jg done_right

    mov [units], 0

inner_loop_right:
    ; Вывод числа в поле шириной 2, выравнивание вправо
    cmp [tens], 0
    jne print_tens_right
	
    mov dl, ' '
    int 21h
    mov dl, [units]
    add dl, '0'
    int 21h
    jmp after_print_right
print_tens_right:
    ; Двузначное число: печатаем десятки и единицы
    mov dl, [tens]
    add dl, '0'
    int 21h
    mov dl, [units]
    add dl, '0'
    int 21h
after_print_right:
    ; Разделительный пробел, если не последнее
    cmp [units], 9
    je skip_space_right
    mov dl, ' '
    int 21h
skip_space_right:
    inc [units]
    cmp [units], 10
    jl inner_loop_right

    ; Конец строки
    mov ah, 02h
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h

    inc [tens]
    jmp outer_loop_right

done_right:
    mov ax, 4C00h
    int 21h

code_seg ends
end start