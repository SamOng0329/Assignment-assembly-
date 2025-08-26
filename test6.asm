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
invalid_msg db "Invalid menu option. Please try again. $",
price db ?
qty db ? ; to store user input qty

price_chicken db ' 6.50$',
price_egg db ' 1.50$',
price_roasted_pork db ' 188.00$',
price_charxiufan db '11.00$',
price_wan_tan_mee db '7.50$',

qty_msg db "Enter your quantity (integers) > $",
current_meal db "current meal is: $",
asterisk db " (* $",
qty_msg2 db " ) $",

;new modify
total_msg db "Total price: RM $",
dot_msg db ".$",
hundreds dw ?                ; 改为word类型，因为可能存储较大的值
tens db ?                        
units db ?                      
decimal db ?                  


qty_input label byte
max_len db 100
act_len db ?
kb_data db 100 DUP('')

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
    jmp menu_user_input 


menu_user_input:
    mov ah, 09h ; Instruction to let customer select meals 
    lea dx, msg7
    int 21h 

    mov ah,01h ; user input 
    int 21h 
    mov qty,al

    mov ah, 02h ; new line 
    mov dl, 0Ah
    int 21h

    mov ah, 02h ; new line
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    mov ah, 09h ;current meal msg
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

    jmp menu_invalid

menu_invalid:
    mov ah, 09h
    lea dx, invalid_msg
    int 21h

    mov ah, 02h ; new line
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    jmp menu_user_input

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
;    mov ah, 02h ; new line 
;     mov dl, 0Ah
;     int 21h

;    mov ah, 02h ; new line 
;     mov dl, 0Ah
;     int 21h

    ; mov ah, 09h ; current meals is 
    ; lea dx, msg8
    ; int 21h

    mov ah,02h
    mov dl, 0Dh
    int 21h
    mov al, 0Ah
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

    ; 修改开始
    mov si, offset kb_data
    mov cl, act_len
    mov ch, 0
    mov ax, 0
convert_loop:
    mov bl, [si]        
    sub bl, '0'         ; ASCII To Arithmetic
    mov dl, 10
    mul dl              ; ax = ax * 10
    add al, bl          ; ax = ax + 新数字
    adc ah, 0           ; 处理进位
    inc si
    loop convert_loop
    
    mov bx, ax          

    ; 根据选择的餐点进行乘法计算
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
    mov ax, bx          ; 数量在bx中
    mov bx, 650         ; (RM 6.50)
    mul bx              ; dx:ax = qty * rm
    jmp process_total
    
calculate_egg:
    mov ax, bx
    mov bx, 150         ; (RM 1.50)
    mul bx
    jmp process_total
    
calculate_pork:
    mov ax, bx
    mov bx, 18800       ; (RM 188.00)
    mul bx              ; dx:ax = qty * price
    jmp process_total
    
calculate_charxiu:
    mov ax, bx
    mov bx, 1100        ; (RM 11.00)
    mul bx
    jmp process_total
    
calculate_wantan:
    mov ax, bx
    mov bx, 750         ; (RM 7.50)
    mul bx
    
process_total:
    ; 处理32位结果（DX:AX）
    mov cx, 100         ; 除数为100
    div cx              ; ax = DX:AX / 100，dx = 余数
    
    ; 保存结果
    mov word ptr hundreds, ax  ; 保存整数部分
    mov ax, dx          ; 将余数移动到AX
    mov bl, 10
    div bl              ; al = 小数第一位, ah = 小数第二位
    
    mov tens, al        ; 保存小数第一位
    mov units, ah       ; 保存小数第二位

    ; Total Price
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, total_msg
    int 21h
    
    ; Display RM
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; Show decimal
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; Show Float
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    jmp exit_program

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
    ; 修改结束

    continue2:
    mov ah,09h
    lea dx, current_meal
    int 21h

    cmp qty, '1'
    je show_chicken_rice
    cmp qty, '2'
    je show_egg
    cmp qty, '3'
    je show_roasted_pork
    cmp qty, '4'
    je show_char_xiu_fan
    cmp qty, '5'
    je show_wan_tan_mee

    jmp show_asterisk

    show_chicken_rice:
    mov ah, 09h
    lea dx, chicken_rice_msg
    int 21h
    jmp show_asterisk

    show_egg:
    mov ah,09h
    lea dx, egg_msg
    int 21h
    jmp show_asterisk

    show_roasted_pork:
    mov ah,09h
    lea dx, roasted_pork_msg
    int 21h
    jmp show_asterisk

    show_char_xiu_fan:
    mov ah,09h
    lea dx, charxiufan_msg
    int 21h
    jmp show_asterisk

    show_wan_tan_mee:
    mov ah,09h
    lea dx, wan_tan_mee_msg
    int 21h
    jmp show_asterisk

    show_asterisk:
    mov ah,09h
    lea dx, asterisk
    int 21h

    mov cl,act_len ; output user stirng input
    mov si,0

    m2: mov ah, 02h
    mov dl, kb_data[si]
    int 21h

    inc si
    loop m2

    mov ah,09h
    lea dx, qty_msg2
    int 21h

    jmp exit_program 

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
    jmp continue    ; 修复：添加这行跳转指令，确保选择5后继续执行

exit_program:
    mov ax, 4c00h
    int 21h

main  ENDP
    end main
