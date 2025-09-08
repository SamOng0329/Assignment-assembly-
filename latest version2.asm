.model small
.data
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
    pass_input    DB ?              

    msgMatch    DB 0Dh,0Ah,"Username matches!$"
    msgNoMatch  DB 0Dh,0Ah,"USERNAME INVALID Please try again$"
    msgPassMatch DB 0Dh,0Ah,"Password matches!$"
    msgPassNoMatch DB 0Dh,0Ah,"Password does not match.$"
    msgBye      DB 0Dh,0Ah,"Goodbye!$"
    msgLogin    DB 0Dh,0Ah,"Jumping to Order Page...$"

    msg db "Welcome to food ordering system $"
    msg1 db "MENU $"
    chicken_rice_name db "1.Chicken Rice $"
    egg_name db "2.Egg $"
    roasted_pork_name db "3.Roasted Pork $"
    charxiufan_name db "4.Char Xiu Fan $"
    wan_tan_mee_name db "5.Wan Tan Mee $"
    chicken_rice_price db " = RM 6.50 $"
    egg_price db " = RM 1.50 $"
    roasted_pork_price db " = RM 18.80 $"
    charxiufan_price db " = RM 11.00 $"
    wan_tan_mee_price db " = RM 7.50 $"
    msg7 db "Please choose your meals (1~5) > $"
    msg8 db "Your meal is: $"
    invalid_food_msg db "Invalid menu option. Please try again. $"
    invalid_qty_msg db "Invalid quantity. Enter 01~99 only.$"
    chicken_rice_msg db "Chicken Rice $"
    egg_msg db "Egg $"
    roasted_pork_msg db "Roasted Pork $"
    charxiufan_msg db "Char Xiu Fan $"
    wan_tan_mee_msg db "Wan Tan Mee $"
    current_price db "your current price is : RM $"
    price db ?
    qty db ? 

    price_chicken db ' 6.50$'
    price_egg db ' 1.50$'
    price_roasted_pork db ' 18.80$'
    price_charxiufan db '11.00$'
    price_wan_tan_mee db '7.50$'

    qty_msg db "Enter your quantity (integers, 01~99) > $"
    current_meal db "current meal is: $"
    asterisk db " (* $"
    qty_msg2 db " ) $"

    total_msg db "Total price: RM $"
    dot_msg db ".$"
    hundreds dw ?
    tens db ?                        
    units db ?                      

    addon_prompt db 0Dh,0Ah,"Do you want to add an addon? (y/n) > $"
    addon_ordered_msg db 0Dh,0Ah,"Addon ordered! RM 2.00 added.$"
    final_total_msg db 0Dh,0Ah,"Final total price: RM $"
    addon_price dw 200 ; RM 2.00 in cents
    addon_ans db ?

    gst_msg db 0Dh,0Ah,"GST (6%): RM $"
    sst_msg db 0Dh,0Ah,"SST (9%): RM $"
    gst_sst_total_msg db 0Dh,0Ah,"GRAND TOTAL with GST & SST: RM $"
    gst_tens db ?
    sst_tens db ?
    sst_units db ?

    member_discount_msg db 0Dh,0Ah,"Member discount (10%): -RM $"
    member_final_msg db 0Dh,0Ah,"FINAL AMOUNT after member discount: RM $"
    
    total_cents dd 0    
    temp32 dd 0         
    gst_cents dd 0      
    sst_cents dd 0      
    discount_cents dd 0 
    
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

    mov ax, 0600h
    mov bh,71h
    mov cx,0h
    mov dx, 184fh
    int 10h
    jmp LOGIN_PROMPT

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
    mov al, [si]       
    mov bl, [di]       
    cmp bl, 0          
    je USERNAME_MATCH
    cmp cx, 0          
    je USERNAME_NO_MATCH
    cmp al, bl         
    jne USERNAME_NO_MATCH
    inc si             
    inc di             
    dec cx             
    jmp check_username

USERNAME_MATCH:
    lea dx, msgMatch
    mov ah, 09h
    int 21h

PASSWORD_PROMPT:
    lea dx, msgPassPrompt
    mov ah, 09h
    int 21h

    mov ah, 07h        
    int 21h
    mov pass_input, al

    mov al, pass_input
    mov bl, password   
    cmp al, bl
    jne PASS_NO_MATCH

    lea dx, msgPassMatch
    mov ah, 09h
    int 21h
    lea dx, msgLogin
    mov ah, 09h
    int 21h
    
    mov ah, 02h 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    jmp START_ORDER

PASS_NO_MATCH:
    lea dx, msgPassNoMatch
    mov ah, 09h
    int 21h
    jmp PASSWORD_PROMPT

USERNAME_NO_MATCH:
    lea dx, msgNoMatch
    mov ah, 09h
    int 21h
    jmp USERNAME_INPUT

START_ORDER:
    mov ah, 02h 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h 
    lea dx, msg 
    int 21h 

    mov ah, 02h 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 02h 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h 
    lea dx, msg1
    int 21h 

    mov ah, 02h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h 
    lea dx, chicken_rice_name
    int 21h

    mov ah, 09h 
    lea dx, chicken_rice_price 
    int 21h

    mov ah, 02h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h 
    lea dx, egg_name
    int 21h

    mov ah, 09h 
    lea dx, egg_price 
    int 21h

    mov ah, 02h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h 
    lea dx, roasted_pork_name
    int 21h 

    mov ah,09h 
    lea dx, roasted_pork_price 
    int 21h

    mov ah, 02h 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h 

    mov ah, 09h 
    lea dx, charxiufan_name 
    int 21h 

    mov ah, 09h 
    lea dx, charxiufan_price
    int 21h

    mov ah, 02h 
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h 

    mov ah, 09h 
    lea dx, wan_tan_mee_name 
    int 21h 

    mov ah, 09h 
    lea dx, wan_tan_mee_price
    int 21h

    mov ah, 02h 
    mov dl, 0Ah
    int 21h

user_input_menu:
    mov ah, 09h 
    lea dx, msg7
    int 21h 

    mov ah,01h 
    int 21h 
    mov qty,al

    mov ah, 02h 
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

    cmp qty, '1' 
    je print_chicken_rice
    cmp qty, '2' 
    je egg
    cmp qty, '3' 
    je roasted_pork
    cmp qty, '4' 
    je char_xiu_fan
    cmp qty, '5' 
    je wan_tan_mee 

    jmp invalid_option

invalid_option:
    mov ah, 09h
    lea dx, invalid_food_msg
    int 21h

    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    jmp user_input_menu

print_chicken_rice:
    mov ah, 09h
    lea dx, chicken_rice_msg 
    int 21h
    jmp print_current_price 

egg: 
    mov ah, 09h
    lea dx, egg_msg
    int 21h
    jmp print_current_price 

roasted_pork:
    mov ah,09h
    lea dx, roasted_pork_msg
    int 21h
    jmp print_current_price 

char_xiu_fan:
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
    mov ah,02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    mov ah, 09h 
    lea dx, current_price 
    int 21h

    jmp print

continue:
    mov ah,02h 
    mov dl,0Ah
    int 21h

    mov ah,09h 
    lea dx,qty_msg
    int 21h

    mov ah, 01h
    int 21h
    mov bl, al           
    cmp bl, '0'
    jb invalid_qty
    cmp bl, '9'
    ja invalid_qty

    mov ah, 01h
    int 21h
    mov bh, al           
    cmp bh, '0'
    jb invalid_qty
    cmp bh, '9'
    ja invalid_qty

    mov ah, 01h
    int 21h
    cmp al, 0Dh          
    jne invalid_qty

    mov al, bl
    sub al, '0'
    mov ah, 10
    mul ah               
    mov cl, al

    mov al, bh
    sub al, '0'
    add cl, al           

    cmp cl, 1            
    jb invalid_qty
    cmp cl, 99           
    ja invalid_qty

    xor bx, bx           
    mov bl, cl           

    jmp after_qty_input

invalid_qty:
    mov ah, 09h
    lea dx, invalid_qty_msg
    int 21h
    jmp continue

after_qty_input:
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
    mov ax, 650         
    jmp multiply_qty
    
calculate_egg:
    mov ax, 150         
    jmp multiply_qty
    
calculate_pork:
    mov ax, 1880        
    jmp multiply_qty
    
calculate_charxiu:
    mov ax, 1100        
    jmp multiply_qty
    
calculate_wantan:
    mov ax, 750         

multiply_qty:
    mul bx              
    mov word ptr total_cents, ax
    mov word ptr total_cents+2, dx 
    
    mov bx, 100
    div bx              
    mov word ptr hundreds, ax  
    mov ax, dx          
    mov bl, 10
    div bl              
    mov tens, al        
    mov units, ah       

    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, total_msg
    int 21h
    
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

CALC_TAXES:
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    mov bx, 6
    call multiply_32_16 
    mov bx, 100
    call divide_32_16   
    
    mov word ptr gst_cents, ax
    mov word ptr gst_cents+2, dx
    
    mov bx, 100
    div bx              
    mov gst_hundreds, ax  
    mov ax, dx          
    mov bl, 10
    div bl              
    mov gst_tens2, al   
    mov gst_units2, ah  
    
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, gst_msg
    int 21h
    
    mov ax, gst_hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    mov al, gst_tens2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov al, gst_units2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    mov bx, 9
    call multiply_32_16 
    mov bx, 100
    call divide_32_16   
    
    mov word ptr sst_cents, ax
    mov word ptr sst_cents+2, dx
    
    mov bx, 100
    div bx              
    mov sst_hundreds, ax  
    mov ax, dx          
    mov bl, 10
    div bl              
    mov sst_tens2, al   
    mov sst_units2, ah  
    
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, sst_msg
    int 21h
    
    mov ax, sst_hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    mov al, sst_tens2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov al, sst_units2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    mov bx, 100
    div bx              
    mov word ptr hundreds, ax  
    mov ax, dx          
    mov bl, 10
    div bl              
    mov tens, al        
    mov units, ah       
    
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, gst_sst_total_msg
    int 21h
    
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    mov bx, 10
    call multiply_32_16 
    mov bx, 100
    call divide_32_16   
    
    mov word ptr discount_cents, ax
    mov word ptr discount_cents+2, dx
    
    mov bx, 100
    div bx              
    mov word ptr hundreds, ax  
    mov ax, dx          
    mov bl, 10
    div bl              
    mov tens, al        
    mov units, ah       
    
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, member_discount_msg
    int 21h
    
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    sub ax, word ptr discount_cents
    sbb dx, word ptr discount_cents+2
    mov bx, 100
    div bx              
    mov word ptr hundreds, ax  
    mov ax, dx          
    mov bl, 10
    div bl              
    mov tens, al        
    mov units, ah       
    
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, member_final_msg
    int 21h
    
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

    jmp exit_program

multiply_32_16 PROC
    push cx
    push si

    mov si, ax
    mov ax, dx
    mul bx              
    mov cx, ax          

    mov ax, si
    mul bx              
    add dx, cx          

    pop si
    pop cx
    ret
multiply_32_16 ENDP

divide_32_16 PROC
    push cx
    push bx

    mov cx, bx          
    div cx              
    xor dx, dx          

    pop bx
    pop cx
    ret
divide_32_16 ENDP

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
    cmp qty, '1' 
    je display1
    cmp qty, '2' 
    je display2
    cmp qty, '3' 
    je display3
    cmp qty, '4' 
    je display4
    cmp qty, '5' 
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