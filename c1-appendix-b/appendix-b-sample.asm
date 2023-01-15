; First Program for MASM 64-bit

extrn ExitProcess : proc

.DATA

num QWORD 80
sum QWORD ?

.CODE

_main PROC              ; Begin function - main entry point

    sub rsp, 28h        ; Bump 8 bytes to ensure 16 byte alignment. Reserve 32 bytes shadow space.

    mov rax, num
    add rax, 20
    mov sum, rax

    xor rcx, rcx        ; Clear RCX
    call ExitProcess    ; Use Windows API to exit the process

_main ENDP              ; End function

END
