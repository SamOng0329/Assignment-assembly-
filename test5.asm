; =============================================================================
; FILE: food_ordering_system.asm
; DESCRIPTION: A simple food ordering system in Assembly (MASM)
; AUTHOR: [Your Name Here]
; =============================================================================

.model small
.stack 100h
.data
    ; --- All data definitions are now grouped here for better readability ---

    ; --- Display Messages ---
    msg db "Welcome to the food ordering system $", 0Dh, 0Ah, 0Dh, 0Ah
    msg1 db "MENU", 0Dh, 0Ah, "--------------------", 0Dh, 0Ah, "$"
    chicken_rice_name db "1. Chicken Rice     ", "$"
    egg_name db "2. Egg                ", "$"
    roasted_pork_name db "3. Roasted Pork     ", "$"
    charxiufan_name db "4. Char Xiu Fan     ", "$"
    wan_tan_mee_name db "5. Wan Tan Mee      ", "$"
    chicken_rice_price db "= RM 6.50", 0Dh, 0Ah, "$"
    egg_price db "= RM 1.50", 0Dh, 0Ah, "$"
    roasted_pork_price db "= RM 188.00", 0Dh, 0Ah, "$"
    charxiufan_price db "= RM 11.00", 0Dh, 0Ah, "$"
    wan_tan_mee_price db "= RM 7.50", 0Dh, 0Ah, 0Dh, 0Ah, "$"
    msg7 db "Please choose your meal (1-5) > $"
    msg8 db 0Dh, 0Ah, "You have selected: $"
    qty_msg db 0Dh, 0Ah, "Enter quantity > $"
    final_total_msg db 0Dh, 0Ah, "Your final total is: RM $"

    ; --- Variables for storing choices and results ---
    choice      db ?
    num_qty     dw 0  ; To store the quantity as a number
    total_cost  dw 0  ; To store the final calculated cost in cents
    saved_ringgit dw 0
    saved_cents dw 0
    digit_buffer db 10 dup(0)
    
    ; --- Prices stored in cents to make math easier and avoid floating-point issues ---
    price_chicken_cents       dw 650    ; RM 6.50
    price_egg_cents           dw 150    ; RM 1.50
    price_roasted_pork_cents  dw 18800  ; RM 188.00
    price_charxiufan_cents    dw 1100   ; RM 11.00
    price_wan_tan_mee_cents   dw 750    ; RM 7.50

    ; --- Buffer for reading quantity from keyboard (DOS buffered input) ---
    qty_input   label byte
    max_len     db 5
    act_len     db ?
    kb_data     db 5 dup('$')

.code
main PROC
    ; Set up the data segment
    mov ax, @data
    mov ds, ax

    ; --- Display Welcome Message and Menu ---
    mov ah, 09h
    lea dx, msg
    int 21h
    lea dx, msg1
    int 21h
    lea dx, chicken_rice_name
    int 21h
    lea dx, chicken_rice_price
    int 21h
    lea dx, egg_name
    int 21h
    lea dx, egg_price
    int 21h
    lea dx, roasted_pork_name
    int 21h
    lea dx, roasted_pork_price
    int 21h
    lea dx, charxiufan_name
    int 21h
    lea dx, charxiufan_price
    int 21h
    lea dx, wan_tan_mee_name
    int 21h
    lea dx, wan_tan_mee_price
    int 21h

    ; --- Get User's Menu Choice ---
    mov ah, 09h
    lea dx, msg7
    int 21h
    mov ah, 01h      ; Read a single character from keyboard
    int 21h
    mov choice, al

    ; --- Get Quantity ---
    mov ah, 09h
    lea dx, qty_msg
    int 21h
    mov ah, 0Ah             ; Read a string from keyboard
    lea dx, qty_input
    int 21h

    ; --- FIXED: Convert Quantity String to a Number (ASCII to Integer) ---
    lea si, kb_data         ; Point SI to the start of the input string
    mov cx, 0               ; CX is now the digit counter for printing
    mov bx, 0               ; BX will hold the final number
    
    mov ch, act_len         ; Load length into CH
    xor cl, cl              ; Clear CL
    mov cx, cx              ; Now CX = act_len
    
ConvertLoop:
    mov al, [si]            ; Get a character
    sub al, '0'             ; Convert from ASCII '0'-'9' to number 0-9
    
    mov dx, 0
    mov ax, bx              ; Move current total to AX
    mov cx, 10
    mul cx                  ; AX = BX * 10
    mov bx, ax              ; Store new total
    
    mov ax, 0
    mov al, [si]
    sub al, '0'
    add bx, ax              ; Add the new digit to the total

    add si, 1               ; Move to the next character
    mov ch, act_len         ; Reset loop count
    xor cl, cl
    mov cx, cx
    
    ; The loop condition needs to be rewritten without `loop`
    cmp si, offset kb_data + act_len
    jb ConvertLoop
    
    mov num_qty, bx         ; Store the final numeric quantity

    ; --- Calculate Total Cost ---
    mov ax, 0               ; Clear AX for the price
    mov bl, choice          ; Move user's choice into BL

    ; Use conditional jumps to select the correct price
    cmp bl, '1'
    je set_price_1
    cmp bl, '2'
    je set_price_2
    cmp bl, '3'
    je set_price_3
    cmp bl, '4'
    je set_price_4
    cmp bl, '5'
    je set_price_5
    jmp exit_program        ; Invalid choice, exit

set_price_1:
    mov ax, price_chicken_cents
    jmp do_calc
set_price_2:
    mov ax, price_egg_cents
    jmp do_calc
set_price_3:
    mov ax, price_roasted_pork_cents
    jmp do_calc
set_price_4:
    mov ax, price_charxiufan_cents
    jmp do_calc
set_price_5:
    mov ax, price_wan_tan_mee_cents
    
do_calc:
    mov bx, num_qty         ; Move quantity into BX
    mul bx                  ; AX = AX (price) * BX (quantity)
    mov total_cost, ax      ; Store the final total

    ; --- Display the final total message ---
    mov ah, 09h
    lea dx, final_total_msg
    int 21h

    ; --- FIXED: INLINE PRINT TOTAL LOGIC ---
    mov ax, total_cost
    
    ; Divide total cents by 100 to get Ringgit and Cents
    mov dx, 0               ; Clear DX before division
    mov bx, 100             ; Divisor
    div bx                  ; AX = Quotient (Ringgit), DX = Remainder (Cents)
    
    mov saved_ringgit, ax   ; Save the ringgit part in a variable
    mov saved_cents, dx     ; Save the cents part in a variable
    
    ; --- FIXED: INLINE PRINT NUMBER LOGIC for Ringgit ---
    mov ax, saved_ringgit
    mov si, offset digit_buffer
    
    RinggitDigitLoop:
        mov dx, 0
        mov bx, 10
        div bx
        mov [si], dx
        add si, 1
        cmp ax, 0
        jne RinggitDigitLoop
        
    mov cx, 0
    RinggitPrintLoop:
        mov dx, [si-1]
        add dl, '0'
        mov ah, 02h
        int 21h
        add si, -1
        add cx, 1
        cmp cx, 0
        jnz RinggitPrintLoop
    
    ; --- Print decimal point ---
    mov ah, 02h
    mov dl, '.'
    int 21h
    
    ; --- FIXED: INLINE PRINT NUMBER LOGIC for Cents ---
    mov ax, saved_cents
    
    ; Check for leading zero
    cmp ax, 10
    ja SkipZero
    mov ah, 02h
    mov dl, '0'
    int 21h
    
SkipZero:
    ; Print the cents part
    mov si, offset digit_buffer
    CentsDigitLoop:
        mov dx, 0
        mov bx, 10
        div bx
        mov [si], dx
        add si, 1
        cmp ax, 0
        jne CentsDigitLoop
        
    mov cx, 0
    CentsPrintLoop:
        mov dx, [si-1]
        add dl, '0'
        mov ah, 02h
        int 21h
        add si, -1
        add cx, 1
        cmp cx, 0
        jnz CentsPrintLoop
    
exit_program:
    mov ax, 4c00h
    int 21h
main ENDP
end main
