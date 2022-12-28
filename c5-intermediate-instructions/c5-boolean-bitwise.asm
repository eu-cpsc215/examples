.DATA

.CODE

AsmBooleanBitwise PROC

push rbp
push rbx
sub rsp, 20h ; Reserve 32-bytes shadow space
lea rbp, [rsp + 20h]

; =========================================================

; Let's look at some examples of assembly instructions for
; bitwise operations.
; ---------------------------------------------------------

; NOT
; ---------------------------------------------------------
mov rax, -1
not rax

; AND
; ---------------------------------------------------------
mov rbx, 20h
not rbx
mov rax, 61h
and rax, rbx      ; 0x61 & 0xDF = 0x41 ('a')

; OR
; ---------------------------------------------------------
mov rax, 41h
or rax, 20h      ; 0x41 | 0x20 = 0x61 ('A')

; XOR
; ---------------------------------------------------------
mov rax, 61h
xor rax, 20h     ; 0x61 ^ 0x20 = 0x41
xor rax, 20h     ; 0x41 ^ 0x20 = 0x61
xor rax, 20h
xor rax, 20h

; Notice what happens when you XOR something by itself
mov rax, 17h
xor rax, rax

; =========================================================

lea rsp, [rbp]
pop rbx
pop rbp
ret

AsmBooleanBitwise ENDP

END
