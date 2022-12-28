.DATA

.CODE

AsmLooping PROC

push rbp
push rbx
sub rsp, 20h ; Reserve 32-bytes shadow space
lea rbp, [rsp + 20h]

; =========================================================

; LOOP
;
; This instruction acts as a do...while loop.
;
; int i = 5;
; do {
;    // do something
;
;    i--;
; } while (i > 0)
;
; For the LOOP instruction, RCX is used as the counter.
; When the instruction executes, RCX is decremeted.
; If > 0, it jumps to the specified location.
; ---------------------------------------------------------
mov rax, 0
mov rcx, 5		; Counter

loopLabel:		; do
inc rax			; { Loop body }
loop loopLabel	; while (rcx > 0)

; NOTE: if rcx is 0 before LOOP is executed, it will roll over since that value is treated as unsigned.
; NOTE: the operand for LOOP is a signed 8-bit relative address, so there is a limit of how far away the loop target can be.

; Other looping structures can be created manually by using
; custom counters and jump instructions.
;
; for (int i = 0; i < 5; ++i)
; {
;     // do something
; }
; ---------------------------------------------------------
mov rax, 0
mov rcx, 0		; int i = 0

forLoopBegin:

	cmp rcx, 5		; i < 5
	jz forLoopEnd

	inc rax			; { Loop body }

	inc rcx			; i++
	jmp forLoopBegin

forLoopEnd:

; Regular while loop:
;
; while (i > 0)
; {
;     // do something
;     --i
; }
; ---------------------------------------------------------
mov rax, 0
mov rcx, 5

whileLoopBegin:

	cmp rcx, 0
	jz whileLoopEnd
	inc rax				; { Loop body }
	dec rcx				; --i
	jmp whileLoopBegin

whileLoopEnd:

; What about a nested loop?
;
; for (int row = 0; row < 10; ++row)
;     for (int col = 0; col < 5; ++col)
;         // do something
; ---------------------------------------------------------
mov rax, 0			; total number of cells visited
mov rcx, 0			; int row = 0

nestedLoopOuter:

	cmp rcx, 10				; row < 10
	jz nestedLoopEnd

	; {
		mov rdx, 0			; int col = 0

		nestedLoopInner:
			cmp rdx, 5		; col < 5
			jz nestedLoopInnerEnd
	
			; {
				inc rax
			; }

			inc rdx			; col++
			jmp nestedLoopInner

		nestedLoopInnerEnd:
	; }

	inc rcx					; row++
	jmp nestedLoopOuter

nestedLoopEnd:

; =========================================================

lea rsp, [rbp]
pop rbx
pop rbp
ret

AsmLooping ENDP

END
