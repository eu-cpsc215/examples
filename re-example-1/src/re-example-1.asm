extrn ExitProcess : proc        ; Declare external function ExitProcess
extrn MessageBoxA : proc
extrn GetModuleFileNameA : proc

.DATA                           ; Directive: enter .data section

    filePath BYTE 260 DUP(0)
    filePathLen QWORD 0
    youWinMsg BYTE "You win!",0
    youLoseMsg BYTE "You lose!",0
    gameTitle BYTE "Game",0

.CODE                           ; Directive: enter .code section

_main PROC                      ; Directive: Begin function labeled `_main`

    sub rsp, 28h                ; Bump 8 bytes to ensure 16 byte alignment. Reserve 32 bytes shadow space.
    ; ----------------------------------------

    ; Get exe file path
    ; -----------------
    mov rcx, 0
    mov rdx, OFFSET filePath
    mov r8, LENGTHOF filePath
    call GetModuleFileNameA
    mov filePathLen, rax

    ; Ensure file path is at least three characters long
    ; --------------------------------------------------
    cmp rax, 3
    jl youLose

    ; Second and third characters must be colon (:) then a backslash (\)
    ; ------------------------------------------------------------------
    cmp [filePath + 1], 3Ah   ; colon
    jne youLose

    cmp [filePath + 2], 5Ch   ; backslash
    jne youLose

    ; First character must be 'C' or 'c'
    ; ------------------------------------------------------------------
    mov dl, [filePath + 0]
    or dl, 00100000b    ; Make lowercase
    cmp dl, 63h         ; 'c'     01100011
                        ; 'C'     01000011
    jne youLose

    ; WINNER
    ; ------
    mov rdx, OFFSET youWinMsg
    jmp showMsg

    ; LOSER
    ; ------
youLose:
    mov rdx, OFFSET youLoseMsg

showMsg:
    ; Show message box
    ; ----------------
    mov rcx, 0
    mov r8, OFFSET gameTitle
    mov r9, 0
    call MessageBoxA

    ; ----------------------------------------
    xor rcx, rcx                ; Clear RCX
    call ExitProcess            ; Use Windows API to exit the process

_main ENDP                      ; Directive: End function labeled `_main`

END                             ; Directive: End of module
