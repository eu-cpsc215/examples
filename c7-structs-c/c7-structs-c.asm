extrn ExitProcess : proc
extrn MessageBoxA : proc

; Define a structure
Person STRUCT
	pname BYTE 64 DUP(?)	; 'name' is a reserved keyword
	age DWORD ?
	height WORD ?
	weight DWORD ?
Person ENDS

.DATA

; Create an instance of the structure
manager person <"Bob",31,72,165>

; Create an array of structure instances (array length is 10, only 2 are initialized)
employees person 10 DUP(<"Sally",22,64,160>, <"George",31,72,170>)

.CODE

_main PROC

push rbp			; Callee-saved register
sub rsp, 20h		; Shadow space for any function calls

;----------------------------------------------------------

; Access a field of the struct (read/write)
mov eax, manager.age
mov manager.age, 34
mov ebx, manager.age

mov rcx, 0
mov rdx, OFFSET manager.pname	; Get pointer to name string
mov r8, 0
mov r9, 0
call MessageBoxA

;----------------------------------------------------------

xor rcx, rcx
call ExitProcess

lea rsp, [rsp+20h]	; Cleanup allocated space
pop rbp				; Restore callee-saved register

_main ENDP

END
