.DATA

.CODE

; =========================================================
Program PROC

	push rbp			; Callee-saved register
	lea rbp, [rsp]		; Establish base pointer
	sub rsp, 20h		; Reserve 32-bytes shadow space
	; -------------------- /\ PROLOGUE /\ --------------------



	; -------------------- \/ EPILOGUE \/ --------------------
	lea rsp, [rbp]		; Cleanup params and shadow space
	pop rbp				; Callee-saved register
	ret

Program ENDP

END
