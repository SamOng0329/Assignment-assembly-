.model small
.stack 100h
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
    chicken_rice_price dw 650   ; 6.50
    egg_price dw 150            ; 1.50
    addon_price dw 550          ; 5.50
    total_price dw 0
    item_price dw 0
    input db ?
    more db ?
    rm_digits db 5 dup(?)       ; buffer for RM digits
    cents_digits db 2 dup(?)    ; buffer for cents
.code
main proc
    mov ax, @data
    mov ds, ax

main_loop:
    ; print menu
    mov ah, 09h
    lea dx, menu_msg
    int 21h

    mov ah, 09h
    lea dx, select_msg
    int 21h

    ; read selection
    mov ah, 01h
    int 21h
    mov input, al

    ; --- selection handling ---
    cmp input, '1'
    jne not_1
        ; chicken rice
        mov ah, 09h
        lea dx, chosen_msg
        int 21h
        mov ah, 09h
        lea dx, chicken_rice_name
        int 21h
        mov ax, chicken_rice_price
        mov item_price, ax
        jmp near ptr show_price
not_1:
    cmp input, '2'
    jne not_2
        ; egg
        mov ah, 09h
        lea dx, chosen_msg
        int 21h
        mov ah, 09h
        lea dx, egg_name
        int 21h
        mov ax, egg_price
        mov item_price, ax
        jmp near ptr show_price
not_2:
    cmp input, '3'
    jne invalid
        ; addon
        mov ah, 09h
        lea dx, chosen_msg
        int 21h
        mov ah, 09h
        lea dx, addon_name
        int 21h
        mov ax, addon_price
        mov item_price, ax
        jmp near ptr show_price

invalid:
    jmp near ptr main_loop

show_price:
    ; show current item price
    mov ah, 09h
    lea dx, price_msg
    int 21h

    mov ax, item_price
    call print_price

    ; accumulate total
    mov ax, total_price
    add ax, item_price
    mov total_price, ax

    ; ask to add more
    mov ah, 09h
    lea dx, add_more_msg
    int 21h

    mov ah, 01h
    int 21h
    mov more, al

    cmp more, 'y'
    jne chk_Y
        jmp near ptr main_loop
chk_Y:
    cmp more, 'Y'
    jne show_total
        jmp near ptr main_loop

show_total:
    mov ah, 09h
    lea dx, total_msg
    int 21h
    mov ax, total_price
    call print_price

    mov ax, 4c00h
    int 21h
main endp

; ======================================
; print_price
; Input: AX = price in cents
; Output: prints "x.yy"
; ======================================
print_price proc
    ; AX = price in cents
    mov bx, 100
    xor dx, dx
    div bx        ; AX = RM (quotient), DX = cents (remainder)

    ; ----- Print RM -----
    mov si, offset rm_digits
    mov cx, 0
    mov bx, 10
    mov di, ax          ; save RM
    mov ax, di
rm_digit_loop:
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder
    add dl, '0'
    mov [si], dl
    inc si
    inc cx
    cmp ax, 0
    jne rm_digit_loop

    ; print RM digits in reverse
    mov si, offset rm_digits
    add si, cx
    dec si
print_rm_digits:
    mov dl, [si]
    mov ah, 02h
    int 21h
    dec si
    loop print_rm_digits

    ; ----- Print '.' -----
    mov dl, '.'
    mov ah, 02h
    int 21h

    ; ----- Print cents -----
    mov ax, dx          ; cents (0–99)
    mov bx, 10
    mov si, offset cents_digits
    mov cx, 2
cents_digit_loop:
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder
    add dl, '0'
    mov [si], dl
    inc si
    dec cx
    jnz cents_digit_loop

    ; print cents digits in reverse
    mov si, offset cents_digits
    add si, 2
    dec si
    mov cx, 2
print_cents_digits:
    mov dl, [si]
    mov ah, 02h
    int 21h
    dec si
    loop print_cents_digits

    ret
print_price endp

end main
