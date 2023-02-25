extrn ExitProcess : proc

.DATA

sourceArray QWORD 8 DUP(2)
destArray QWORD 8 DUP(1)

.CODE

_main PROC

;----------------------------------------------------------

;----------------------------------------------------------
; STD - Set direction flag
; CLD - Set direction flag
;----------------------------------------------------------

std		; DF = 1, RSI/RDI decremented automatically after execution of string instructions.
cld		; DF = 0, RSI/RDI incremented automatically after execution of string instructions.

;----------------------------------------------------------
; MOVS - https://www.felixcloutier.com/x86/movs:movsb:movsw:movsd:movsq
;----------------------------------------------------------

; Copies data from source to destination.
; RSI - source address
; RDI - destination address
;
; There are different variations of the instruction depending on what size of data needs copied:
; MOVSB - Byte (1 byte)
; MOVSW - Word (2 bytes)
; MOVSD - Double word (4 bytes)
; MOVSQ - Quad word (8 bytes)
;
; Note the explicit operand variation of the instruction still uses RSI/RDI as source/destination.
;
; For all string instructions, be aware that different variants exist and they utilize appropriate
; memory/register sizes. Only 64-bit variants are used in these examples.

; Example: Observe QWORD is copied from source to dest and RSI/RDI are incremented.
mov rsi, OFFSET sourceArray
mov rdi, OFFSET destArray
movsq

;----------------------------------------------------------
; CMPS - https://www.felixcloutier.com/x86/cmps:cmpsb:cmpsw:cmpsd:cmpsq
;----------------------------------------------------------

; Compares data in source to destination; flags set appropriately (i.e., SF, ZF, etc.)
; RSI/RDI incremented/decremented acording to DF.

mov [sourceArray], 42h
mov [sourceArray + 8h], 50h
mov [sourceArray + 10h], 60h
mov [destArray], 43h
mov [destArray + 8h], 50h
mov [destArray + 10h], 30h

mov rsi, OFFSET sourceArray
mov rdi, OFFSET destArray

cmpsq	; 42h != 43h     (42h - 43h, zero flag 0, sign flag -1)
cmpsq	; 50h == 50h     (50h - 50h, zero flag 1, sign flag 0)
cmpsq	; 60h != 30h     (60h - 30h, zero flag 0, sign flag 0)

;----------------------------------------------------------
; SCAS - https://www.felixcloutier.com/x86/scas:scasb:scasw:scasd
;----------------------------------------------------------

; Similar to COMPS, but compares data in [RDI] to RAX. (RSI is not used.)
; RDI is incremented/decremented acording to DF. (RSI is not modified.)

mov rax, 46h

mov [destArray], 43h
mov [destArray + 8h], 48h
mov [destArray + 10h], 46h

mov rdi, OFFSET destArray

scasq	; 46h != 43h
scasq	; 46h != 48h
scasq	; 46h == 46h

;----------------------------------------------------------
; STOS - https://www.felixcloutier.com/x86/stos:stosb:stosw:stosd:stosq
;----------------------------------------------------------

; Copies value from RAX into [RDI]. (RSI is not used.)
; RDI is incremented/decremented acording to DF. (RSI is not modified.)

mov rax, 99h
mov rdi, OFFSET destArray

stosq
stosq
stosq
stosq
stosq

;----------------------------------------------------------
; LODS - https://www.felixcloutier.com/x86/lods:lodsb:lodsw:lodsd:lodsq
;----------------------------------------------------------

; Copies value from [RSI] into RAX. (RDI is not used.)
; RSI is incremented/decremented acording to DF. (RDI is not modified.)

mov [sourceArray], 42h
mov [sourceArray + 8h], 50h
mov [sourceArray + 10h], 60h

mov rsi, OFFSET sourceArray

lodsq
lodsq
lodsq

;----------------------------------------------------------
; Repeat instructions (string operation prefix)
; REP/REPE/REPZ/REPNE/REPNZ
; https://www.felixcloutier.com/x86/rep:repe:repz:repne:repnz
;----------------------------------------------------------

; Repeat instructions are used as a prefix to string instructions.
; It indicates the specified string instruciton should be repeated automatically.
; Each repeat instruction has different conditions to determine when to stop repeating.
; Table 7.2 in the textbook provides an outline of those conditions and the behaviors of each instruction.
; See the docs for details on which string instructions can use which repeat prefix.

;----------------------------------------------------------
; REP
;----------------------------------------------------------

; Repeat while RCX != 0

; Example: Populate all elements of destArray with 60h.

mov rcx, 8	; RCX is the counter (8 times)
mov rax, 60h
mov rdi, OFFSET destArray

rep stosq

;----------------------------------------------------------
; REPE/REPZ
;----------------------------------------------------------

; Repeat while (RCX != 0 && ZF == 1)

; Example: Get index of first character that differs between two strings.

mov [sourceArray], 'A'
mov [sourceArray + 8h], 'B'
mov [sourceArray + 10h], 'C'
mov [sourceArray + 18h], 'D'
mov [destArray], 'A'
mov [destArray + 8h], 'B'
mov [destArray + 10h], 'C'
mov [destArray + 18h], 'Z'

; Set counter to prevent running outside the bounds of the array
mov rcx, 8
mov rsi, OFFSET sourceArray
mov rdi, OFFSET destArray

repe cmpsq

; Note the value of RCX after repeat ends.
; (May be useful to draw out the state of RSI, RDI, and RCX over each step)
; RCX ends up with value of 4.
; 8 - 4 - 1 = 3 is the index of the first different character

;----------------------------------------------------------
; REPNE/REPNZ
;----------------------------------------------------------

; Repeat while (RCX != 0 && ZF == 0)

; Example: Get index of the first 'H' character in a string.

mov [destArray], 'A'
mov [destArray + 8h], 'B'
mov [destArray + 10h], 'C'
mov [destArray + 18h], 'D'
mov [destArray + 20h], 'H'

mov rcx, 8
mov rax, 'H'
mov rdi, OFFSET destArray

repne scasq

; Note the value of RCX after repeat ends.
; RCX ends up with value of 3.
; 8 - 3 - 1 = 4 is the index of the first 'H' character

;----------------------------------------------------------

xor rcx, rcx
call ExitProcess

_main ENDP

END
