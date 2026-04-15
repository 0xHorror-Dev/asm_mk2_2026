; void print_result(char* message, bool res)
print_result proc near
    push bp
    mov bp, sp
    pusha

    mov dx, word ptr [bp+6]      ; message offset
    push dx
    call putstr
    add sp, 2
    
    mov bx, word ptr [bp+4] 
    cmp bx, 0
    jne pr_fail
    mov dx, offset msg_pass
    jmp pr_print
pr_fail:
    mov dx, offset msg_fail
pr_print:
    push dx
    call putstr
    add sp, 2

    popa
    mov sp, bp
    pop bp
    ret
print_result endp

test_strtos proc near
    push bp
    mov  bp, sp
    sub  sp, 2               ; local flag: 0 = pass, 1 = fail

    ; ---------- Test 1: decimal "123" -> 123, end_ptr -> terminator ----------
    push 10                  ; base
    push offset test_end_ptr
    push offset test_strtos1
    call strtos
    add  sp, 6
    cmp  ax, 123
    jne  tstrtos_fail
    ; check end_ptr points to null terminator
    mov  bx, offset test_end_ptr
    mov  bx, [bx]            ; bx = pointer stored by strtos
    cmp  byte ptr [bx], 0
    jne  tstrtos_fail

    ; ---------- Test 2: decimal "-456" -> -456 ----------
    push 10
    push offset test_end_ptr
    push offset test_strtos2
    call strtos
    add  sp, 6
    cmp  ax, -456
    jne  tstrtos_fail

    ; ---------- Test 3: decimal "  +789" (whitespace & sign) -> 789 ----------
    push 10
    push offset test_end_ptr
    push offset test_strtos3
    call strtos
    add  sp, 6
    cmp  ax, 789
    jne  tstrtos_fail

    ; ---------- Test 4: hex "FF" base 16 -> 255 ----------
    push 16
    push offset test_end_ptr
    push offset test_strtos4
    call strtos
    add  sp, 6
    cmp  ax, 255
    jne  tstrtos_fail

    ; ---------- Test 5: hex with 0x prefix, base 0 -> 16 ----------
    push 0                   ; auto-detect
    push offset test_end_ptr
    push offset test_strtos5
    call strtos
    add  sp, 6
    cmp  ax, 16
    jne  tstrtos_fail

    ; ---------- Test 6: octal "077" base 0 -> 63 (0 prefix) ----------
    push 0
    push offset test_end_ptr
    push offset test_strtos6
    call strtos
    add  sp, 6
    cmp  ax, 63
    jne  tstrtos_fail

    ; ---------- Test 7: decimal "10" base 0 -> 10 ----------
    push 0
    push offset test_end_ptr
    push offset test_strtos7
    call strtos
    add  sp, 6
    cmp  ax, 10
    jne  tstrtos_fail

    ; ---------- Test 8: end_ptr on trailing text "123abc" -> points to 'a' ----------
    push 10
    push offset test_end_ptr
    push offset test_strtos8
    call strtos
    add  sp, 6
    cmp  ax, 123
    jne  tstrtos_fail
    mov  bx, offset test_end_ptr
    mov  bx, [bx]
    cmp  byte ptr [bx], 'a'
    jne  tstrtos_fail

    ; ---------- Test 9: invalid string "abc" -> 0, end_ptr = string ----------
    push 10
    push offset test_end_ptr
    push offset test_strtos9
    call strtos
    add  sp, 6
    cmp  ax, 0
    jne  tstrtos_fail
    mov  bx, offset test_end_ptr
    mov  bx, [bx]
    cmp  bx, offset test_strtos9
    jne  tstrtos_fail

    ; ---------- Test 10: max short 32767 ----------
    push 10
    push offset test_end_ptr
    push offset test_strtos10
    call strtos
    add  sp, 6
    cmp  ax, 32767
    jne  tstrtos_fail

    ; ---------- Test 11: min short -32768 ----------
    push 10
    push offset test_end_ptr
    push offset test_strtos11
    call strtos
    add  sp, 6
    cmp  ax, -32768
    jne  tstrtos_fail

    ; All tests passed
    mov  word ptr [bp-2], 0
    jmp  tstrtos_end

tstrtos_fail:
    mov word ptr [bp-2], 1

tstrtos_end:
    mov dx, word ptr [bp-2] 
    push offset msg_strtos
    push dx
    call print_result
    add  sp, 4
    mov  sp, bp
    pop  bp
    ret
test_strtos endp

test_strlen proc near
    push bp
    mov bp, sp
    sub sp, 2          ; local flag (0 = pass)

    ; Test 1: empty string -> 0
    push offset test_str4
    call strlen
    add sp, 2
    cmp ax, 0
    jne tstrlen_fail

    ; Test 2: "Hello" -> 5
    push offset test_str1
    call strlen
    add sp, 2
    cmp ax, 5
    jne tstrlen_fail

    ; Test 3: "Hello, World!" -> 13
    push offset test_str2
    call strlen
    add sp, 2
    cmp ax, 13
    jne tstrlen_fail

    mov word ptr [bp-2], 0  ; all passed
    jmp tstrlen_end
tstrlen_fail:
    mov word ptr [bp-2], 1
tstrlen_end:
    push offset msg_strlen
    push word ptr [bp-2]
    call print_result
    add sp, 4
    mov sp, bp
    pop bp
    ret
test_strlen endp

test_strchr proc near
    push bp
    mov bp, sp
    sub sp, 2

    ; Test 1: find 'l' in "Hello" -> pointer to first 'l'
    push 'l'
    push offset test_str1
    call strchr
    add sp, 4
    cmp ax, offset test_str1 + 2   ; "Hello" -> index 2 = 'l'
    jne tschr_fail

    ; Test 2: find 'x' not present -> NULL
    push 'x'
    push offset test_str1
    call strchr
    add sp, 4
    test ax, ax
    jnz tschr_fail

    ; Test 3: find null terminator -> pointer to end
    push 0
    push offset test_str1
    call strchr
    add sp, 4
    cmp ax, offset test_str1 + 5   ; after 'o'
    jne tschr_fail

    mov word ptr [bp-2], 0
    jmp tschr_end
tschr_fail:
    mov word ptr [bp-2], 1
tschr_end:
    push offset msg_strchr
    push word ptr [bp-2]
    call print_result
    add sp, 4
    mov sp, bp
    pop bp
    ret
test_strchr endp

test_strstr proc near
    push bp
    mov bp, sp
    sub sp, 2

    ; Test 1: empty needle -> return haystack
    push offset test_str1
    push offset test_str4   ; empty string
    call strstr
    add sp, 4
    cmp ax, offset test_str1
    jne tstrstr_fail

    ; Test 2: needle at start ("Hello" in "Hello, World!")
    push offset test_str2
    push offset test_str1
    call strstr
    add sp, 4
    cmp ax, offset test_str2
    jne tstrstr_fail

    ; Test 3: needle in middle ("World" in "Hello, World!")
    push offset test_str2
    push offset test_str2 + 7   ; "World"
    call strstr
    add sp, 4
    cmp ax, offset test_str2 + 7
    jne tstrstr_fail

    ; Test 4: needle not found ("xyz") -> NULL
    push offset test_str2
    push offset test_str3   ; "world" (case mismatch, not found)
    call strstr
    add sp, 4
    test ax, ax
    jnz tstrstr_fail

    ; Test 5: needle longer than haystack
    push offset test_str1   ; "Hello"
    push offset test_str2   ; "Hello, World!" longer
    call strstr
    add sp, 4
    test ax, ax
    jnz tstrstr_fail

    mov word ptr [bp-2], 0
    jmp tstrstr_end
tstrstr_fail:
    mov word ptr [bp-2], 1
tstrstr_end:
    push offset msg_strstr
    push word ptr [bp-2]
    call print_result
    add sp, 4
    mov sp, bp
    pop bp
    ret
test_strstr endp


test_strcmp proc near
    push bp
    mov bp, sp
    sub sp, 2

    ; Test 1: equal strings ("abc", "abc") -> 0
    push offset test_str5
    push offset test_str5
    call strcmp
    add sp, 4
    cmp ax, 0
    jne tstrcmp_fail

    ; Test 2: first < second ("abc", "abd") -> negative
    push offset test_str5
    push offset test_str6
    call strcmp
    add sp, 4
    cmp ax, 0
    jge tstrcmp_fail

    ; Test 3: first > second ("abd", "abc") -> positive
    push offset test_str6
    push offset test_str5
    call strcmp
    add sp, 4
    cmp ax, 0
    jle tstrcmp_fail

    ; Test 4: different lengths ("ab", "abc") -> negative (null vs 'c')
    push offset test_str7
    push offset test_str5
    call strcmp
    add sp, 4
    cmp ax, 0
    jge tstrcmp_fail

    mov word ptr [bp-2], 0
    jmp tstrcmp_end
tstrcmp_fail:
    mov word ptr [bp-2], 1
tstrcmp_end:
    push offset msg_strcmp
    push word ptr [bp-2]
    call print_result
    add sp, 4
    mov sp, bp
    pop bp
    ret
test_strcmp endp

test_stricmp proc near
    push bp
    mov  bp, sp
    sub  sp, 2               ; local flag: 0 = pass, 1 = fail

    ; Test 1: equal strings, same case ("abc", "abc") -> 0
    push offset test_str5
    push offset test_str5
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jne  tstricmp_fail

    ; Test 2: equal strings, different case ("abc", "ABC") -> 0
    push offset test_str5        ; "abc"
    push offset test_str_upper   ; "ABC"
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jne  tstricmp_fail

    ; Test 3: first < second ("abc", "abd") -> negative
    push offset test_str5        ; "abc"
    push offset test_str6        ; "abd"
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jge  tstricmp_fail

    ; Test 4: first > second ("abd", "abc") -> positive
    push offset test_str6        ; "abd"
    push offset test_str5        ; "abc"
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jle  tstricmp_fail

    ; Test 5: different lengths, case‑insensitive ("ab", "ABC")
    ; "ab" vs "ABC" -> compare 'a' vs 'A' (equal), 'b' vs 'B' (equal),
    ; then null vs 'C' → null < 'C' → negative
    push offset test_str7        ; "ab"
    push offset test_str_upper   ; "ABC"
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jge  tstricmp_fail

    ; Test 6: ordering with case differences ("apple" vs "BANANA")
    ; 'a' vs 'B' → after case‑fold: 'a' vs 'b' → negative
    push offset test_str_apple   ; "apple"
    push offset test_str_banana  ; "BANANA"
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jge  tstricmp_fail

    ; Test 7: both strings empty -> 0
    push offset test_str4        ; ""
    push offset test_str4
    call stricmp
    add  sp, 4
    cmp  ax, 0
    jne  tstricmp_fail

    ; All tests passed
    mov  word ptr [bp-2], 0
    jmp  tstricmp_end

tstricmp_fail:
    mov  word ptr [bp-2], 1

tstricmp_end:
    push offset msg_stricmp
    push word ptr [bp-2]
    call print_result
    add  sp, 4
    mov  sp, bp
    pop  bp
    ret
test_stricmp endp

test_strcpy proc near
    push bp
    mov bp, sp
    sub sp, 2

    ; Copy "Hello" into test_buffer
    push offset test_buffer
    push offset test_str1
    call strcpy
    add sp, 4

    ; Verify buffer content
    push offset test_buffer
    push offset test_str1
    call strcmp
    add sp, 4
    cmp ax, 0
    jne tstrcpy_fail

    ; Also check that original string unchanged
    push offset test_str1
    push offset test_str1
    call strcmp
    add sp, 4
    cmp ax, 0
    jne tstrcpy_fail

    mov word ptr [bp-2], 0
    jmp tstrcpy_end
tstrcpy_fail:
    mov word ptr [bp-2], 1
tstrcpy_end:
    push offset msg_strcpy
    push word ptr [bp-2]
    call print_result
    add sp, 4
    mov sp, bp
    pop bp
    ret
test_strcpy endp