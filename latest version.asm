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
    roasted_pork_price db " = RM 18.80 $"  ; 修改价格从188.00到18.80
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
    price_roasted_pork db ' 18.80$'  ; 修改价格显示从188.00到18.80
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

    qty_input label byte
    max_len db 100
    act_len db ?
    kb_data db 100 DUP('')

    ; 新增变量用于32位计算
    total_cents dd 0    ; 总价格（以分为单位）
    temp32 dd 0         ; 临时32位存储
    gst_cents dd 0      ; GST金额（分）
    sst_cents dd 0      ; SST金额（分）
    
    ; 用于显示税金的变量
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
;    mov ah, 02h ; new line 
;     mov dl, 0Ah
;     int 21h

;    mov ah, 02h ; new line 
;     mov dl, 0Ah
;     int 21h

;     mov ah, 09h ; current meals is 
;     lea dx, msg8
;     int 21h

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

    ; 转换输入的数量为数字
    mov si, offset kb_data
    mov cl, act_len
    mov ch, 0
    mov ax, 0
convert_loop:
    mov bl, [si]        
    sub bl, '0'         ; ASCII 转数字
    mov dl, 10
    mul dl              ; ax = ax * 10
    add al, bl          ; ax = ax + 新数字
    adc ah, 0           ; 处理进位
    inc si
    loop convert_loop
    
    mov bx, ax          ; bx = 数量

    ; 根据选择的餐点进行价格计算
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
    mov ax, 650         ; 鸡肉饭价格 (6.50 RM = 650分)
    jmp multiply_qty
    
calculate_egg:
    mov ax, 150         ; 鸡蛋价格 (1.50 RM = 150分)
    jmp multiply_qty
    
calculate_pork:
    mov ax, 1880        ; 烤猪价格 (18.80 RM = 1880分) - 修改价格
    jmp multiply_qty
    
calculate_charxiu:
    mov ax, 1100        ; 叉烧饭价格 (11.00 RM = 1100分)
    jmp multiply_qty
    
calculate_wantan:
    mov ax, 750         ; 云吞面价格 (7.50 RM = 750分)
    
multiply_qty:
    ; 计算总价: ax * bx
    mul bx              ; dx:ax = 价格 * 数量
    mov word ptr total_cents, ax
    mov word ptr total_cents+2, dx ; 保存32位结果
    
    ; 转换为元和分
    mov bx, 100
    div bx              ; ax = 元部分, dx = 分部分
    
    mov word ptr hundreds, ax  ; 保存元
    mov ax, dx          ; 获取分部分
    mov bl, 10
    div bl              ; al = 角, ah = 分
    
    mov tens, al        ; 保存角
    mov units, ah       ; 保存分

    ; 显示总价
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, total_msg
    int 21h
    
    ; 显示元部分
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; 显示角
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; 显示分
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

CALC_TAXES:
    ; 计算税金 (GST 6% 和 SST 9%)
    ; 总价已存储在 total_cents 中 (32位)
    
    ; 计算 GST (6%)
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    mov bx, 6
    call multiply_32_16 ; dx:ax = total_cents * 6
    mov bx, 100
    call divide_32_16   ; dx:ax = (total_cents * 6) / 100
    
    ; 保存 GST
    mov word ptr gst_cents, ax
    mov word ptr gst_cents+2, dx
    
    ; 转换为元和分显示
    mov bx, 100
    div bx              ; ax = 元部分, dx = 分部分
    
    mov gst_hundreds, ax  ; 保存元
    mov ax, dx          ; 获取分部分
    mov bl, 10
    div bl              ; al = 角, ah = 分
    
    mov gst_tens2, al   ; 保存角
    mov gst_units2, ah  ; 保存分
    
    ; 显示 GST
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, gst_msg
    int 21h
    
    ; 显示GST元部分
    mov ax, gst_hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; 显示GST角
    mov al, gst_tens2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; 显示GST分
    mov al, gst_units2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; 计算 SST (9%)
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    mov bx, 9
    call multiply_32_16 ; dx:ax = total_cents * 9
    mov bx, 100
    call divide_32_16   ; dx:ax = (total_cents * 9) / 100
    
    ; 保存 SST
    mov word ptr sst_cents, ax
    mov word ptr sst_cents+2, dx
    
    ; 转换为元和分显示
    mov bx, 100
    div bx              ; ax = 元部分, dx = 分部分
    
    mov sst_hundreds, ax  ; 保存元
    mov ax, dx          ; 获取分部分
    mov bl, 10
    div bl              ; al = 角, ah = 分
    
    mov sst_tens2, al   ; 保存角
    mov sst_units2, ah  ; 保存分
    
    ; 显示 SST
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, sst_msg
    int 21h
    
    ; 显示SST元部分
    mov ax, sst_hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; 显示SST角
    mov al, sst_tens2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; 显示SST分
    mov al, sst_units2
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; 计算含税总价
    mov ax, word ptr total_cents
    mov dx, word ptr total_cents+2
    
    ; 加上 GST
    add ax, word ptr gst_cents
    adc dx, word ptr gst_cents+2
    
    ; 加上 SST
    add ax, word ptr sst_cents
    adc dx, word ptr sst_cents+2
    
    ; 转换为元和分
    mov bx, 100
    div bx              ; ax = 元部分, dx = 分部分
    
    mov word ptr hundreds, ax  ; 保存元
    mov ax, dx          ; 获取分部分
    mov bl, 10
    div bl              ; al = 角, ah = 分
    
    mov tens, al        ; 保存角
    mov units, ah       ; 保存分
    
    ; 显示含税总价
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    
    mov ah, 09h
    lea dx, gst_sst_total_msg
    int 21h
    
    ; 显示元部分
    mov ax, word ptr hundreds
    call display_number 
    
    mov ah, 09h
    lea dx, dot_msg
    int 21h
    
    ; 显示角
    mov al, tens
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h
    
    ; 显示分
    mov al, units
    add al, '0'
    mov ah, 02h
    mov dl, al
    int 21h

    jmp exit_program

; 32位乘以16位函数
; 输入: dx:ax = 32位数, bx = 16位数
; 输出: dx:ax = 结果
multiply_32_16 PROC
    push cx
    push si
    
    ; 保存低16位
    mov si, ax
    
    ; 计算高16位 * bx
    mov ax, dx
    mul bx              ; dx:ax = 高16位 * bx
    mov cx, ax          ; 保存结果高16位
    
    ; 计算低16位 * bx
    mov ax, si
    mul bx              ; dx:ax = 低16位 * bx
    
    ; 合并结果: cx:dx + ax
    add dx, cx          ; 将高16位的结果加到dx:ax的高位
    
    pop si
    pop cx
    ret
multiply_32_16 ENDP

; 32位除以16位函数
; 输入: dx:ax = 32位数, bx = 16位数
; 输出: dx:ax = 商
divide_32_16 PROC
    push cx
    push bx
    
    mov cx, bx          ; 保存除数
    
    ; 执行除法
    div cx              ; ax = 商低16位, dx = 余数
    
    ; 由于是32位除法，需要处理高位
    ; 这里简化处理，假设结果不会超过16位
    xor dx, dx          ; 清零dx
    
    pop bx
    pop cx
    ret
divide_32_16 ENDP

; 显示数字函数
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