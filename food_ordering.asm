.model small
; .stack 100h
.data
msg db "Welcome to food ordering system $",
msg1 db "MENU $",
chicken_rice_name db "1.Chicken Rice $",
egg_name db "2.Egg $",
roasted_pork_name db "3.Roasted Pork $",
charxiufan_name db "4.Char Xiu Fan $",
wan_tan_mee_name db "5.Wan Tan Mee $",
chicken_rice_price db " = RM 6.50 $",
egg_price db " = RM 1.50 $",
roasted_pork_price db " = RM 188.00 $",
charxiufan_price db " = RM 11.00 $",
wan_tan_mee_price db " = RM 7.50 $",
msg7 db "Please choose your meals (1~5) > $",
msg8 db "Your meal is: $",
chicken_rice_msg db "Chicken Rice $",
egg_msg db "Egg $",
roasted_pork_msg db "Roasted Pork $",
charxiufan_msg db "Char Xiu Fan $",
wan_tan_mee_msg db "Wan Tan Mee $",
current_price db "your current price is : RM $",
price db ?
qty db ? ; to store user input qty

price_chicken db ' 6.50$',
price_egg db ' 1.50$',
price_roasted_pork db ' 188.00$',
price_charxiufan db '11.00$',
price_wan_tan_mee db '7.50$',

.code 
main PROC
    mov ax, @data
    mov ds,ax

    ;clear screen
    mov ax, 0600h
    mov bh,71h
    mov cx,0h
    mov dx, 184fh
    int 10h
    
    ;program start
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
    mov al, 0Ah
    int 21h

    mov ah, 09h ; current price 
    lea dx, current_price 
    int 21h

    mov al,30h
    mov cx, 1

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

    jmp exit_program 
    continue:

    loop print 
    jmp exit_program
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

exit_program:
    mov ax, 4c00h
    int 21h

main  ENDP
    end main 