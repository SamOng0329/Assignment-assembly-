.model small
.stack 100h

.data
; Constants defined for better readability and maintenance 
; --- System Constants ---
PIN_LENGTH          EQU 6
MAX_PIN_ATTEMPTS    EQU 3
BACKSPACE_KEY       EQU 8
ENTER_KEY           EQU 13

; --- Transaction Limits ---
MIN_WITHDRAWAL      EQU 100
MAX_WITHDRAWAL      EQU 3000
MIN_DEPOSIT         EQU 100
MAX_DEPOSIT         EQU 10000

; Welcome messages and basic UI text
menu_msg            db 13, 10, 'Welcome to KL ATM! $'
insert_card_msg     db 13, 10, 'Please insert your card! $'
newline             db 13, 10, '$'
take_card_msg       db 13, 10, 'Please take your card! $'
exit_msg            db 13, 10, 'Thank you for using KL ATM. Goodbye! $'

; PIN security system - limits attempts to prevent brute force
pin_msg             db 13, 10, 'Please enter 6-digit PIN: $'
fail_pin            db 13, 10, 'Incorrect PIN. Try again.$'
card_retained_msg   db 13, 10, 'Too many wrong attempts. Your card has been retained!$'
times_out_msg       db 13, 10, 'Too many invalid attempts. Returning to main menu.$'
fail_count          db 0                    ; tracks wrong PIN attempts
pin_buf             db 7, ?, 7 dup('$')     ; buffer to store user input
correct_pin         db '123456$'            ; hardcoded PIN for demo

; Menu system - shows all available banking operations
select_msg          db 13, 10, 'Please select an option (1-5): $'
checkBalance_option db 13, 10, '1. Check Balance$'
withdraw_option     db 13, 10, '2. Withdraw Cash$'
deposit_option      db 13, 10, '3. Deposit Cash$'
pin_change_option   db 13, 10, '4. Change PIN$'
exit_option         db 13, 10, '5. Exit$'
choice_buf          db 100 ,?, 100 dup('$')     ; stores user menu choice

; Balance storage - split into whole ringgit and cents for precision
balance_msg         db 13, 10, 'Your current balance is: RM $'
balance_whole       dw 50000                ; main balance (RM)
balance_fraction    dw 55                   ; cents portion (0-99)

; Withdrawal system with validation limits
withdraw_prompt     db 13, 10, 'Enter withdrawal amount (no cents): RM $'
withdraw_success    db 13, 10, 'Withdrawal successful!$'
withdraw_failed     db 13, 10, 'Invalid amount! Please enter again.(no cents) $'
max_withdraw_msg    db 13, 10, 'Maximum withdrawal is RM3000.$'
min_withdraw_msg    db 13, 10, 'Minimum withdrawal is RM100.$'
insufficient_msg    db 13, 10, 'Insufficient balance for this transaction.$'
withdraw_buf        db 8, ?, 8 dup('$')     ; holds withdrawal amount input

; Deposit system - adds money to account
deposit_prompt      db 13, 10, 'Enter deposit amount (no cents): RM $'
deposit_success     db 13, 10, 'Deposit successful!$'
deposit_failed     db 13, 10, 'Invalid amount! Valid range: RM100-10000 (no cents)$'
deposit_buf         db 8, ?, 8 dup('$')     ; holds deposit amount input

; PIN change system - requires current PIN for security
current_pin_msg     db 13, 10, 'Enter current PIN: $'
new_pin_msg         db 13, 10, 'Enter new 6-digit PIN: $'
confirm_pin_msg     db 13, 10, 'Confirm new PIN: $'
pin_changed_msg     db 13, 10, 'PIN changed successfully!$'
pin_mismatch_msg    db 13, 10, 'PINs do not match. Try again.$'
invalid_pin_format  db 13, 10, 'PIN must be 6 digits.$'
invalid_current_pin db 13, 10, 'Current PIN is incorrect!$'
current_pin_buf     db 7, ?, 7 dup('$')
new_pin_buf         db 7, ?, 7 dup('$')
confirm_pin_buf     db 7, ?, 7 dup('$')

; Fee system - charges 0.2% on withdrawals
fee_prompt          db 13, 10, 'Transaction fee: RM $'
withdraw_fee_msg    db 13, 10, 'A withdrawal fee of 0.2% applies to each transaction.$'
fee_whole           dw 0                    ; fee amount (whole part)
fee_fraction        dw 0                    ; fee amount (cents part)

; Working variables for calculations
amount_whole        dw 0                    ; temporary storage for amounts
amount_fraction     dw 0
last_total_deducted dw 0, 0                ; total withdrawn (amount + fee)

.code
; 1. MAIN PROGRAM FLOW
;==============================================================================
; Program entry point - sets up data and starts main loop
main PROC
    mov ax, @data
    mov ds, ax

    call display_welcome              ; Clear screen, show welcome message
    call authenticate_pin             ; Securely verify user identity

main_menu:
    call display_menu                 ; Show options 1-5
    call get_user_choice              ; Get user's menu selection

    ; Jump to the appropriate function based on the user's choice
    cmp bl, '1'
    je check_balance
    cmp bl, '2'
    je withdraw
    cmp bl, '3'
    je deposit
    cmp bl, '4'
    je change_PIN
    cmp bl, '5'
    je exit_program
    
    jmp main_menu                     ; If choice is invalid, show the menu again

check_balance:
    call display_balance
    jmp main_menu

withdraw:
    call withdraw_proc
    jmp main_menu
    
deposit:
    call deposit_proc
    jmp main_menu

change_PIN:
    call modify_pin
    jmp main_menu

exit_program:
    call display_goodbye
    mov ax, 4C00h
    int 21h
main ENDP


; 2. HIGH-LEVEL UI AND LOGIC PROCEDURES
;==============================================================================
; Clears screen and shows welcome message - the first thing the user sees
display_welcome PROC
    mov ax, 0600h                     ; AH=06 (scroll), AL=00 (clear all)
    mov bh, 07h                       ; Normal white text on black
    mov cx, 0000h                     ; Start at top-left (0,0)
    mov dx, 184Fh                     ; End at bottom-right (24,79)
    int 10h

    mov ah, 09h
    lea dx, menu_msg
    int 21h

    mov ah, 09h
    lea dx, insert_card_msg
    int 21h
    ret
display_welcome ENDP

; Shows all menu options in a numbered list format
display_menu PROC
    mov ah, 09h
    lea dx, newline
    int 21h

    lea dx, checkBalance_option
    int 21h

    lea dx, withdraw_option
    int 21h

    lea dx, deposit_option
    int 21h

    lea dx, pin_change_option
    int 21h

    lea dx, exit_option
    int 21h

    lea dx, select_msg
    int 21h
    ret
display_menu ENDP

; Shows goodbye messages when the user chooses to exit
display_goodbye PROC
    mov ah, 09h
    lea dx, take_card_msg
    int 21h
    
    mov ah, 09h
    lea dx, exit_msg
    int 21h
    ret
display_goodbye ENDP

; Security system - verifies PIN with a maximum of 3 attempts and hides input
authenticate_pin PROC
    mov fail_count, 0

prompt_pin:
    mov ah, 09h
    lea dx, pin_msg
    int 21h

    mov cx, 0                         
    mov si, offset pin_buf + 2        

get_pin_char:
    mov ah, 08h                       
    int 21h                           

    cmp al, BACKSPACE_KEY
    je handle_backspace
    
    cmp al, '0'
    jb get_pin_char
    cmp al, '9'
    ja get_pin_char
    
    cmp cx, PIN_LENGTH
    je get_pin_char                   

    mov [si], al
    inc si                            
    inc cx                            

    mov ah, 02h
    mov dl, '*'
    int 21h
    
    cmp cx, PIN_LENGTH
    jl get_pin_char                   
    jmp pin_entry_done

handle_backspace:
    cmp cx, 0
    je get_pin_char                   

    dec cx                            
    dec si                            

    mov ah, 02h
    mov dl, BACKSPACE_KEY                       
    int 21h
    mov dl, ' '                       
    int 21h
    mov dl, BACKSPACE_KEY                       
    int 21h
    
    jmp get_pin_char                  

pin_entry_done:
    mov byte ptr [pin_buf + 1], PIN_LENGTH
    mov al, [pin_buf + 1]             
    cmp al, PIN_LENGTH
    jne pin_failed

    mov si, offset pin_buf + 2        
    mov di, offset correct_pin        
    mov cx, PIN_LENGTH                         
compare_loop:
    mov al, [si]
    cmp al, [di]
    jne pin_failed                    
    inc si
    inc di
    loop compare_loop

    ret                               

pin_failed:
    mov ah, 09h
    lea dx, newline
    int 21h

    inc fail_count
    mov al, fail_count
    cmp al, MAX_PIN_ATTEMPTS
    jae card_retained                 

    mov ah, 09h
    lea dx, fail_pin
    int 21h
    jmp prompt_pin                    

card_retained:
    mov ah, 09h
    lea dx, card_retained_msg
    int 21h

    mov ax, 4C00h                     
    int 21h
authenticate_pin ENDP

; Main withdrawal process with fee calculation and validation
withdraw_proc PROC
    push cx
    
    call display_balance              
    
    mov ah, 09h
    lea dx, withdraw_fee_msg          
    int 21h

    mov cx, 3                         
withdraw_loop:
    mov ah, 09h
    lea dx, withdraw_prompt
    int 21h

    mov ah, 0Ah
    lea dx, withdraw_buf
    int 21h

    call process_withdrawal
    jnc withdraw_success_msg          

    dec cx
    jnz withdraw_loop                 

    mov ah, 09h
    lea dx, times_out_msg
    int 21h
    jmp withdraw_end

withdraw_success_msg:
    call display_fee                  
    
    mov ah, 09h
    lea dx, withdraw_success
    int 21h

    call display_balance              

withdraw_end:
    pop cx
    ret
withdraw_proc ENDP

; Handles cash deposits with validation
deposit_proc PROC
    push ax
    push bx
    push cx
    push dx
    push si

    call display_balance              

    mov ah, 09h
    lea dx, deposit_prompt
    int 21h

    mov ah, 0Ah
    lea dx, deposit_buf
    int 21h

    lea dx, deposit_buf               
    call parse_input_amount           
    jc dep_invalid

    mov ax, [amount_whole]
    cmp ax, MIN_DEPOSIT                       
    jb dep_invalid
    cmp ax, MAX_DEPOSIT                     
    ja dep_invalid

    call add_to_balance
    
    mov ah, 09h
    lea dx, deposit_success
    int 21h

    call display_balance              
    jmp dep_end

dep_invalid:
    mov ah, 09h
    lea dx, deposit_failed
    int 21h

dep_end:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
deposit_proc ENDP

; Secure PIN change process - requires current PIN verification
modify_pin PROC
    push ax 
    push bx
    push cx
    push dx
    push si
    push di

    mov ah, 09h
    lea dx, current_pin_msg
    int 21h

    mov ah, 0Ah
    lea dx, current_pin_buf
    int 21h

    mov al, [current_pin_buf+1]
    cmp al, PIN_LENGTH
    jne invalid_current

    mov si, offset current_pin_buf+2
    mov di, offset correct_pin
    mov cx, PIN_LENGTH
verify_current:
    mov al, [si]
    cmp al, [di]
    jne invalid_current               
    inc si
    inc di
    loop verify_current

get_new_pin:
    mov ah, 09h
    lea dx, new_pin_msg
    int 21h

    mov ah, 0Ah
    lea dx, new_pin_buf
    int 21h

    mov al, [new_pin_buf+1]
    cmp al, PIN_LENGTH
    jne pin_format_error

    mov ah, 09h
    lea dx, confirm_pin_msg
    int 21h

    mov ah, 0Ah
    lea dx, confirm_pin_buf
    int 21h

    mov al, [confirm_pin_buf+1]
    cmp al, PIN_LENGTH
    jne pin_format_error

    mov si, offset new_pin_buf+2
    mov di, offset confirm_pin_buf+2
    mov cx, PIN_LENGTH
compare_pins:
    mov al, [si]
    cmp al, [di]
    jne pins_dont_match               
    inc si
    inc di
    loop compare_pins

    mov si, offset new_pin_buf+2
    mov di, offset correct_pin
    mov cx, PIN_LENGTH
update_pin:
    mov al, [si]
    mov [di], al                      
    inc si
    inc di
    loop update_pin

    mov ah, 09h
    lea dx, pin_changed_msg
    int 21h
    jmp pin_change_exit

invalid_current:
    mov ah, 09h
    lea dx, invalid_current_pin
    int 21h
    jmp pin_change_exit

pin_format_error:
    mov ah, 09h
    lea dx, invalid_pin_format
    int 21h
    jmp get_new_pin                   

pins_dont_match:
    mov ah, 09h
    lea dx, pin_mismatch_msg
    int 21h
    jmp get_new_pin                   

pin_change_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
modify_pin ENDP


; 3. HELPER AND SUB-PROCEDURES
;==============================================================================
; Input and Parsing Helpers  
; Gets single character input from user for menu selection
get_user_choice PROC
    mov ah, 0Ah                       
    lea dx, choice_buf
    int 21h

    mov bl, [choice_buf + 2]          
    ret
get_user_choice ENDP

; Converts user input string to numeric value.
; Expects: DX = address of the input buffer (e.g., withdraw_buf)
parse_input_amount PROC
    push ax
    push bx
    push cx
    push si

    mov si, dx
    add si, 2
    
    mov word ptr [amount_whole], 0
    mov word ptr [amount_fraction], 0

parse_loop:
    mov al, [si]                      
    
    cmp al, '.'
    je parse_done 
    cmp al, ENTER_KEY                        
    je parse_done
    cmp al, '$'                       
    je parse_done

    sub al, '0'
    cmp al, 0
    jl parse_error                      
    cmp al, 9
    jg parse_error                      

    mov ax, [amount_whole]
    mov bx, 10
    mul bx                            

    mov bl, [si]
    sub bl, '0'                       
    mov bh, 0
    add ax, bx                        
    mov [amount_whole], ax
    
    inc si                            
    jmp parse_loop

parse_done:
    clc                               
    jmp parse_exit

parse_error:
    stc                               

parse_exit:
    pop si
    pop cx
    pop bx
    pop ax
    ret
parse_input_amount ENDP


; --- Core Logic Helpers (Withdrawal) ---
; Validates withdrawal amount and processes transaction
process_withdrawal PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov cl, [withdraw_buf + 1]
    or cl, cl
    jz pw_invalid

    lea dx, withdraw_buf              
    call parse_input_amount           
    jc pw_invalid                     

    mov ax, [amount_whole]
    cmp ax, MIN_WITHDRAWAL                       
    jb pw_small
    cmp ax, MAX_WITHDRAWAL                      
    ja pw_large

    call calculate_fee_02
    call calculate_total_deduction
    
    call check_sufficient_balance
    jc pw_insufficient
    
    call deduct_from_balance
    clc                               
    jmp pw_end

pw_small:
    mov ah, 09h
    lea dx, min_withdraw_msg
    int 21h
    stc                               
    jmp pw_end

pw_large:
    mov ah, 09h
    lea dx, max_withdraw_msg
    int 21h
    stc
    jmp pw_end

pw_insufficient:
    mov ah, 09h
    lea dx, insufficient_msg
    int 21h
    stc
    jmp pw_end

pw_invalid:
    mov ah, 09h
    lea dx, withdraw_failed
    int 21h
    stc

pw_end:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
process_withdrawal ENDP

; Calculates 0.2% withdrawal fee
calculate_fee_02 PROC
    push ax
    push bx
    push dx

    mov ax, [amount_whole]
    
    mov bx, 2
    mul bx                            
    
    mov bx, 1000
    xor dx, dx                        
    div bx                            
    
    mov [fee_whole], ax
    
    mov ax, dx
    mov bx, 10
    xor dx, dx
    div bx
    
    mov [fee_fraction], ax

    pop dx
    pop bx
    pop ax
    ret
calculate_fee_02 ENDP

; Combines withdrawal amount and fee to get total deduction
calculate_total_deduction PROC
    push ax

    mov ax, [amount_whole]
    mov [last_total_deducted], ax
    mov word ptr [last_total_deducted+2], 0

    mov ax, [fee_whole]
    add [last_total_deducted], ax
    
    mov ax, [fee_fraction]
    add [last_total_deducted+2], ax

    mov ax, [last_total_deducted+2]
    cmp ax, 100
    jb ctd_done
    
    sub ax, 100                       
    mov [last_total_deducted+2], ax
    inc word ptr [last_total_deducted] 

ctd_done:
    pop ax
    ret
calculate_total_deduction ENDP

; Verifies account has sufficient balance for transaction
check_sufficient_balance PROC
    push ax

    mov ax, [balance_whole]
    cmp ax, [last_total_deducted]
    jb csb_insufficient               
    ja csb_sufficient                 

    mov ax, [balance_fraction]
    cmp ax, [last_total_deducted+2]
    jb csb_insufficient

csb_sufficient:
    clc                               
    jmp csb_end

csb_insufficient:
    stc                               

csb_end:
    pop ax
    ret
check_sufficient_balance ENDP

; Subtracts total deduction from account balance
deduct_from_balance PROC
    push ax

    mov ax, [balance_fraction]
    sub ax, [last_total_deducted+2]
    jnc df_no_borrow                  

    add ax, 100
    dec word ptr [balance_whole]      

df_no_borrow:
    mov [balance_fraction], ax
    
    mov ax, [balance_whole]
    sub ax, [last_total_deducted]
    mov [balance_whole], ax
    
    pop ax
    ret
deduct_from_balance ENDP

; --- Core Logic Helpers (Deposit) ---
; Adds deposit amount to account balance
add_to_balance PROC
    push ax
    
    mov ax, [balance_fraction]
    add ax, [amount_fraction]         
    cmp ax, 100
    jb ac_no_carry
    
    sub ax, 100
    inc word ptr [balance_whole]

ac_no_carry:
    mov [balance_fraction], ax
    
    mov ax, [balance_whole]
    add ax, [amount_whole]
    mov [balance_whole], ax
    
    pop ax
    ret
add_to_balance ENDP


; --- Display Helpers ---
; Shows current balance in RM format with 2 decimal places
display_balance PROC
    push ax
    push bx
    push cx
    push dx

    mov ah, 09h
    lea dx, balance_msg               
    int 21h

    mov ax, [balance_whole]
    call display_number

    mov ah, 02h
    mov dl, '.'
    int 21h

    mov ax, [balance_fraction]
    call display_two_digits

    mov ah, 09h
    lea dx, newline
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_balance ENDP

; Converts any number to string and displays it digit by digit
display_number PROC
    push ax
    push bx
    push cx
    push dx
    
    cmp ax, 0
    jne dn_not_zero

    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp dn_done

dn_not_zero:
    mov bx, 10
    xor cx, cx                        
dn_convert_loop:
    xor dx, dx                        
    div bx                            
    push dx                           
    inc cx                            
    test ax, ax                       
    jnz dn_convert_loop

dn_display_loop:
    pop dx
    add dl, '0'                       
    mov ah, 02h
    int 21h
    loop dn_display_loop

dn_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_number ENDP

; Displays exactly 2 digits for cents (pads with zero if needed)
display_two_digits PROC
    push ax
    push bx
    push dx
    
    cmp ax, 99
    jbe dt_valid
    mov ax, 99                        
    
dt_valid:
    mov bl, 10
    div bl                            
    
    mov dl, al
    add dl, '0'
    push ax                           
    mov ah, 02h
    int 21h
    
    pop ax                            
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
display_two_digits ENDP

; Shows transaction fee in RM format
display_fee PROC
    push ax
    push dx

    mov ah, 09h
    lea dx, fee_prompt                
    int 21h
    
    mov ax, [fee_whole]
    call display_number
    
    mov ah, 02h
    mov dl, '.'
    int 21h
    
    mov ax, [fee_fraction]
    call display_two_digits
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    pop dx
    pop ax
    ret
display_fee ENDP

END main