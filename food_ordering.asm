.model small
; .stack 100h

.data
msg db "Welcome to food ordering system $",               ; Welcome message
msg1 db "MENU $",                                        ; Menu header

chicken_rice_name db "1.Chicken Rice $",                 ; Item names
egg_name db "2.Egg $"
roasted_pork_name db "3.Roasted Pork $"
charxiufan_name db "4.Char Xiu Fan $"
wan_tan_mee_name db "5.Wan Tan Mee $"

chicken_rice_price db " = RM 6.50 $",                    ; Item prices
egg_price db " = RM 1.50 $"
roasted_pork_price db " = RM 188.00 $"
charxiufan_price db " = RM 11.00 $"
wan_tan_mee_price db " = RM 7.50 $"

msg7 db "Please choose your meals (1~5) > $",            ; Prompt for meal selection
msg8 db "Your meal is: $",                               ; Confirmation message

chicken_rice_msg db "Chicken Rice $",                    ; Message for meal selection
egg_msg db "Egg $"
roasted_pork_msg db "Roasted Pork $"
charxiufan_msg db "Char Xiu Fan $"
wan_tan_mee_msg db "Wan Tan Mee $"

current_price db "your current price is : RM $",         ; Message to show current price
price db ?                                               ; Variable to store price (unused)
qty db ?                                                 ; Variable to store user choice

price_chicken db ' 6.50$',                               ; Prices as strings for display
price_egg db ' 1.50$'
price_roasted_pork db ' 188.00$'
price_charxiufan db '11.00$'
price_wan_tan_mee db '7.50$'

qty_msg db "Enter your quantity (integers) > $",         ; Prompt for quantity
current_meal db "current meal is: $",                    ; Current meal message
asterisk db " (* $",                                     ; Message for showing quantity
qty_msg2 db " ) $",                                      ; Message for showing quantity

qty_input label byte                                     ; Buffer for quantity input
max_len db 100
act_len db ?
kb_data db 100 DUP('')                                   ; Stores quantity input string

.code 
main PROC
    mov ax, @data
    mov ds,ax

    ;------------- Screen Clear Section -------------
    mov ax, 0600h            ; Scroll entire window up
    mov bh,71h               ; Set background/foreground color
    mov cx,0h                ; Upper left corner
    mov dx, 184fh            ; Lower right corner
    int 10h                  ; Call BIOS interrupt (clear screen)
    
    ;------------- Program Start Section -------------
    mov ah, 09h              ; Print welcome message
    lea dx, msg 
    int 21h 

    mov ah, 02h              ; Print new line (carriage return)
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah              ; Print new line (line feed)
    int 21h

    mov ah, 02h              ; Print new line again
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Print menu header
    lea dx, msg1
    int 21h 

    mov ah, 02h              ; Print new line
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Print Chicken Rice name and price
    lea dx, chicken_rice_name
    int 21h
    mov ah, 09h
    lea dx, chicken_rice_price 
    int 21h

    mov ah, 02h              ; New line
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Print Egg name and price
    lea dx, egg_name
    int 21h
    mov ah, 09h
    lea dx, egg_price 
    int 21h

    mov ah, 02h              ; New line
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Print Roasted Pork name and price
    lea dx, roasted_pork_name
    int 21h 
    mov ah,09h
    lea dx, roasted_pork_price 
    int 21h

    mov ah, 02h              ; New line (carriage return and line feed)
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h 

    mov ah, 09h              ; Print Char Xiu Fan name and price
    lea dx, charxiufan_name 
    int 21h 
    mov ah, 09h
    lea dx, charxiufan_price
    int 21h

    mov ah, 02h              ; New line
    mov dl, 0Dh
    int 21h 
    mov dl, 0Ah
    int 21h 

    mov ah, 09h              ; Print Wan Tan Mee name and price
    lea dx, wan_tan_mee_name 
    int 21h 
    mov ah, 09h
    lea dx, wan_tan_mee_price
    int 21h

    mov ah, 02h              ; New line
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Prompt user for meal selection
    lea dx, msg7
    int 21h 

    mov ah,01h               ; Wait for key input (1~5)
    int 21h 
    mov qty,al               ; Save user's choice in 'qty'

    mov ah, 02h              ; New line
    mov dl, 0Ah
    int 21h

    mov ah, 02h              ; New line (carriage return and line feed)
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Print confirmation message
    lea dx, msg8
    int 21h

    ;------------- Display which meal was chosen -------------
    cmp qty, '1'             ; Check if Chicken Rice
    je print_chicken_rice
    cmp qty, '2'             ; Check if Egg
    je egg
    cmp qty, '3'             ; Check if Roasted Pork
    je roasted_pork
    cmp qty, '4'             ; Check if Char Xiu Fan
    je char_xiu_fan
    cmp qty, '5'             ; Check if Wan Tan Mee
    je wan_tan_mee 

    jmp exit_program         ; If not 1~5, exit

print_chicken_rice: 
    mov ah, 09h              ; Print Chicken Rice confirmation
    lea dx, chicken_rice_msg 
    int 21h
    jmp print_current_price  ; Jump to print price

egg: 
    mov ah, 09h              ; Print Egg confirmation
    lea dx, egg_msg
    int 21h
    jmp print_current_price 

roasted_pork: 
    mov ah,09h               ; Print Roasted Pork confirmation
    lea dx, roasted_pork_msg
    int 21h
    jmp print_current_price 

char_xiu_fan: 
    mov ah,09h               ; Print Char Xiu Fan confirmation
    lea dx, charxiufan_msg 
    int 21h
    jmp print_current_price 

wan_tan_mee:
    mov ah, 09h              ; Print Wan Tan Mee confirmation
    lea dx, wan_tan_mee_msg
    int 21h
    jmp print_current_price 

print_current_price:
    mov ah, 02h              ; New line
    mov dl, 0Ah
    int 21h

    mov ah, 02h              ; New line again
    mov dl, 0Ah
    int 21h

    mov ah, 09h              ; Print "current meals is"
    lea dx, msg8
    int 21h

    mov ah,02h               ; New line (carriage return and line feed)
    mov dl, 0Dh
    int 21h
    mov al, 0Ah
    int 21h

    mov ah, 09h              ; Print current price message
    lea dx, current_price 
    int 21h

    jmp print                ; Jump to price display

continue:
    mov ah,02h               ; New line
    mov dl,0Ah
    int 21h

    mov ah,09h               ; Prompt for quantity
    lea dx,qty_msg
    int 21h

    mov ah,0Ah               ; Input string for quantity
    lea dx, qty_input
    int 21h

    mov ah, 02h              ; New line
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h

continue2:
    mov ah,09h               ; Print current meal
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
    mov ah,09h               ; Print "(*"
    lea dx, asterisk
    int 21h

    mov cl,act_len           ; Output entered quantity characters
    mov si,0

m2: mov ah, 02h              ; Print each character entered
    mov dl, kb_data[si]
    int 21h

    inc si
    loop m2

    mov ah,09h               ; Print ")"
    lea dx, qty_msg2
    int 21h

    ; No further calculation here
    jmp exit_program 

    mov al,30h
    mov cx, 1

print:                       ; Print price based on selection

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

exit_program:
    mov ax, 4c00h            ; Exit program
    int 21h

main  ENDP
    end main