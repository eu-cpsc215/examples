; First Program for MASM 64-bit

extrn ExitProcess : proc

.DATA

num QWORD 80
sum QWORD ?

.CODE

_main PROC

sub rax, 28h

mov rax, num
add rax, 20
mov sum, rax
xor rcx, rcx

call ExitProcess

_main ENDP

END
