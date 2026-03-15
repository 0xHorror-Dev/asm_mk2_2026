.386

stack_seg segment para stack 'stack' use16
    db 65500 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
crc16_table dw 0000h, 1021h, 2042h, 3063h, 4084h, 50A5h, 60C6h, 70E7h, \
8108h, 9129h, 0A14Ah, 0B16Bh, 0C18Ch, 0D1ADh, 0E1CEh, 0F1EFh,
1231h, 0210h, 3273h, 2252h, 52B5h, 4294h, 72F7h, 62D6h,
9339h, 8318h, 0B37Bh, 0A35Ah, 0D3BDh, 0C39Ch, 0F3FFh, 0E3DEh,
2462h, 3443h, 0420h, 1401h, 64E6h, 74C7h, 44A4h, 5485h,
0A56Ah, 0B54Bh, 8528h, 9509h, 0E5EEh, 0F5CFh, 0C5ACh, 0D58Dh
 dw 3653h, 2672h, 1611h, 0630h, 76D7h, 66F6h, 5695h, 46B4h,
0B75Bh, 0A77Ah, 9719h, 8738h, 0F7DFh, 0E7FEh, 0D79Dh, 0C7BCh,
48C4h, 58E5h, 6886h, 78A7h, 0840h, 1861h, 2802h, 3823h,
0C9CCh, 0D9EDh, 0E98Eh, 0F9AFh 
 dw 8948h, 9969h, 0A90Ah, 0B92Bh,
5AF5h, 4AD4h, 7AB7h, 6A96h, 1A71h, 0A50h, 3A33h, 2A12h,
0DBFDh, 0CBDCh, 0FBBFh, 0EB9Eh, 9B79h, 8B58h, 0BB3Bh, 0AB1Ah,
6CA6h, 7C87h, 4CE4h, 5CC5h, 2C22h, 3C03h, 0C60h, 1C41h,
0EDAEh, 0FD8Fh, 0CDECh, 0DDCDh, 0AD2Ah, 0BD0Bh, 8D68h, 9D49h
 dw 7E97h, 6EB6h, 5ED5h, 4EF4h, 3E13h, 2E32h, 1E51h, 0E70h,
0FF9Fh, 0EFBEh, 0DFDDh, 0CFFCh, 0BF1Bh, 0AF3Ah, 9F59h, 8F78h,
9188h, 81A9h, 0B1CAh, 0A1EBh, 0D10Ch, 0C12Dh, 0F14Eh, 0E16Fh,
1080h, 00A1h, 30C2h, 20E3h, 5004h, 4025h, 7046h, 6067h,
83B9h, 9398h, 0A3FBh, 0B3DAh, 0C33Dh, 0D31Ch, 0E37Fh, 0F35Eh
 dw 02B1h, 1290h, 22F3h, 32D2h, 4235h, 5214h, 6277h, 7256h,
0B5EAh, 0A5CBh, 95A8h, 8589h, 0F56Eh, 0E54Fh, 0D52Ch, 0C50Dh,
34E2h, 24C3h, 14A0h, 0481h, 7466h, 6447h, 5424h, 4405h,
0A7DBh, 0B7FAh, 8799h, 97B8h, 0E75Fh, 0F77Eh, 0C71Dh, 0D73Ch
 dw 26D3h, 36F2h, 0691h, 16B0h, 6657h, 7676h, 4615h, 5634h,
0D94Ch, 0C96Dh, 0F90Eh, 0E92Fh, 99C8h, 89E9h, 0B98Ah, 0A9ABh,
5844h, 4865h, 7806h, 6827h, 18C0h, 08E1h, 3882h, 28A3h,
0CB7Dh, 0DB5Ch, 0EB3Fh, 0FB1Eh, 8BF9h, 9BD8h, 0ABBBh, 0BB9Ah
 dw 4A75h, 5A54h, 6A37h, 7A16h, 0AF1h, 1AD0h, 2AB3h, 3A92h,
0FD2Eh, 0ED0Fh, 0DD6Ch, 0CD4Dh, 0BDAAh, 0AD8Bh, 9DE8h, 8DC9h,
7C26h, 6C07h, 5C64h, 4C45h, 3CA2h, 2C83h, 1CE0h, 0CC1h,
0EF1Fh, 0FF3Eh, 0CF5Dh, 0DF7Ch, 0AF9Bh, 0BFBAh, 8FD9h, 9FF8h,
6E17h, 7E36h, 4E55h, 5E74h, 2E93h, 3EB2h, 0ED1h, 1EF0h


Crc32Table DD 00000000h, 077073096h, 0EE0E612Ch, 0990951BAh
    DD 0076DC419h, 0706AF48Fh, 0E963A535h, 09E6495A3h
    DD 0EDB8832h, 079DCB8A4h, 0E0D5E91Eh, 097D2D988h
    DD 09B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
    DD 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh
    DD 01ADAD47Dh, 06DDDE4EBh, 0F4D4B551h, 083D385C7h
    DD 0136C9856h, 0646BA8C0h, 0FD62F97Ah, 08A65C9ECh
    DD 014015C4Fh, 063066CD9h, 0FA0F3D63h, 08D080DF5h
    DD 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h
    DD 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh
    DD 035B5A8FAh, 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h
    DD 032D86CE3h, 045DF5C75h, 0DCD60DCFh, 0ABD13D59h
    DD 026D930ACh, 051DE003Ah, 0C8D75180h, 0BFD06116h
    DD 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
    DD 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h
    DD 02F6F7C87h, 058684C11h, 0C1611DABh, 0B6662D3Dh
    DD 076DC4190h, 001DB7106h, 098D220BCh, 0EFD5102Ah
    DD 071B18589h, 006B6B51Fh, 09FBFE4A5h, 0E8B8D433h
    DD 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h
    DD 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h
    DD 06B6B51F4h, 01C6C6162h, 0856530D8h, 0F262004Eh
    DD 06C0695EDh, 01B01A57Bh, 08208F4C1h, 0F50FC457h
    DD 065B0D9C6h, 012B7E950h, 08BBEB8EAh, 0FCB9887Ch
    DD 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
    DD 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h
    DD 04ADFA541h, 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh
    DD 04369E96Ah, 0346ED9FCh, 0AD678846h, 0DA60B8D0h
    DD 044042D73h, 033031DE5h, 0AA0A4C5Fh, 0DD0D7CC9h
    DD 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h
    DD 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh
    DD 05EDEF90Eh, 029D9C998h, 0B0D09822h, 0C7D7A8B4h
    DD 059B33D17h, 02EB40D81h, 0B7BD5C3Bh, 0C0BA6CADh
    DD 0EDB88320h, 09ABFB3B6h, 003B6E20Ch, 074B1D29Ah
    DD 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
    DD 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h
    DD 0E40ECF0Bh, 09309FF9Dh, 00A00AE27h, 07D079EB1h
    DD 0F00F9344h, 08708A3D2h, 01E01F268h, 06906C2FEh
    DD 0F762575Dh, 0806567CBh, 0196C3671h, 06E6B06E7h
    DD 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh
    DD 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h
    DD 0D6D6A3E8h, 0A1D1937Eh, 038D8C2C4h, 04FDFF252h
    DD 0D1BB67F1h, 0A6BC5767h, 03FB506DDh, 048B2364Bh
    DD 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h, 041047A60h
    DD 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
    DD 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h
    DD 0CC0C7795h, 0BB0B4703h, 0220216B9h, 05505262Fh
    DD 0C5BA3BBEh, 0B2BD0B28h, 02BB45A92h, 05CB36A04h
    DD 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh, 05BDEAE1Dh
    DD 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah
    DD 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h
    DD 095BF4A82h, 0E2B87A14h, 07BB12BAEh, 00CB61B38h
    DD 092D28E9Bh, 0E5D5BE0Dh, 07CDCEFB7h, 00BDBDF21h
    DD 086D3D2D4h, 0F1D4E242h, 068DDB3F8h, 01FDA836Eh
    DD 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
    DD 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch
    DD 08F659EFFh, 0F862AE69h, 0616BFFD3h, 0166CCF45h
    DD 0A00AE278h, 0D70DD2EEh, 04E048354h, 03903B3C2h
    DD 0A7672661h, 0D06016F7h, 04969474Dh, 03E6E77DBh
    DD 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h
    DD 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h
    DD 0BDBDF21Ch, 0CABAC28Ah, 053B39330h, 024B4A3A6h
    DD 0BAD03605h, 0CDD70693h, 054DE5729h, 023D967BFh
    DD 0B3667A2Eh, 0C4614AB8h, 05D681B02h, 02A6F2B94h
    DD 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh

input_string db 255 dup(?)

crc16_output_prefix db "CRC16:", '$'
crc32_output_prefix db "CRC32:", '$'

data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg


; bx - string pointer
; cx - string len
; dx - result 
crc16_ccitt:
    push si
    push ax
    push di

    mov dx, 0FFFFh

    test cx, cx 
    jz crc16_ccitt_exit    
crc16_ccitt_loop:
    push dx
    ;(*pcBlock++)
    mov al, byte ptr [bx]
    inc bx
    xor ah, ah

    ; crc >> 8
    shr dx, 8 

    ;(crc >> 8) ^ (*pcBlock++)
    xor ax, dx
    mov si, ax

    ; * sizeof(short)
    shl si, 1 
    
    ; Crc16Table[ (crc >> 8) ^ (*pcBlock++) ] 
    mov di, word ptr [crc16_table+si]

    ; restore crc
    pop dx
    ; crc << 8
    shl dx, 8

    ;  ( (crc << 8) ^ Crc16Table[ (crc >> 8) ^ (*pcBlock++) ] );
    xor dx, di 

    loop crc16_ccitt_loop

crc16_ccitt_exit:
    pop di
    pop ax
    pop si
    
    ret

; si - string pointer
; cx - string len
; ax:di - result
crc32:
    test cx, cx 
    jz crc32_exit_zero

    ; crc = FFFFFFFFh
    mov ax, 0FFFFh
    mov di, 0FFFFh

crc32_loop:
    xor bx, bx
    ; val = *buff++
    mov bl, byte ptr [si]
    inc si
    ; c2 = val = val ^ c1 
    xor bl, al

    ; c3 = c2 & FFh
    and bl, 0FFh

    ; c4 = Crc32Table[c3];
    xor bh, bh
    shl bx, 2

    ; c1 = (crc >> 8)
    shrd ax, di, 8
    shr di, 8

    ;  c1 ^ c4
    mov dx, word ptr [Crc32Table+bx]
    xor ax, dx
    mov dx, word ptr [Crc32Table+bx+2]
    xor di, dx

    loop crc32_loop

    xor ax, 0FFFFh
    xor di, 0FFFFh
crc32_exit:
    ret

crc32_exit_zero:
    xor ax, ax
    xor di, di
    ret

; bx - number
print_hex:
    push cx
    push ax

    mov cx, 4

print_hex_loop:
    rol bx, 4 
    mov al, bl 
    and al, 0Fh 
    cmp al, 10  
    jl digit    
    add al, 'A' - 10
    jmp print_char
digit:
    add al, '0'
print_char:
    mov ah, 02h
    mov dl, al
    pusha
    int 21h
    popa
    loop print_hex_loop


    pop ax
    pop cx
    
    ret

start:

    ; initialize ds to point to our data segment
    mov ax, data_seg
    mov ds, ax

    mov ax, stack_seg
    mov ss, ax 

    mov bx, 0 
    mov cx, 254 
    lea dx, [input_string]
    mov ah, 3Fh 
    int 21h
    sub ax, 2
    push ax

    lea bx, [input_string]
    mov cx, ax
    call crc16_ccitt
    mov bx, dx

    lea dx, [crc16_output_prefix]
    mov ah, 09h 
    int 21h

    call print_hex

    mov dl, 0Dh
    mov ah, 02h
    int 21h

    mov dl, 0Ah
    mov ah, 02h
    int 21h

    pop ax 
    lea si, [input_string]
    mov cx, ax
    call crc32

    push ax
    push di
    lea dx, [crc32_output_prefix]
    mov ah, 09h
    int 21h
    pop di
    pop ax

    mov bx, di
    call print_hex

    mov bx, ax
    call print_hex


    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah      
    int 21h


    nop ; debugger

    ; terminate program with return code 0
    mov ax, 4c00h           
    int 21h

code_seg ends

end start
