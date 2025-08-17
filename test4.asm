.model small
.data
    menu_msg db "Menu:", 0Dh, 0Ah, "1. Chicken Rice (RM 6.50)", 0Dh, 0Ah, "2. Egg (RM 1.50)", 0Dh, 0Ah, "3. Add-on (RM 5.50)", 0Dh, 0Ah, "$"
    select_msg db 0Dh, 0Ah, "Select item (1-3): $"
    chosen_msg db 0Dh, 0Ah, "You chose: $"
    price_msg db "Current price: RM $"
    add_more_msg db 0Dh, 0Ah, "Add more? (y/n): $"
    total_msg db 0Dh, 0Ah, "Total price: RM $"
    chicken_rice_name db "Chicken Rice $"
    egg_name db "Egg $"
    addon_name db "Add-on $"
    invalid_msg db "Invalid selection. Please choose again.$"
    chicken_rice_price dw 650   ; 6.50
    egg_price dw 150            ; 1.50
    addon_price dw 550          ; 5.50
    total_price dw 0
    item_price dw 0
    input db ?
    more db ?

.code 
main proc
    mov ax, @data
    mov ds, ax

main_loop:
    ;print menu
    mov ah, 09h
    lea dx, menu_msg
    int 21h
    
    mov ah, 09h
    lea dx, select_msg
    int 21h

    mov ah, 01h
    int 21h
    mov input, al

invalid: 
    ;Print invalid message
    mov ah, 09h
    lea dx, invalid_msg 
    int 21h
    jmp main_loop

; --- selection handling ---
    cmp input, '1'
    je select_chicken_rice
    cmp input, '2'
    je select_egg
    cmp input, '3'
    je select_addon
    jmp invalid

select_chicken_rice:
    mov ax, chicken_rice_price
    mov item_price, ax
    mov ax, item_price
    lea dx, chicken_rice_name
    jmp print_item

select_egg:
    mov ax, egg_price
    mov item_price, ax
    lea dx, egg_name
    jmp print_item

select_addon:
    mov ax, addon_price
    mov item_price, ax
    lea dx, addon_name
    jmp print_item

print_item:
    mov ah, 09h
    int 21h
    jmp exit_program

exit_program:
    mov ax, 4c00h
    int 21h
main endp
    end main