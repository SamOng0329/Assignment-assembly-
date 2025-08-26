.MODEL SMALL
.STACK 100h
.DATA
    msgMember  DB "Are you a member? (Y/N) > $"
    msgLogin   DB 0Dh,0Ah,"Please Login",0Dh,0Ah,"$"
    msgUser    DB "Username > $"
    msgPass    DB "Password > $"
    msgSuccess DB 0Dh,0Ah,"Login Successfully$"
    msgFail    DB 0Dh,0Ah,"Invalid Username/Password, please try again.",0Dh,0Ah,"$"

    ; Stored credentials
    username   DB "SamOng",0
    password   DB "123456",0

    ; Buffers for input
    inputUser  DB 20 DUP(0)
    inputPass  DB 20 DUP(0)

    ans        DB ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Ask if member
    LEA DX, msgMember
    MOV AH, 09h
    INT 21h

    ; Read one character
    MOV AH, 01h
    INT 21h
    MOV ans, AL

    CMP ans, 'Y'
    JNE EXIT       ; If not 'Y', exit program

    ; Print login prompt once
    LEA DX, msgLogin
    MOV AH, 09h
    INT 21h

LOGIN_AGAIN:
    ; Ask username
    LEA DX, msgUser
    MOV AH, 09h
    INT 21h

    ; --- Read username ---
    LEA SI, inputUser
READ_USER:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JE END_USER
    MOV [SI], AL
    INC SI
    JMP READ_USER
END_USER:
    MOV BYTE PTR [SI], 0

    ; Compare username
    LEA SI, inputUser
    LEA DI, username
CMP_USER:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE WRONG
    CMP AL, 0
    JE USER_OK
    INC SI
    INC DI
    JMP CMP_USER

USER_OK:
    ; Ask password
    LEA DX, msgPass
    MOV AH, 09h
    INT 21h

    ; --- Read password ---
    LEA SI, inputPass
READ_PASS:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JE END_PASS
    MOV [SI], AL
    INC SI
    JMP READ_PASS
END_PASS:
    MOV BYTE PTR [SI], 0

    ; Compare password
    LEA SI, inputPass
    LEA DI, password
CMP_PASS:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE WRONG
    CMP AL, 0
    JE LOGIN_OK
    INC SI
    INC DI
    JMP CMP_PASS

WRONG:
    LEA DX, msgFail
    MOV AH, 09h
    INT 21h
    JMP LOGIN_AGAIN

LOGIN_OK:
    LEA DX, msgSuccess
    MOV AH, 09h
    INT 21h
    JMP EXIT

EXIT:
    MOV AH, 4Ch
    INT 21h
MAIN ENDP
END MAIN
