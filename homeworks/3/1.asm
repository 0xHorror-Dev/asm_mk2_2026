.8086

stack_seg segment para stack 'stack'
    db 256 dup(?)
stack_seg ends

data_seg segment para public 'data' 
    first_string_input_array    db  241  ; length
    first_string_input_size     db  0    ; actual size
    first_string_input_buffer   db  241 dup(?) ; buffer

    second_string_input_array   db  241  ; length
    second_string_input_size    db  0    ; actual size
    second_string_input_buffer  db  241 dup(?) ; buffer

    third_string_input_array   db  241  ; length
    third_string_input_size    db  0    ; actual size
    third_string_input_buffer  db  241 dup(?) ; buffer

    new_line                    db 0dh, 0ah

data_seg ends

code_seg segment para public 'code' 
    assume cs:code_seg, ds:data_seg, ss:stack_seg

start:      ; initialize ds to point to our data segment
            mov ax, data_seg
            mov ds, ax
            
            ; read first string 
            lea dx,  first_string_input_array
            mov ah, 0Ah
            int 21h

            lea dx, new_line
            mov bx, 1
            mov cx, 2
            mov ah, 40h
            int 21h 

            ; read second string 
            lea dx,  second_string_input_array
            mov ah, 0Ah
            int 21h

            lea dx, new_line
            mov bx, 1
            mov cx, 2
            mov ah, 40h
            int 21h 

            ; read third string 
            lea dx,  third_string_input_array
            mov ah, 0Ah
            int 21h

            lea dx, new_line
            mov bx, 1
            mov cx, 2
            mov ah, 40h
            int 21h 

            ;print first string
            lea dx, first_string_input_buffer
            mov ah, 40h
            mov cl, [first_string_input_size]
            mov ch, 0h
            mov bx, 1
            int 21h

            lea dx, new_line
            mov bx, 1
            mov cx, 2
            mov ah, 40h
            int 21h 

            ;print second string
            lea dx, second_string_input_buffer
            mov ah, 40h
            mov cl, [second_string_input_size]
            mov ch, 0h
            mov bx, 1
            int 21h

            lea dx, new_line
            mov bx, 1
            mov cx, 2
            mov ah, 40h
            int 21h 

            ;print third string
            lea dx, third_string_input_buffer
            mov ah, 40h
            mov cl, [third_string_input_size]
            mov ch, 0h
            mov bx, 1
            int 21h

            lea dx, new_line
            mov bx, 1
            mov cx, 2
            mov ah, 40h
            int 21h 

            ; terminate program with return code 0
            mov ax, 4c00h           
            int 21h

code_seg ends

end start