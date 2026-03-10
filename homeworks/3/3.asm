.8086

stack_seg segment para stack 'stack'
    db 256 dup(?)
stack_seg ends

data_seg segment para 'data'
    msg db 'hello, world!', 0dh, 0ah, '$'

    x sword 2
    y sword 2
    z sword ?

    a sword 2
    b sword 3
    res_c sword 0

data_seg ends

code_seg segment para 'code'
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:  ; initialize ds to point to our data segment
        mov     ax, data_seg
        mov     ds, ax

        ; z = (x*y)/(x+y)
        ; x * y 
        mov     ax, [x]

        imul    [y]      ; ax = x * y

        mov     bx, [x]

        add     bx, [y]  ; bx = x + y

        xor     dx, dx
        idiv    bx 

        mov     [z], ax

        ; c = (a + b) ^ 2
        mov     ax, [a]

        add     ax, [b]  ; ax = a + b

        imul    ax

        mov     [res_c], ax

        ; c = (a + b) ^ 3
        mov     ax, [a]
        add     ax, [b]  ; ax = a + b

        mov     cx, ax
        imul    ax      ; ax = ax * ax = (a+b)^2
        imul    cx      ; ax = cx * ax = (a+b) ^3 

        mov     [res_c], ax

        ; terminate program with return code 0
        mov ax, 4c00h           
        int 21h

code_seg ends

end start
