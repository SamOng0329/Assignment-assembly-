; DOS Assembly: Simple login with array of users and passwords
; Compatible with MASM/TASM and DOSBox

.model small
.stack 100h

.data
prompt_msg     db "Are you a member? (Y/N) $"
login_msg      db 0Dh, 0Ah, "Please Login:", 0Dh, 0Ah, "$"
user_prompt    db "Username: $"
pass_prompt    db "Password: $"
login_success  db 0Dh, 0Ah, "Login Successfully.", 0Dh, 0Ah, "$"
login_fail     db 0Dh, 0Ah, "Login Failed.", 0Dh, 0Ah, "$"
welcome_msg    db "Welcome ", "$"
newline        db 0Dh, 0Ah, '$'

; User database: 2 users
usernames      db 'SamOng ', 0
               db 'Alice  ', 0
passwords      db '123456', 0
               db 'abcdef', 0

MAX_USERS      equ 2
USER_LEN       equ 7
PASS_LEN       equ 6

input_user     db USER_LEN+1 dup(0)
input_pass     db PASS_LEN+1 dup(0)

.code

main PROC
    mov ax, @data
    mov ds, ax

    ; Show Y/N prompt
    mov ah, 09h
    lea dx, prompt_msg
    int 21h

    mov ah, 01h          ; Get single character
    int 21h
    mov bl, al           ; Store input to BL

    mov ah, 09h
    lea dx, newline
    int 21h

    cmp bl, 'Y'
    je do_login
    cmp bl, 'y'
    je do_login
    jmp exit_program

do_login:
    mov ah, 09h
    lea dx, login_msg
    int 21h

    ; Username prompt
    mov ah, 09h
    lea dx, user_prompt
    int 21h

    lea si, input_user      ; SI points to input_user buffer
    mov cx, USER_LEN
    call get_input

    ; Password prompt
    mov ah, 09h
    lea dx, pass_prompt
    int 21h

    lea si, input_pass      ; SI points to input_pass buffer
    mov cx, PASS_LEN
    call get_input

    ; Check login
    mov di, 0              ; di = user index (0 or 1)
check_next_user:
    mov si, offset usernames
    mov bx, di
    mov cx, USER_LEN
    mov ax, bx
    mov dx, USER_LEN+1
    mul dx                 ; ax = (USER_LEN+1) * user_index
    add si, ax             ; SI points to current username

    lea bp, input_user     ; BP points to input_user
    mov cx, USER_LEN
    push si
    push bp
    call strncmp           ; Compare USER_LEN chars
    pop bp
    pop si
    cmp ax, 0
    jne try_next_user      ; If not match, try next user

    ; Username matches, check password
    mov si, offset passwords
    mov bx, di
    mov cx, PASS_LEN
    mov ax, bx
    mov dx, PASS_LEN+1
    mul dx                 ; ax = (PASS_LEN+1) * user_index
    add si, ax             ; SI points to password

    lea bp, input_pass     ; BP points to input_pass
    mov cx, PASS_LEN
    push si
    push bp
    call strncmp           ; Compare PASS_LEN chars
    pop bp
    pop si
    cmp ax, 0
    jne try_next_user      ; If not match, try next user

    ; Success!
    mov ah, 09h
    lea dx, login_success
    int 21h
    mov ah, 09h
    lea dx, welcome_msg
    int 21h
    ; Print username
    mov si, offset usernames
    mov bx, di
    mov ax, bx
    mov dx, USER_LEN+1
    mul dx
    add si, ax
    mov ah, 09h
    mov dx, si
    int 21h

    jmp exit_program

try_next_user:
    inc di
    cmp di, MAX_USERS
    jl check_next_user

login_failed:
    mov ah, 09h
    lea dx, login_fail
    int 21h

exit_program:
    mov ah, 4Ch
    int 21h
main ENDP

; ---------------------------------------------------------------
; get_input: Reads CX chars from keyboard, stores at [SI]
; Terminates on Enter, stores 0 at end
; ---------------------------------------------------------------
get_input PROC
    push ax
    push cx
    push si

    xor bx, bx
get_input_loop:
    mov ah, 01h
    int 21h
    cmp al, 0Dh
    je get_input_done
    mov [si+bx], al
    inc bx
    cmp bx, cx
    jl get_input_loop
get_input_done:
    mov byte ptr [si+bx], 0   ; Null-terminate
    pop si
    pop cx
    pop ax
    ret
get_input ENDP

; ---------------------------------------------------------------
; strncmp: Compares CX bytes at [SI] and [BP]
; Returns AX=0 if equal, AX=1 if not
; ---------------------------------------------------------------
strncmp PROC
    push si
    push bp
    push cx
    xor ax, ax
    xor dx, dx
compare_loop:
    mov dl, [si]
    mov dh, [bp]
    cmp dl, dh
    jne not_equal
    inc si
    inc bp
    loop compare_loop
    xor ax, ax
    jmp end_strncmp
not_equal:
    mov ax, 1
end_strncmp:
    pop cx
    pop bp
    pop si
    ret
strncmp ENDP

end main