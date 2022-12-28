extern GetInt : proc

.DATA

.CODE

AsmBranching PROC

push rbp
push rbx
sub rsp, 20h ; Reserve 32-bytes shadow space
lea rbp, [rsp + 20h]

; =========================================================

; Unconditional jumps
; ---------------------------------------------------------
mov rax, 1
jmp thisIsALabel
mov rax, 2		; This instruction is never executed

thisIsALabel:
mov rax, 3

; Conditional jumps
; We need to be able to perform a test and choose the appropriate
; code path to execute based on the result (IF/ELSE).
;
; Achieving this in assembly requires two steps:
; - Peform the test.
; - Jump to the appropriate next instruction.
;
; We'll look at two instructions for doing a conditional test.
; Then we'll look at conditional jump instructions.
; The test instructions will affect the flags register.
; The jump instructions will look at the flags register to determine what to do.
;
; List of common flags: https://www.intel.com/content/dam/develop/external/us/en/documents/introduction-to-x64-assembly-181178.pdf
; Viewing flags in Visual Studio: https://learn.microsoft.com/en-us/visualstudio/debugger/debugging-basics-registers-window?view=vs-2022#register-flags
; ---------------------------------------------------------

; TEST - Implied AND (bitwise) - (observe that destination is not updated, only flags are)
mov rax, 1
test rax, 0		; 1 AND 0 = 0 (Zero = 1, Sign = 0, Parity = 1)
test rax, 1		; 1 AND 1 = 1 (Zero = 0, Sign = 0, Parity = 0)
test rax, 5		; 1 AND 5 = 1 (Zero = 0, Sign = 0, Parity = 0)
mov rax, -16
test rax, 1		; -16 AND 1 = 0 (Parity = 1, Zero = 1, Sign = 0)
test rax, -16	; -16 AND -16 = -16 (Parity = 1, Zero = 0, Sign = 1)
and rax, 1		; notice RAX is updated with result in addition to setting flags

; CMP - Implied SUB (again, destination not updated, only flags)
mov rax, 5
cmp rax, 5		; 5 - 5 = 0  (Zero = 1, Sign = 0, Parity = 1)
cmp rax, 6		; 5 - 6 = -1 (Zero = 0, Sign = 1, Parity = 1)
cmp rax, 1		; 5 - 1 = 4  (Zero = 0, Sign = 0, Parity = 0)
sub rax, 5

; The test instructions like TEST and CMP are handy to update
; flags without modifying register values.
;
; Let's look at conditional jump instructions now. There
; are a lot of them. The textbook has a good list (Table 5.7).
; ---------------------------------------------------------

; Example if condition pseudocode:
;
; rax = GetUserInput();
; if (rax == 0)
;	rbx = 2

call GetInt		; Get user integer from user input, result in RAX
cmp rax, 0		; Compare to 0
jnz skipIt		; Jump to label if input was not zero
mov rbx, 2		; This instruction will be executed if input was 0

skipIt:

; What about an if/else scenario?:
;
; rax = GetUserInput();
; if (rax == 0)
;	rbx = 2
; else
;	rbx = 5

cmp rax, 0		; Compare to 0
jnz doTheElse	; Jump to label if input was not zero

mov rbx, 2
jmp ifElseDone	; Need to skip over the "else" part

doTheElse:
mov rbx, 5

ifElseDone:

; What about compound conditions?
; These use short-circuit evaluation.
;
; if (rax == 0 || rax == 1)
;	rbx = 2

call GetInt				; Get user integer from user input, result in RAX

cmp rax, 0				; rax == 0
jz compoundOrIsTrue		; Short-circuit since we know its true, no need to evaluate rax == 1

cmp rax, 1				; rax == 1
jnz compountOrIsFalse	; Bail if false

compoundOrIsTrue:
mov rbx, 2				; rbx = 2

compountOrIsFalse:

; Can also do a compount AND
;
; if (rax == 0 && rcx == 1)
;	rbx = 2

call GetInt				; Get user integer from user input, result in RAX
mov rcx, 1

cmp rax, 0				; rax == 0
jnz compoundAndFalse	; Short-circuit since we know its false, no need to evaluate rcx == 1

cmp rcx, 1				; rcx == 1
jnz compoundAndFalse	; Jump if false

mov rbx, 2				; rbx = 2

compoundAndFalse:

; =========================================================

lea rsp, [rbp]
pop rbx
pop rbp
ret

AsmBranching ENDP

END
