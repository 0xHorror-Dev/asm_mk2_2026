; Функции для ввода-вывода строк/символов (используется соглашение cdecl)
.386

ACCESS_READ     EQU 0

SEEK_START equ 0
SEEK_CURRENT_POS equ 1
SEEK_END equ 2

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

SHRT_MAX equ 32767
SHRT_MIN equ -32768

stack segment para stack use16
db 65530 dup(?)
stack ends

data segment para public use16

; errors
    ERROR_ALLOC equ 0
    ERROR_OPEN equ 1
    ERROR_LSEEK equ 2

    err_alloc db "failed to allocate memory", 0dh, 0ah, 0
    err_open db "failed to open file", 0dh, 0ah, 0
    err_lseek db "failed to lseek file", 0dh, 0ah, 0
    err_vec dw offset err_alloc, offset err_open, offset err_lseek

    fio_err_no_error        db " ", 0                                ; code 0 (no error, rarely used)
    fio_err_invalid_func    db "Invalid function", 0dh, 0ah, 0      ; code 1
    fio_err_not_found       db "File not found", 0dh, 0ah, 0        ; code 2
    fio_err_path_not_found  db "Path not found", 0dh, 0ah, 0        ; code 3
    fio_err_too_many_open   db "Too many open files", 0dh, 0ah, 0   ; code 4
    fio_err_access_denied   db "Access denied", 0dh, 0ah, 0         ; code 5
    fio_err_invalid_handle  db "Invalid handle", 0dh, 0ah, 0        ; code 6
    fio_err_mcb_destroyed   db "Memory control blocks destroyed", 0dh, 0ah, 0 ; code 7
    fio_err_insufficient_mem db "Insufficient memory", 0dh, 0ah, 0  ; code 8
    fio_err_invalid_mem_block db "Invalid memory block address", 0dh, 0ah, 0 ; code 9
    fio_err_invalid_env     db "Invalid environment", 0dh, 0ah, 0   ; code 10
    fio_err_invalid_format  db "Invalid format", 0dh, 0ah, 0        ; code 11
    fio_err_invalid_access  db "Invalid access code", 0dh, 0ah, 0   ; code 12
    fio_err_invalid_data    db "Invalid data", 0dh, 0ah, 0          ; code 13
    fio_err_reserved        db "Reserved error", 0dh, 0ah, 0        ; code 14
    fio_err_invalid_drive   db "Invalid drive", 0dh, 0ah, 0         ; code 15
    fio_err_remove_cur_dir  db "Cannot remove current directory", 0dh, 0ah, 0 ; code 16
    fio_err_not_same_device db "Not same device", 0dh, 0ah, 0       ; code 17
    fio_err_no_more_files   db "No more files", 0dh, 0ah, 0         ; code 18
    fio_err_write_protected db "Write protected", 0dh, 0ah, 0       ; code 19
    fio_err_unknown_unit    db "Unknown unit", 0dh, 0ah, 0          ; code 20
    fio_err_drive_not_ready db "Drive not ready", 0dh, 0ah, 0       ; code 21
    fio_err_unknown_cmd     db "Unknown command", 0dh, 0ah, 0       ; code 22
    fio_err_crc_error       db "CRC error", 0dh, 0ah, 0             ; code 23
    fio_err_bad_req_len     db "Bad request structure length", 0dh, 0ah, 0 ; code 24
    fio_err_seek_error      db "Seek error", 0dh, 0ah, 0            ; code 25
    fio_err_unknown_media   db "Unknown media type", 0dh, 0ah, 0    ; code 26
    fio_err_sector_not_found db "Sector not found", 0dh, 0ah, 0     ; code 27
    fio_err_printer_out_paper db "Printer out of paper", 0dh, 0ah, 0 ; code 28
    fio_err_invalid_device_req db "Invalid device request", 0dh, 0ah, 0 ; code 29 (returned by read/write on unsuitable device)
    fio_err_read_fault      db "Read fault", 0dh, 0ah, 0            ; code 30
    fio_err_general_failure db "General failure", 0dh, 0ah, 0       ; code 31
    fio_err_unknown         db "Unknown DOS error", 0dh, 0ah, 0     ; for codes >3

    fio_err_vec dw offset fio_err_no_error          ; 0
                dw offset fio_err_invalid_func      ; 1
                dw offset fio_err_not_found         ; 2
                dw offset fio_err_path_not_found    ; 3
                dw offset fio_err_too_many_open     ; 4
                dw offset fio_err_access_denied     ; 5
                dw offset fio_err_invalid_handle    ; 6
                dw offset fio_err_mcb_destroyed     ; 7
                dw offset fio_err_insufficient_mem  ; 8
                dw offset fio_err_invalid_mem_block ; 9
                dw offset fio_err_invalid_env       ; 10
                dw offset fio_err_invalid_format    ; 11
                dw offset fio_err_invalid_access    ; 12
                dw offset fio_err_invalid_data      ; 13
                dw offset fio_err_reserved          ; 14
                dw offset fio_err_invalid_drive     ; 15
                dw offset fio_err_remove_cur_dir    ; 16
                dw offset fio_err_not_same_device   ; 17
                dw offset fio_err_no_more_files     ; 18
                dw offset fio_err_write_protected   ; 19
                dw offset fio_err_unknown_unit      ; 20
                dw offset fio_err_drive_not_ready   ; 21
                dw offset fio_err_unknown_cmd       ; 22
                dw offset fio_err_crc_error         ; 23
                dw offset fio_err_bad_req_len       ; 24
                dw offset fio_err_seek_error        ; 25
                dw offset fio_err_unknown_media     ; 26
                dw offset fio_err_sector_not_found  ; 27
                dw offset fio_err_printer_out_paper ; 28
                dw offset fio_err_invalid_device_req; 29
                dw offset fio_err_read_fault        ; 30
                dw offset fio_err_general_failure   ; 31
;
    

    filename  db "t.txt", 0  ; int 21, 3Dh accept dos string
    error_msg db  "Error: Cannot open or read file", 0

	str1 db 256 dup(?)
	str2 db "Hello, World!", 0

    test_str1       db "Hello", 0
    test_str2       db "Hello, World!", 0
    test_str3       db "world", 0
    test_str4       db 0
    test_str5       db "abc", 0
    test_str6       db "abd", 0
    test_str7       db "ab", 0
    test_str8       db "abcdef", 0
    test_str9       db "cde", 0
    test_buffer     db 256 dup(?)

    test_str_upper db "ABC", 0
    test_str_apple db "apple", 0
    test_str_banana db "BANANA", 

    test_strtos1   db "123",0
    test_strtos2   db "-456",0
    test_strtos3   db "  +789",0
    test_strtos4   db "FF",0
    test_strtos5   db "0x10",0
    test_strtos6   db "077",0
    test_strtos7   db "10",0
    test_strtos8   db "123abc",0
    test_strtos9   db "abc",0
    test_strtos10  db "32767",0
    test_strtos11  db "-32768",0
    test_end_ptr   dw ?


    msg_pass        db " PASS", 13, 10, 0
    msg_fail        db " FAIL", 13, 10, 0
    msg_strlen      db "Testing strlen...", 0
    msg_strchr      db "Testing strchr...", 0
    msg_strstr      db "Testing strstr...", 0
    msg_strcmp      db "Testing strcmp...", 0
    msg_strcpy      db "Testing strcpy...", 0
    msg_stricmp     db "Testing stricmp...", 0
    msg_strtos      db "Testing strtos... ", 0
    msg_strdup      db "Testing strdup...", 0

    msg_loaded_str  db "Loaded string from file t.txt: ", 13, 10, 0
    msg_filed_to_find_delimiter  db "failed to find delimiter '|' in string!", 13, 10, 0

    msg_equal   db 'Strings are equal', 13, 10, 0        ; $ for DOS print, or 0 for C-style
    msg_greater db 'First string is greater', 13, 10, 0
    msg_less    db 'First string is smaller', 13, 10, 0

    msg_equal_ic   db 'Strings are equal (case insensitive)', 13, 10, 0  
    msg_greater_ic db 'First string is greater (case insensitive)',13, 10, 0  
    msg_less_ic    db 'First string is smaller (case insensitive)', 13, 10, 0  

;----
msg_prompt1      db 'Enter path to first file: ',0
msg_prompt2      db 'Enter path to second file: ',0
msg_err_open1    db 'Error opening first file.',0
msg_err_size1    db 'Error getting size of first file.',0
msg_err_read1    db 'Error reading first file.',0
msg_err_open2    db 'Error opening second file.',0
msg_err_size2    db 'Error getting size of second file.',0
msg_err_read2    db 'Error reading second file.',0
msg_diff_count   db 'Warning: files contain different number of tokens.',13,10,0
msg_token_prefix db 'Token ',0


msg_loaded_file1 db 'loaded first file: ',0

msg_loaded_file2 db 'loaded second file: ',0


msg_err_split1 db  'Failed to allocate memory for strings for first file', 0
msg_err_split2 db  'Failed to allocate memory for strings for second file', 0

filename1      db 256 dup(0)
filename2      db 256 dup(0)
empty_str      db 0
msg_colon_space db ': ',0

data ends

code segment para public use16

assume cs:code,ds:data,ss:stack, es:data

public fread 
public InitMem
public AllocMem
public strchr
public strstr
public freadtos

include macro.inc

include strings.inc
include memory.inc
include misc.inc

include io.inc
include fio.inc
include error.inc

include tests.inc

include file_string_test.inc
include file_diff_test.inc

; void test()
; функция для демонстрации работы ввода-вывода
_test proc near
    push bp
    mov bp, sp

    ; ; ввод-вывод символа
    ; call getchar
    
    ; push ax
    ; call putchar
    ; add sp, 2
    
    ; call putnewline
    
    ; ; ввод строки
    ; mov dx, 256
    ; push dx
    ; lea dx,  str1
    ; push dx
    ; call getstr
    ; add sp, 4
    
    ; ; вывод строк
    ; lea dx, str1
    ; push dx
    ; call putstr
    ; add sp, 2

    
    ; lea dx, str2
    ; push dx
    ; call putstr
    ; add sp, 2

    call putnewline

    call test_strtos
    call test_strlen
    call test_strchr
    call test_strstr
    call test_strcmp
    call test_stricmp
    call test_strcpy

    call putnewline

    call _test_file
    call _compare_files

    mov sp, bp
    pop bp
    ret
_test endp
 
start:
    mov ax, data
    mov ds, ax
    mov es, ax
    mov ax, stack
    mov ss, ax
	nop

    push offset end_code_seg
    push cs
    push es
    call InitMem
    add sp, 6 

    call _test
    
    call exit0
end_code_seg:
code ends

end start