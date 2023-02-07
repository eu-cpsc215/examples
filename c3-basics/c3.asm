; This is a single line comment. Comments start with a semi-colon and take up the rest of the line.

COMMENT !
This is a comment
with multiple
lines.
!

; External function declarations can be listed at the top of the file.
; This function (ExitProcess) comes from the Windows API. It is defined in
; kernel32.lib. Visual Studio provides a number of default static libraries in
; the linking step for us automatically (kernel32.lib is one of them).
extrn ExitProcess : proc

; Data segment - this directive tells the assembler to enter the data segment.
; Both initialized and uninitialized are defined in this section.
.DATA

    initByte BYTE 2                    ; 8-bit unsigned integer
    uninitByte BYTE ?                  ; 8-bit unsigned integer, uninitialized
    signedByte SBYTE -0Ah              ; 8-bit signed integer
    initWord WORD 54F2h                ; 16-bit unsigned integer
    initDword DWORD 4312A2C1h          ; 32-bit unsigned integer
    initQword QWORD 98714128C5D1A8C2h  ; 64-bit unsigned integer

    wordArray WORD 12h, 32h, 1Fh       ; Array of WORDs
    charArray BYTE "Hello, world!",0   ; Array of ASCII characters with a null-terminator at the end
    initArray QWORD 10 DUP (1)         ; Array of 10 QWORDs, each initialized to a value of 1
    uninitArray QWORD 10 DUP (?)       ; Array of 10 QWORDs, each uninitialized

    multiLineString BYTE "This is split up",0Dh,0Ah
        BYTE "into multiple lines.",0

    CONST_VALUE = 12        ; Constant value (not in memory)

; Code segment - this directive tells the assembler to enter the code segment.
; Functions and instructions are defined in this section.
.CODE

; This is a function definition.
; `_main` is an identifier. It is the name of the function.
; PROC is a directive.
_main PROC              ; Begin function - main entry point

    sub rsp, 28h        ; This is an instruction. It is a `sub` instruction with a register operand and an immediate (literal) operand.

; This is a label. It is an identifier with a colon after it.
; Labels can be reference by instructions as operands. For example, a jmp instruction can
; be used to jump program execution to this point. Labels are not instructions and they
; themselves do not get encoded into the program binary output.
myLabel:

    mov rax, CONST_VALUE
    mov al, [initByte]

    xor rcx, rcx
    call ExitProcess    ; Calls the ExitProcess function that is declared at the top of the file.

_main ENDP              ; End function

; The END directive is required to indicate the end of the module
END
