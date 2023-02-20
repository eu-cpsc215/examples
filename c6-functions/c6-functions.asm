.DATA

.CODE

; =========================================================
; void AsmFunctionExample0()
;
; Function that takes no parameters and returns nothing.
; =========================================================
AsmFunctionExample0 PROC

    nop     ; This function does nothing

    ret

AsmFunctionExample0 ENDP

; =========================================================
; int AsmFunctionExample1(int a, float b, const char* c)
;
; Simple example function with three parameters.
; Observe the register values while stepping through the function.
; All parameters will be passed using registers.
; =========================================================
AsmFunctionExample1 PROC

    push rbp                ; Callee-saved register
    mov rbp, rsp            ; Establish frame pointer
    ; -------------------- /\ PROLOGUE /\ --------------------

    mov rax, rcx            ; Param 'a' (interger)
    movaps xmm8, xmm1       ; Param 'b' (floating point)
    mov rax, r8             ; Param 'c' (memory address)

    ; -------------------- \/ EPILOGUE \/ --------------------
    pop rbp                 ; Restore callee-saved register
    ret

AsmFunctionExample1 ENDP

; =========================================================
; int64_t AsmFunctionExample2(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e, int64_t f)
;
; Advanced example function with six parameters.
; Four will use registers, two will use stack.
; This function takes utilizes shadow space allocated by the caller.
; This function allocates stack space for local variables.
; =========================================================
AsmFunctionExample2 PROC

    push rbp                ; Callee-saved register
    push rbx                ; Callee-saved register (we'll use RBX within this function)
    sub rsp, 10h            ; Allocate space for two 64-bit local variables
    mov rbp, rsp            ; Establish frame pointer
    ; -------------------- /\ PROLOGUE /\ --------------------

    ; Here's what the stack should look like right now:
    ;
    ; RSP/RBP --> | Allocated for local variable
    ;             | Allocated for local variable
    ;             | Saved RBX for caller
    ;             | Saved RBP for caller
    ;             | Return address
    ;             | Shadow space
    ;             | Shadow space
    ;             | Shadow space
    ;             | Shadow space
    ;             | Parameter 'e' value
    ;             | Parameter 'f' value

    ; Save register params into shadow space just for fun.
    ; This is such a simple function, you wouldn't even need to do this, this is just for demo purposes.
    ; This space is available for use as you see fit.
    mov [rbp + 28h], rcx    ; Move param 'a' into shadow space (see the stack diagram above to understand RBP + 28h)
    mov [rbp + 30h], rdx    ; Move param 'b' into shadow space
    mov [rbp + 38h], r8     ; Move param 'c' into shadow space
    mov [rbp + 40h], r9     ; Move param 'd' into shadow space

    ; Get the remaining parameters from the stack
    mov rax, [rbp + 48h]    ; Move param 'e' into RAX
    mov rbx, [rbp + 50h]    ; Move param 'f' into RBX

    ; Add everything up (RAX will hold return value)
    add rax, rbx
    add rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9

    ; -------------------- \/ EPILOGUE \/ --------------------
    lea rsp, [rsp + 10h]    ; Free stack-allocated space used by the local variables
    pop rbx                 ; Restore callee-saved register
    pop rbp                 ; Restore callee-saved register
    ret

AsmFunctionExample2 ENDP

; =========================================================
; void AsmFunctionExample3()
;
; This example calls another function defined in assembly.
; =========================================================
AsmFunctionExample3 PROC

    push rbp            ; Callee-saved register
    sub rsp, 20h        ; Shadow space for any function calls
    ; -------------------- /\ PROLOGUE /\ --------------------

    mov rcx, 3
    call asmFunctionExample3Helper

    ; -------------------- \/ EPILOGUE \/ --------------------
    lea rsp, [rsp+20h]  ; Cleanup allocated space
    pop rbp             ; Restore callee-saved register
    ret

AsmFunctionExample3 ENDP

; =========================================================
asmFunctionExample3Helper PROC

    mov [rsp + 8h], rcx     ; Save register parameter into shadow space
    push rbp                ; Callee-saved register
    mov rbp, rsp            ; Establish frame pointer
    ; -------------------- /\ PROLOGUE /\ --------------------

    ; We could get the param from rcx directly, but this demonstrates
    ; saving off the paramter and coming back later to access it.
    mov rax, [rbp + 10h]

    ; -------------------- \/ EPILOGUE \/ --------------------
    pop rbp                 ; Restore callee-saved register
    ret

asmFunctionExample3Helper ENDP

; =========================================================
; void AsmFunctionExample4(int (*functionPtr)(int));
;
; This example calls a function defined in C code.
; =========================================================
AsmFunctionExample4 PROC

    push rbp                ; Callee-saved register
    mov rbp, rsp            ; Establish frame pointer
    sub rsp, 20h            ; Allocate shadow space for any function calls
    ; -------------------- /\ PROLOGUE /\ --------------------

    mov rax, rcx
    mov rcx, 5
    call rax

    ; -------------------- \/ EPILOGUE \/ --------------------
    lea rsp, [rsp+20h]      ; Cleanup allocated space
    pop rbp                 ; Restore callee-saved register
    ret

AsmFunctionExample4 ENDP

; =========================================================
; void AsmFunctionExample5()
;
; This example calls another function defined in assembly.
; This demonstrates using the stack to pass additional parameters.
; =========================================================
AsmFunctionExample5 PROC

    push rbp        ; Callee-saved register
    ; -------------------- /\ PROLOGUE /\ --------------------

    mov rcx, 1      ; Param 'a'
    mov rdx, 2      ; Param 'b'
    mov r8, 3       ; Param 'c'
    mov r9, 4       ; Param 'd'
    push 6          ; Param 'f'
    push 5          ; Param 'e'
    sub rsp, 20h    ; Shadow space

    call asmFunctionExample5Helper	; After return, expect RAX to have result of 21 (0x15)

    add rsp, 20h    ; Cleanup shadow space
    pop rbx         ; Cleanup param 'e'
    pop rbx         ; Cleanup param 'f'

    ; -------------------- \/ EPILOGUE \/ --------------------
    pop rbp         ; Restore callee-saved register
    ret

AsmFunctionExample5 ENDP

; =========================================================
; Assume function has following params: (int a, int b, int c, int d, int e, int f)
asmFunctionExample5Helper PROC

    push rbp                ; Callee-saved register
    mov rbp, rsp            ; Establish frame pointer
    ; -------------------- /\ PROLOGUE /\ --------------------

    ; Here's what the stack should look like right now:
    ; 
    ; RSP/RBP --> | Saved RBP for caller
    ;             | Return address
    ;             | Shadow space
    ;             | Shadow space
    ;             | Shadow space
    ;             | Shadow space
    ;             | Parameter value ('f')
    ;             | Parameter value ('e')

    ; Let's add up all the params
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    add rax, [rsp + 30h] ; Param 'e'
    add rax, [rsp + 38h] ; Param 'f'

    ; -------------------- \/ EPILOGUE \/ --------------------
    pop rbp                 ; Restore callee-saved register
    ret

asmFunctionExample5Helper ENDP

END
