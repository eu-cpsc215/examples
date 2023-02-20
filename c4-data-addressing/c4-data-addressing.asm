.DATA

; For more about the ALIGN directive, see https://learn.microsoft.com/en-us/cpp/assembler/masm/align-masm?view=msvc-170

var1 BYTE 0FFh
ALIGN 2
var2 BYTE 0FFh
ALIGN 4
var3 WORD 0FFFFh
ALIGN 16
var4 QWORD 0FFFFFFFFFFFFFFFFh

;ALIGN 13		; INVALID - not a power of 2
;ALIGN 32		; INVALID - must be less than or equal to the segment alignment

array1 QWORD 1h, 2h, 3h, 4h, 5h, 0FFFFh

.CODE

_program PROC

push rbp
push rbx

; =========================================================

; Remember there are three types of operands:
; - Immediate/literal (a specific value known at assembly time)
; - Register
; - Memory (a memory address)
;
; MASM will pick the appropriate instruction variation automatically.
; ---------------------------------------------------------
mov rax, 5          ; Immediate
mov rax, rbx        ; Register
mov rax, [var4]     ; Memory

; For memory operands, use [] brackets to specify a memory address.
; ---------------------------------------------------------
push 1234h          ; Push a value onto the stack.
mov rax, rsp        ; Register operand - get the value in the RSP register (stack pointer).
mov rax, [rsp]      ; Memory operand - get the value in memory at the address stored in RSP.

mov rax, 5          ; Immediate operand
;mov rax, [5]       ; Memory operand - this will compile, but 5 will not be a valid address, so a runtime error will happen.

; You can think of a variable as having two components:
;   1) the value of the variable
;   2) the address where the value is stored in memory
;
; Variables in MASM have a unique twist; MASM will imply [] brackets for you.
; View disassembly at runtime for comparison.
; ---------------------------------------------------------
mov rax, [var4]     ; Memory operand - gets value stored in the variable.
mov rax, var4       ; Memory operand - will behave the same as above. [] brackets are implied.

; What if we want to get the address of a variable?
; You can use the OFFSET operator to get the address of a variable:
; https://learn.microsoft.com/en-us/cpp/assembler/masm/operator-offset?view=msvc-170
; ---------------------------------------------------------
mov rax, 0
mov rax, var4           ; Memory operand - result is the VALUE of var4 (the [] brackets are implied).
mov rax, OFFSET var4    ; Immediate operand - result is the ADDRESS of var4 in memory.
mov rax, OFFSET [var4]  ; Immediate operand - result is the ADDRESS of var4 in memory (same as previous instruction).
mov rax, [OFFSET var4]  ; Memory operand - result is the VALUE of var4 (the [] brackets indicate a memory operand).

;mov rax, OFFSET 1      ; INVALID
;mov rax, OFFSET [2]    ; INVALID
;mov rax, OFFSET rbx    ; INVALID
;mov rax, OFFSET [rbx]  ; INVALID

; You can do a limited amount of calculation within the [] brackets to compute an address.
; This is useful for arrays.
; ---------------------------------------------------------
mov rax, [array1]           ; Gets value of first element in array
mov rax, [array1 + 8]       ; Gets value of second element (look at the data type of array1: it's QWORD, so we do a +8 to advance to the next element (QWORD == 64 bits == 8 bytes)
mov rax, [array1 + 16]      ; Gets value of third element
mov rax, [array1 + 3 * 8]   ; Gets value of fourth element

mov rbx, OFFSET array1
mov rax, [rbx]              ; Gets value of first element
mov rax, [rbx + 8]          ; Gets value of second element
mov rax, [rbx + 16]         ; Gets value of third element
mov rcx, 3
mov rax, [rbx + rcx * 8]    ; Gets value of fourth element

mov rax, OFFSET [array1]        ; Gets address of first element
mov rax, [rax]                  ; Gets value of first element
mov rax, OFFSET [array1 + 8]    ; Gets address of second element
mov rax, [rax]                  ; Gets value of second element
mov rax, OFFSET [array1 + 16]   ; Gets address of third element
mov rax, [rax]                  ; Gets value of third element

; There's another way besides MOV+OFFSET to get an address.
; You can also use the LEA (Load Effective Address) instruction.
; https://www.felixcloutier.com/x86/lea
; ---------------------------------------------------------
mov rax, 0
lea rax, [var4]         ; Gets the address of var4 in memory
lea rax, var4           ; Again, this is the same as above. The [] brackets are implied since this is a variable.

; Seems like MOV+OFFSET is the same as LEA, right?
; ---------------------------------------------------------
mov rax, 0
mov rax, OFFSET var4    ; Gets the address of var4 in memory
lea rax, [var4]         ; Gets the address of var4

; Yes! But...
; OFFSET is a MASM operator. It only works when the address is known at assembly/compile time.
; Consider a stack variable.
; ---------------------------------------------------------
push 5678h
push 9876h
lea rax, [rsp]          ; Address that points to value 0x9876 on stack
lea rbx, [rsp + 8]      ; Address that points to value 0x5678 on stack
mov rcx, [rax]          ; Value 0x9876
mov rdx, [rbx]          ; Value 0x5678

;mov rax, OFFSET rsp    ; INVALID - Can't use OFFSET on a register

mov rax, 0
mov rbx, 0
mov rcx, 0
mov rdx, 0

; Equivalent version using just MOV
mov rax, rsp            ; Address that points to value 0x9876 on stack
mov rbx, rsp
add rbx, 8              ; Address that points to value 0x5678 on stack
mov rcx, [rax]          ; Value 0x9876
mov rdx, [rbx]          ; Value 0x5678

; So, what's the difference between MOV and LEA?
; MOV - evalutes [] and gets the value at that address
; LEA - evalutes [] only
; ---------------------------------------------------------
mov rax, 0
lea rax, [array1]       ; First element ADDRESS
mov rax, [array1]       ; First element VALUE
lea rax, [array1 + 8]   ; Second element ADDRESS
mov rax, [array1 + 8]   ; Second element VALUE
lea rax, [array1 + 16]  ; Third element ADDRESS 
mov rax, [array1 + 16]  ; Third element VALUE

; =========================================================

lea rsp, [rsp + 18h] ; pop the three values off the stack that we pushed
pop rbx
pop rbp
ret

_program ENDP

END
