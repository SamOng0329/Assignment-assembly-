.model small
.data
    ; Login system variables
    msgLoginPrompt DB "--- Please login ---$"
    msgUser     DB 0Dh,0Ah,"Username > $"
    username    DB "SamOng",0

    ans db ?

    user_para   LABEL BYTE
    user_max    DB 20              
    user_act    DB ?               
    user_buf    DB 20 DUP(0)       

    msgPassPrompt DB 0Dh,0Ah,"Password > $"
    password      DB "A", 0
    pass_input    DB ?              ; Store single password char

    msgMatch    DB 0Dh,0Ah,"Username matches!$"
    msgNoMatch  DB 0Dh,0Ah,"USERNAME INVALID Please try again$"
    msgPassMatch DB 0Dh,0Ah,"Password matches!$"
    msgPassNoMatch DB 0Dh,0Ah,"Password does not match.$"
    msgBye      DB 0Dh,0Ah,"Goodbye!$"
    msgLogin    DB 0Dh,0Ah,"Jumping to Order Page...$"

    ; Food ordering system variables
    msg db "Welcome to food ordering system $"
    msg1 db "MENU $"
    chicken_rice_name db "1.Chicken Rice $"
    egg_name db "2.Egg $"
    roasted_pork_name db "3.Roasted Pork $"
    charxiufan_name db "4.Char Xiu Fan $"
    wan_tan_mee_name db "5.Wan Tan Mee $"
    chicken_rice_price db " = RM 6.50 $"
    egg_price db " = RM 1.50 $"
    roasted_pork_price db " = RM 18.80 $"  ; Fixed price from 188.00 to 18.80
    charxiufan_price db " = RM 11.00 $"
    wan_tan_mee_price db " = RM 7.50 $"
    msg7 db "Please choose your meals (1~5) > $"
    msg8 db "Your meal is: $"
    chicken_rice_msg db "Chicken Rice $"
    egg_msg db "Egg $"
    roasted_pork_msg db "Roasted Pork $"
    charxiufan_msg db "Char Xiu Fan $"
    wan_tan_mee_msg db "Wan Tan Mee $"
    current_price db "your current price is : RM $"
    price db ?
    qty db ? ; to store user input qty

    price_chicken db ' 6.50$'
    price_egg db ' 1.50$'
    price_roasted_pork db ' 18.80$'  ; Fixed price display from 188.00 to 18.80
    price_charxiufan db '11.00$'
    price_wan_tan_mee db '7.50$'

    qty_msg db "Enter your quantity (integers) > $"
    current_meal db "current meal is: $"
    asterisk db " (* $"
    qty_msg2 db " ) $"

    ;new modify
    total_msg db "Total price: RM $"
    dot_msg db ".$"
    hundreds dw ?
    tens db ?                        
    units db ?                      
    decimal db ?                  

    ;== Addon feature appended here ==
    addon_prompt db 0Dh,0Ah,"Do you want to add an addon? (y/n) > $"
    addon_ordered_msg db 0Dh,0Ah,"Addon ordered! RM 2.00 added.$"
    final_total_msg db 0Dh,0Ah,"Final total price: RM $"
    addon_price dw 200 ; RM 2.00 in cents
    addon_ans db ?
    ;== End addon feature ==

    ;== Arithmetic (Taxes: GST 6%, SST 9%) ==
    gst_msg db 0Dh,0Ah,"GST (6%): RM $"
    sst_msg db 0Dh,0Ah,"SST (9%): RM $"
    gst_sst_total_msg db 0Dh,0Ah,"GRAND TOTAL with GST & SST: RM $"
    gst_tens db ?
    sst_tens db ?
    sst_units db ?

    ;== Member discount feature ==
    member_discount_msg db 0Dh,0Ah,"Member discount (10%): -RM $"
    member_final_msg db 0Dh,0Ah,"FINAL AMOUNT after member discount: RM $"
    ;== End member discount feature ==

    qty_input label byte
    max_len db 100
    act_len db ?
    kb_data db 100 DUP('')

    ; 32-bit calculation variables
    total_cents dd 0    ; Total price in cents
    temp32 dd 0         ; Temporary 32-bit storage
    gst_cents dd 0      ; GST amount in cents
    sst_cents dd 0      ; SST amount in cents
    discount_cents dd 0 ; Member discount amount in cents
    
    ; Variables for displaying tax amounts
    gst_hundreds dw 0
    gst_tens2 db 0
    gst_units2 db 0
    sst_hundreds dw 0
    sst_tens2 db 0
    sst_units2 db 0
    
.code 
main PROC
    mov ax, @data
    mov ds,ax

    ; Clear screen with blue background, white text
    mov ax, 0600h
    mov bh,71h
    mov cx,0h
    mov dx, 184fh
    int 10h
    jmp LOGIN_PROMPT

; LOGIN SYSTEM WITH RETRY MECHANISM 
LOGIN_PROMPT:
    lea dx, msgLoginPrompt
    mov ah, 09h
    int 21h
    jmp USERNAME_INPUT

USERNAME_INPUT: 
    lea dx, msgUser
    mov ah, 09h
    int 21h

    lea dx, user_para
    mov ah,0ah
    int 21h

    mov al, user_act
    mov si, offset user_buf
    mov cx, ax

    lea di, username
    mov bx, 0

check_username:
    mov al, [si]       ; Get input char
    mov bl, [di]       ; Get username char
    cmp bl, 0          ; End of username string?
    je USERNAME_MATCH
    cmp cx, 0          ; End of input string?
    je USERNAME_NO_MATCH
    cmp al, bl         ; Compare input and username char
    jne USERNAME_NO_MATCH
    inc si             ; Move to next input char
    inc di             ; Move to next username char
    dec cx             ; Decrement input length
    jmp check_username

USERNAME_MATCH:
    lea dx, msgMatch
    mov ah, 09h
    int 21h

PASSWORD_PROMPT:
    lea dx, msgPassPrompt
    mov ah, 09h
    int 21h

    mov ah, 07h        ; Get single char, not displayed
    int 21h
    mov pass_input, al

    mov al, pass_input
    mov bl, password   ; password is "A"
    cmp al, bl
    jne PASS_NO_MATCH

    lea dx, msgPassMatch
    mov ah, 09h
    int 21h
    lea dx, msgLogin
    mov ah, 09h
    int 21h
    
    mov ah, 02h ; new line 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    jmp START_ORDER

PASS_NO_MATCH:
    lea dx, msgPassNoMatch
    mov ah, 09h
    int 21h
    ; Retry password input
    jmp PASSWORD_PROMPT

USERNAME_NO_MATCH:
    lea dx, msgNoMatch
    mov ah, 09h
    int 21h
    ; Retry username input
    jmp USERNAME_INPUT

; END LOGIN SYSTEM 

START_ORDER:
    ; ORDERING SYSTEM 

    mov ah, 02h ; new line 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; Welcome to food ordering system
    lea dx, msg 
    int 21h 

    mov ah, 02h ; new line 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 02h ; new line 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; Menu
    lea dx, msg1
    int 21h 

    mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; Chicken Rice Name
    lea dx, chicken_rice_name
    int 21h

    mov ah, 09h ; chicken rice price 
    lea dx, chicken_rice_price 
    int 21h

    mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; Egg Name 
    lea dx, egg_name
    int 21h

    mov ah, 09h ; egg_price 
    lea dx, egg_price 
    int 21h

    mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; Roasted Pork Name 
    lea dx, roasted_pork_name
    int 21h 

    mov ah,09h ; Roasted Pork Price 
    lea dx, roasted_pork_price 
    int 21h

    mov ah, 02h ; new line
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h 

    mov ah, 09h ; Char Xiu Fan Name 
    lea dx, charxiufan_name 
    int 21h 

    mov ah, 09h ; Char Xiu Fan Price 
    lea dx, charxiufan_price
    int 21h

    mov ah, 02h ; new line 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h 

    mov ah, 09h ; Wan Tan Mee Name 
    lea dx, wan_tan_mee_name 
    int 21h 

    mov ah, 09h ; Wan Tan Mee Price
    lea dx, wan_tan_mee_price
    int 21h

    mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; Instruction to let customer select meals 
    lea dx, msg7
    int 21h 

    mov ah,01h ; user input 
    int 21h 
    mov qty,al

    mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    mov ah, 09h
    lea dx, msg8
    int 21h

    cmp qty, '1' ; chicken rice 
    je print_chicken_rice
    cmp qty, '2' ; egg
    je egg
    cmp qty, '3' ; Roasted Pork
    je roasted_pork
    cmp qty, '4' ; Char Xiu Fan 
    je char_xiu_fan
    cmp qty, '5' ; wan tan mee
    je wan_tan_mee 

    jmp exit_program 

print_chicken_rice: ; chicken rice 
    mov ah, 09h
    lea dx, chicken_rice_msg 
    int 21h
    jmp print_current_price 

egg: ; egg
    mov ah, 09h
    lea dx, egg_msg
    int 21h
    jmp print_current_price 

roasted_pork: ; roasted pork
    mov ah,09h
    lea dx, roasted_pork_msg
    int 21h
    jmp print_current_price 

char_xiu_fan: ; char xiu fan 
    mov ah,09h
    lea dx, charxiufan_msg 
    int 21h
    jmp print_current_price 

wan_tan_mee:
    mov ah, 09h
    lea dx, wan_tan_mee_msg
    int 21h
    jmp print_current_price 

print_current_price:
   mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

   mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; current meals is 
    lea dx, msg8
    int 21h

    mov ah,02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    mov ah, 09h ; current price 
    lea dx, current_price 
    int 21h

    jmp print

continue:
    mov ah,02h ; new line
    mov dl,0Ah
    int 21h

    mov ah,09h ; quantity message
    lea dx,qty_msg
    int 21h

    mov ah,0Ah
    lea dx, qty_input
    int 21h

    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h

    ; Convert input quantity to number
    mov si, offset kb_data
    mov cl, act_len
    mov ch, 0
    mov ax, 0
convert_loop:
    mov bl, [si]        
    sub bl, '0'         ; Convert ASCII to number
    mov dl, 10
    mul dl              ; ax = ax * 10
    add al, bl          ; ax = ax + new digit
    adc ah, 0           ; Handle carry
    inc si
    loop convert_loop
    
    mov bx, ax          ; bx = quantity

    ; Calculate price based on selected meal
    cmp qty, '1'
    je calculate_chicken
    cmp qty, '2'
    je calculate_egg
    cmp qty, '3'
    je calculate_pork
    cmp qty, '4'
    je calculate_charxiu
    cmp qty, '5'
    je calculate_wantan
    
calculate_chicken:
    mov ax, 650         ; Chicken rice price (6.50 RM = 650 cents)
    jmp multiply_qty
    
calculate_egg:
    mov ax, 150         ; Egg price (1.50 RM = 150 cents)
    jmp multiply_qty
    
calculate_pork:
    mov ax, 1880        ; Roasted pork price (18.80 RM = 1880 cents)
    jmp multiply_qty
    
calculate_charxiu:
    mov ax, 1100        ; Char xiu fan price (11.00 RM = 1100 cents)
    jmp multiply_qty
    
calculate_wantan:
    mov ax, 750         ; Wan tan mee price (7.50 RM = 750 cents)
    
multiply_qty:
    ; Calculate total: ax * bx
    mul bx              ; dx:ax = price * quantity
    mov word ptr total_cents, ax
    mov word ptr total_cents+2, dx ; Save 32-bit result
    
    ; Convert to RM and cents
    mov bx, 100
    div bx              ; ax = RM part, dx = cents part
    
    mov word ptr hundreds, ax  ; Save RM
    mov ax, dx          ; Get cents part
    mov bl, 10
    div bl              ; al = tens, ah = units
    
    mov tens, al        ; Save tens
    mov units, ah       ; Save units

    ; Display total price
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, total_msg
    int 21h
    
    ; Display RM part
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Display tens
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Display units
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

CALC_TAXES:
    ; Calculate taxes (GST 6% and SST 9%)
    ; Total price is stored in total_cents (32-bit)
    
    ; Calculate GST (6%)
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    mov bx, 6
    call multiply_32_16 ; dx:ax = total_cents * 6
    mov bx, 100
    call divide_32_16   ; dx:ax = (total_cents * 6) / 100
    
    ; Save GST
    mov word ptr gst_cents, ax
    mov word ptr gst_cents+2, dx
    
    ; Convert to RM and cents for display
    mov bx, 100
    div bx              ; ax = RM part, dx = cents part
    
    mov gst_hundreds, ax  ; Save RM
    mov ax, dx          ; Get cents part
    mov bl, 10
    div bl              ; al = tens, ah = units
    
    mov gst_tens2, al   ; Save tens
    mov gst_units2, ah  ; Save units
    
    ; Display GST
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, gst_msg
    int 21h
    
    ; Display GST RM part
    mov ax, gst_hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Display GST tens
    mov al, gst_tens2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Display GST units
    mov al, gst_units2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Calculate SST (9%)
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    mov bx, 9
    call multiply_32_16 ; dx:ax = total_cents * 9
    mov bx, 100
    call divide_32_16   ; dx:ax = (total_cents * 9) / 100
    
    ; Save SST
    mov word ptr sst_cents, ax
    mov word ptr sst_cents+2, dx
    
    ; Convert to RM and cents for display
    mov bx, 100
    div bx              ; ax = RM part, dx = cents part
    
    mov sst_hundreds, ax  ; Save RM
    mov ax, dx          ; Get cents part
    mov bl, 10
    div bl              ; al = tens, ah = units
    
    mov sst_tens2, al   ; Save tens
    mov sst_units2, ah  ; Save units
    
    ; Display SST
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, sst_msg
    int 21h
    
    ; Display SST RM part
    mov ax, sst_hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Display SST tens
    mov al, sst_tens2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Display SST units
    mov al, sst_units2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Calculate total with taxes
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    
    ; Add GST
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    
    ; Add SST
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    
    ; Convert to RM and cents
    mov bx, 100
    div bx              ; ax = RM part, dx = cents part
    
    mov word ptr hundreds, ax  ; Save RM
    mov ax, dx          ; Get cents part
    mov bl, 10
    div bl              ; al = tens, ah = units
    
    mov tens, al        ; Save tens
    mov units, ah       ; Save units
    
    ; Display total with taxes
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, gst_sst_total_msg
    int 21h
    
    ; Display RM part
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Display tens
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Display units
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

    ; Apply automatic member discount (10%)
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    
    ; Add GST and SST
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    
    ; Calculate discount (10%)
    mov bx, 10
    call multiply_32_16 ; dx:ax = total price * 10
    mov bx, 100
    call divide_32_16   ; dx:ax = discount amount (total price * 10 / 100)
    
    ; Save discount amount
    mov word ptr discount_cents, ax
    mov word ptr discount_cents+2, dx
    
    ; Convert to RM and cents for display
    mov bx, 100
    div bx              ; ax = RM part, dx = cents part
    
    mov word ptr hundreds, ax  ; Save RM
    mov ax, dx          ; Get cents part
    mov bl, 10
    div bl              ; al = tens, ah = units
    
    mov tens, al        ; Save tens
    mov units, ah       ; Save units
    
    ; Display discount information
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, member_discount_msg
    int 21h
    
    ; Display discount RM part
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Display discount tens
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Display discount units
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Calculate final price (total with taxes - discount)
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    
    ; Add GST and SST
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    
    ; Subtract discount
    sub ax, word ptr discount_cents
    sbb dx, word ptr discount_cents+2
    
    ; Convert to RM and cents
    mov bx, 100
    div bx              ; ax = RM part, dx = cents part
    
    mov word ptr hundreds, ax  ; Save RM
    mov ax, dx          ; Get cents part
    mov bl, 10
    div bl              ; al = tens, ah = units
    
    mov tens, al        ; Save tens
    mov units, ah       ; Save units
    
    ; Display final price
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, member_final_msg
    int 21h
    
    ; Display RM part
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Display tens
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Display units
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

    jmp exit_program

; 32-bit multiply by 16-bit function
; Input: dx:ax = 32-bit number, bx = 16-bit number
; Output: dx:ax = result
multiply_32_16 PROC
    push cx
    push si
    
    ; Save low 16 bits
    mov si, ax
    
    ; Calculate high 16 bits * bx
    mov ax, dx
    mul bx              ; dx:ax = high 16 bits * bx
    mov cx, ax          ; Save result high 16 bits
    
    ; Calculate low 16 bits * bx
    mov ax, si
    mul bx              ; dx:ax = low 16 bits * bx
    
    ; Combine results: cx:dx + ax
    add dx, cx          ; Add high 16 bits result to dx:ax high part
    
    pop si
    pop cx
    ret
multiply_32_16 ENDP

; 32-bit divide by 16-bit function
; Input: dx:ax = 32-bit number, bx = 16-bit number
; Output: dx:ax = quotient
divide_32_16 PROC
    push cx
    push bx
    
    mov cx, bx          ; Save divisor
    
    ; Perform division
    div cx              ; ax = quotient low 16 bits, dx = remainder
    
    ; For 32-bit division, we need to handle high bits
    ; Simplified assuming result won't exceed 16 bits
    xor dx, dx          ; Clear dx
    
    pop bx
    pop cx
    ret
divide_32_16 ENDP

; Display number function
display_number:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0
    mov bx, 10
div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz div_loop
    
print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print:
    cmp qty, '1' ; chicken rice 
    je display1
    cmp qty, '2' ; egg
    je display2
    cmp qty, '3' ; Roasted Pork
    je display3
    cmp qty, '4' ; Char Xiu Fan 
    je display4
    cmp qty, '5' ; wan tan mee
    je display5

display1:
    mov ah,09h
    lea dx, price_chicken
    int 21h
    jmp continue

display2:
    mov ah,09h
    lea dx, price_egg
    int 21h
    jmp continue

display3:
    mov ah,09h
    lea dx, price_roasted_pork
    int 21h
    jmp continue

display4:
    mov ah,09h
    lea dx, price_charxiufan
    int 21h
    jmp continue

display5:
    mov ah,09h
    lea dx, price_wan_tan_mee
    int 21h
    jmp continue

exit_program:
    mov ax, 4c00h
    int 21h

main  ENDP
    end main