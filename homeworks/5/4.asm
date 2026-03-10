.386

stack_seg segment para stack 'stack' use16
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data' use16

hex db "0123456789ABCDEF"
space db ' $'
colon db ': $'
new_line db '\n$'
vt db '\v$'
ht db '\t$'

bs db '\b$'
bel db '\a$'
ff db '\f$'
eesc db '\e$'
del db '\d$'                     

return_carriage db '\r$'
nl db 0Dh,0Ah,'$'

save db ?
data_seg ends

code_seg segment para 'code' use16
assume cs:code_seg, ds:data_seg, ss:stack_seg

start:
    mov ax,data_seg
    mov ds,ax

    mov cx,256        
    xor si,si         ; текущий ASCII код
    xor di,di         ; счётчик 8 символов

next_symbol:

    mov ax, si       
    mov al, al       
    mov [save], al

    ; ---- печать символа ----
    jmp check_sym
ret_ch_s:

    mov dl,al
    mov ah,2
    int 21h
    mov dx, offset space
    mov ah,9
    int 21h

    jmp after_char

print_dot:
    mov dl,'.'
    mov ah,2
    int 21h

after_char:

    ; печать ": "
    mov dx,offset colon
    mov ah,9
    int 21h

    mov ax,si
    mov bl,al

    jmp cnv

ret_cnv:

    ; проверка на необходимость пробела после hex
    jmp second_space_check

ret_sp:
    mov dx, offset space
    mov ah,9
    int 21h

    inc si
    inc di

    cmp di,8
    jne no_newline

    mov di,0
    mov dx, offset nl
    mov ah,9
    int 21h

no_newline:
    loop next_symbol

    mov ax,4C00h
    int 21h

second_space_check:
    mov dx, offset space
    mov ah,9
    int 21h
    jmp ret_sp

check_sym:

    cmp al, 0Ah
    je print_new_line

    cmp al, 0Dh
    je print_return_carriage

    cmp al, 07h
    je print_bel
    cmp al, 08h
    je print_bs
    cmp al, 09h
    je print_ht
    cmp al, 0Bh
    je print_vt
    cmp al, 0Ch
    je print_ff
    cmp al, 1Bh
    je print_esc
    cmp al, 7Fh        
    je print_del

    jmp ret_ch_s

cnv:
    ; старшая тетрада
    mov bh,bl
    shr bh,4
    mov bl,bh
    xor bh,bh
    mov dl,hex[bx]
    mov ah,2
    int 21h

    ; младшая тетрада
    mov ax,si
    and al,0Fh
    xor bx,bx
    mov bl,al
    mov dl,hex[bx]
    mov ah,2
    int 21h
    jmp ret_cnv

print_new_line:
    mov dx, offset new_line
    mov ah,9
    int 21h
    jmp after_char
    

print_return_carriage:
    mov dx, offset return_carriage
    mov ah,9
    int 21h
    jmp after_char

print_bel:
    mov dx, offset bel
    mov ah,9
    int 21h
    jmp after_char

print_bs:
    mov dx, offset bs
    mov ah,9
    int 21h
    jmp after_char

print_ht:
    mov dx, offset ht
    mov ah,9
    int 21h
    jmp after_char

print_vt:
    mov dx, offset vt
    mov ah,9
    int 21h
    jmp after_char

print_ff:
    mov dx, offset ff
    mov ah,9
    int 21h
    jmp after_char

print_esc:
    mov dx, offset eesc
    mov ah,9
    int 21h
    jmp after_char

print_del:                          
    mov dx, offset del
    mov ah,9
    int 21h
    jmp after_char


code_seg ends
end start