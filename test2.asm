.model small
.data
    prompt_asking_member db "Are you a member? (Y/N) > $"
    msgNotMember db "You are not a member. Exiting program.$"
    msgMember db "Welcome back, member! Please login.$"
    msgLogin db "Please Login$"
    msgUser db "Username > $"
    msgPass db "Password > $"
    msgSuccess db "Login Successfully$"
    msgFail db "Invalid Username/Password, please try again.$"
    msgInvalid db "Invalid input. Please enter Y or N.$"
    inputUser db 20 DUP(0)
    inputPass db 20 DUP(0)

    ;array the user
    username db "SamOng",0
    password db "123456",0

    ans db ?

.code 
main proc
    mov ax, @data
    mov ds, ax

    ;ask if member
    lea dx,prompt_asking_member
    mov ah, 09h
    int 21h

member_input:
    ;Read char
    mov ah, 01h
    int 21h
    mov ans, al

    cmp ans, 'Y'
    je isMember
    cmp ans, 'N'
    je notMember
    jmp member_invalid

member_invalid:
    ; If invalid input, show message
    lea dx,msgInvalid
    mov ah, 09h
    int 21h
    jmp member_input

isMember:
    ; If member, proceed to login
    jmp login

notMember:
    ; If not a member, show message
    lea dx,msgNotMember
    mov ah, 09h
    int 21h
    jmp exit_program

login:
    ; Login process
    lea dx,msgLogin
    mov ah, 09h
    int 21h

    ; Read username
    lea dx,msgUser
    mov ah, 09h
    int 21h
    mov ah, 0Ah
    lea dx,inputUser
    int 21h

    ; Read password
    lea dx,msgPass
    mov ah, 09h
    int 21h
    mov ah, 0Ah
    lea dx,inputPass
    int 21h

    ; Check credentials
    cmp inputUser, username
    jne login_fail
    cmp inputPass, password
    jne login_fail

    ; If successful
    lea dx,msgSuccess
    mov ah, 09h
    int 21h
    jmp exit_program

login_fail:
    lea dx,msgFail
    mov ah, 09h
    int 21h
    jmp exit_program

exit_program:
    ; Exit program
    mov ax, 4C00h
    int 21h
main endp
end main