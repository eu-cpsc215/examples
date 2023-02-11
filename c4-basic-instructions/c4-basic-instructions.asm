extrn ExitProcess : proc

.DATA

var1 QWORD 110
var2 QWORD 10

.CODE

_main PROC

;----------------------------------------------------------

; These are not exhaustive examples.

;----------------------------------------------------------
; MOV
;----------------------------------------------------------

mov rbx, 3          ; Literal to register (value 3 copied into RBX)
mov [var1], 2       ; Literal to memory (value 2 copied into var1)
mov rax, rbx        ; Register to register (RBX copied into RAX)
mov [var1], rbx     ; Register to memory (RBX copied into var1)
mov rbx, [var2]     ; Memory to register (value of var2 copied into RBX)

;mov [var1], [var2] ; INVALID: Memory to memory
;mov rax, ax        ; INVALID: Operands must be the same size

; Observe the behavior of different register sizes

mov rax, 1234567899876543h
mov eax, 11111111h  ; Bits 32-63 cleared

mov rax, 1234567899876543h
mov eax, -12        ; Bits 32-63 cleared (zero extended, not sign extended)

mov rax, 1234567899876543h
mov ax, 1111h       ; No existing bits are cleared

mov rax, 1234567899876543h
mov ah, 11h         ; No existing bits are cleared

mov rax, 1234567899876543h
mov al, 11h         ; No existing bits are cleared

;----------------------------------------------------------
; XCHG
;----------------------------------------------------------

mov rax, 1
mov rbx, 2
mov [var1], 3
mov [var2], 4

xchg rax, rbx       ; Register to register
xchg [var1], rax    ; Register to memory
xchg rbx, [var2]    ; Memory to register

;xchg [var1], [var2]    ; INVALID: Memory to memory

;----------------------------------------------------------
; INC/DEC
;----------------------------------------------------------

mov rax, 0
inc rax
inc rax
dec rax
dec rax

mov [var1], 0
inc [var1]
dec [var1]

mov ax, 0FFFFh
inc ax            ; Wrap around to 0

mov ax, 0
dec ax            ; Wrap around to FFFF

;----------------------------------------------------------
; ADD/SUB
;----------------------------------------------------------

mov rax, 5
mov rbx, 2
mov [var1], 5

add rax, 10         ; Add literal and register (result in register)
add [var1], 10      ; Add literal and memory (result in memory)
add rax, rbx        ; Add register and register
add [var1], rbx     ; Add register and memory (result in memory)

;add [var1], [var2] ; INVALID: Both operands can't be memory
;add 2, rax         ; INVALID: Can't store result in a literal

sub rax, 2          ; (RAX - 2), store result in RAX

;----------------------------------------------------------
; Flags
;----------------------------------------------------------

xor rax, rax    ; Clear rax register

; Zero flag (indicates if result is zero)

add al, 1       ; 0 + 1 = 1, so ZF = 0.
add al, -1      ; 1 + (-1) = 0, so ZF = 1.

; Sign flag (indicates if result is negative)

mov al, 1
sub al, 1       ; 1 - 1 = 0. Not negative, so SF = 0.
sub al, 1       ; 0 - 1 = -1. Negative, so SF = 1.

; Carry flag (indicates unsigned wrap-around)
; - CF = 1 if carry out of most significant bit.
; - CF = 1 if borrow into most significant bit.
; - Otherwise, CF = 0.

mov al, 254     ; Initialize AL (1 byte) with value 11111110 (254).
add al, 1       ; 11111110 + 00000001 = 11111111 (255)    No carry out  bit, so CF = 0
add al, 1       ; 11111111 + 00000001 = 00000000 (0)      Carry into 9th bit, so CF = 1.

mov al, 1       ; Initialize AL (1 byte) with value 00000001 (1).
sub al, 1       ; 00000001 - 00000001 = 00000000 (0)      No borrow from 9th bit, so CF = 0.
sub al, 1       ; 00000000 - 00000001 = 11111111 (255)    Borrow from 9th bit, so CF = 1.

; Overflow flag (indicates signed wrap-around)
; - OF = 1 if result wraps around the signed boundary

mov al, 126     ; Remember: The signed range of 1 byte is [-128, 127].
add al, 1       ; 01111110 + 00000001 = 01111111 (127)     Still within signed range, so OF = 0.
add al, 1       ; 01111111 + 00000001 = 10000000 (-128)    Wrapped around signed range, so OF = 1.

mov al, -127    ; Remember: The signed range of 1 byte is [-128, 127].
sub al, 1       ; 10000001 - 00000001 = 10000000 (-128)    Still within signed range, so OF = 0.
sub al, 1       ; 10000000 - 00000001 = 01111111 (127)     Wrapped around signed range, so OF = 1.

;----------------------------------------------------------
; NEG
;----------------------------------------------------------

mov rax, -1

neg rax
neg rax

;----------------------------------------------------------
; MUL
;----------------------------------------------------------

; RAX is multiplicand
; Operand is multiplier
; Product stored in RDX:RAX (high bits in RDX, low bits in RAX)

mov rax, 10
mov rbx, 2
mul rbx

mov rax, 98765432100
mov [var1], 987654321
mul [var1]

;mul 2          ; INVALID: Can't use immediate operand (literal)

;----------------------------------------------------------
; IMUL
;----------------------------------------------------------

; Signed multiplication. Has three variations.

; One-operand (similar to unsigned MUL)
; -------------------------------------
mov rax, 10
mov rbx, -2
imul rbx

mov rax, -10
mov [var1], 2
imul [var1]

; Two-operand (destination, source)
; -------------------------------------
mov var1, 2
mov rax, 2
imul rax, -2        ; immediate * register
imul rax, rax       ; register * register
imul rax, [var1]    ; memory * register

;imul [var1], rax   ; INVALID: memory can't be destination
;imul 2, rax        ; INVALID: immediate can't be destination

; Three-operand (destination, source, immediate)
; -------------------------------------
mov [var1], 2
mov rax, 2
imul rbx, rax, -2       ; register source
imul rbx, [var1], -2    ; memory source

;imul [var1], rbx, 2    ; INVALID: memory can't be destination
;imul rbx, rax, rcx     ; INVALID: last operand must be immediate
;imul rbx, rax, [var1]  ; INVALID: last operand must be immediate

; Compare MUL (unsigned) to IMUL (signed)
; -------------------------------------
xor rax, rax
xor rbx, rbx
xor rdx, rdx

mov al, 2
mov bl, -2
mul bl         ; 2 * -2 = 2 * 254 = 508 = 0000 0001 : 1111 1100

mov al, 2
mov bl, -2
imul bl        ; 2 * -2 =            -4 = 1111 1111 : 1111 1100

mov al, 2
mov bl, 254
imul bl        ; 2 * -2 =            -4 = 1111 1111 : 1111 1100

;----------------------------------------------------------
; DIV
;----------------------------------------------------------

; RDX:RAX is the dividend (high bits in RDX, low in RAX)
; Operand is divisor
; Quotient stored in RAX
; Remainder stored in RDX

mov rdx, 0
mov rax, 11
mov rcx, 2
div rcx     ; Use register as divisor, rax will contain quotient, rdx remainder

mov rdx, 412
mov rax, 9876543
mov [var1], 1234
div [var1]

;div 2      ; INVALID: can't use immediate

; This example will cause integer overflow
;mov rdx, 4124123
;mov rax, 98765432100
;mov rcx, 1234
;div rcx

; This example will cause a divide-by-zero exception
;mov rdx, 0
;mov rax, 12
;mov rcx, 0
;div rcx

;----------------------------------------------------------
; IDIV
;----------------------------------------------------------

; Signed division. Same as regular DIV. Unlike IMUL, only has the one-operand format.

mov rdx, 0
mov rax, 11
mov rcx, -2
idiv rcx

;----------------------------------------------------------
; SHL/SHR
;----------------------------------------------------------

; Logical bit shifting
; Last bit lost moves to carry flag (CF)
; New bits filled with 0

mov rax, 1
shl rax, 1      ; 1 * (2^1) = 1 * 2 = 2
shl rax, 1      ; 2 * (2^1) = 2 * 2 = 4
shl rax, 2      ; 4 * (2^2) = 4 * 4 = 16
shr rax, 1      ; 16 / (2^1) = 16 / 2 = 8
shr rax, 3      ; 8 / (2^3) = 8 / 8 = 1

;shr rax, rax	; INVALID: last operand must be immediate value

; Observe carry flag as bits are shifted out of the bounds of the register BX (16-bit)
mov rbx, 0
mov bx, 1010101010101010b
shl bx, 1       ; Carry flag will be 1
shl bx, 1       ; Carry flag will be 0
shl bx, 1       ; Carry flag will be 1
shl bx, 1       ; Carry flag will be 0

;----------------------------------------------------------
; SAL/SAR
;----------------------------------------------------------

; Arithmetic bit shifting
; Preserves the sign (allows multiplication or division of signed ints)
; "Shift Arithmetic Left"/"Shift Arithmetic Right"
; Note that SAL and SHL are identical

mov rax, -1
sal rax, 1      ; -1 * (2^1) = -1 * 2 = -2
sal rax, 3      ; -2 * (2^3) = -2 * 8 = -16
sar rax, 1      ; -16 / (2^1) = -16 / 2 = -8
sar rax, 2      ; -8 / (2^2) = -8 / 4 = -2

;----------------------------------------------------------
; CBW/CWD/CDQ/CQO
;----------------------------------------------------------

; Sign extension - fills high order half with the value of the leading bit of the low order half

; CBW - Convert BYTE to WORD (al -> ax)
mov rax, 0
mov al, -2
cbw

; CWD - Convert WORD to DWORD (ax -> dx:ax)
mov rax, 0
mov rdx, 0
mov ax, -2
cwd

; CDQ - Convert DWORD to QWORD (eax -> edx:eax)
mov rax, 0
mov rdx, 0
mov eax, -2
cdq

; CQO - Convert QWORD to OCTA (rax -> rdx:rax)
mov rax, 0
mov rdx, 0
mov rax, -2
cqo

;----------------------------------------------------------

xor rcx, rcx
call ExitProcess

_main ENDP

END
