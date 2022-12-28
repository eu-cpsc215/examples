extrn ExitProcess : proc
extrn MessageBoxA : proc

; Define a structure (define outside any segments)
Player STRUCT
	pname BYTE 64 DUP(?)	; 'name' is a reserved keyword
	age BYTE ?
	height BYTE ?
	weight WORD ?
Player ENDS

.DATA

; Create an instance of the structure
quarterback Player <"Patrick Mahomes",27,74,225>

; Create an array of structure instances (can also do DUP({}) to initialize)
offensivePlayers Player 11 DUP(<"Player Name",0,0,0>)

.CODE

_main PROC

push rbp			; Callee-saved register
sub rsp, 20h		; Shadow space for any function calls

;----------------------------------------------------------

; Access a field of the struct (read/write)
mov al, quarterback.age
mov quarterback.age, 34
mov bl, quarterback.age

mov rcx, 0
mov rdx, OFFSET quarterback.pname	; Get pointer to name string
mov r8, 0
mov r9, 0
call MessageBoxA

; Array of structs
;----------------------------------------------------------
mov rax, SIZEOF Player				; sizeof(Player) in bytes
mov rax, LENGTHOF offensivePlayers	; # of elements
mov rax, SIZEOF offensivePlayers	; # of elements * sizeof(Player)
mov rax, OFFSET [offensivePlayers + (SIZEOF Player * 2)]	; Address of third element in array
lea rbx, (Player ptr [rax]).age		; Address of the "age" member of the third element
mov rcx, 28							; Load immediate value 28 into a temp register
mov [rbx], rcx						; Move value 28 into "age" member of third element
xor rcx, rcx						; Zero out RCX register
mov cl, (Player ptr [rax]).age		; Get "age" value of third element and put into RCX

;----------------------------------------------------------

xor rcx, rcx
call ExitProcess

lea rsp, [rsp+20h]	; Cleanup allocated space
pop rbp				; Restore callee-saved register

_main ENDP

END
