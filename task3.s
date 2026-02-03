@ Command Definitions in .data Section

    @ for converting number into hexadecimal

    hex_cmd: .ascii "hex"      
    hex_len = . - hex_cmd

    @ for adding two numbers 

    add_cmd: .ascii "add"
    add_len = . - add_cmd

    @ used to convert 0 to 15 into 0 to F

    hex_digits: .ascii "0123456789ABCDEF" @ For printing hex digits

    @ used to print "0x" before hex-values

    hex_prefix: .ascii "0x"
    hex_prefix_len = . - hex_prefix

@ Adds conditional checks for custom commands in the main command handler

@ if the command is "hex", it calls do_hex
@ if it's "add", it calls do_add
@ if not matched, it falls to unknown_command

check_hex:
    ldr r0, =input_buffer
    ldr r1, =hex_cmd
    mov r2, #hex_len
    bl compare_strings

    cmp r0, #1
    bne check_add

    bl do_hex

    pop {pc}

check_add:
    ldr r0, =input_buffer
    ldr r1, =add_cmd
    mov r2, #add_len
    bl compare_strings

    cmp r0, #1
    bne unknown_command

    bl do_add

    pop {pc}


@ Converts a decimal number to hexadecimal format:

do_hex:
    push {r4, r5, r6, lr}

    ldr r0, =input_buffer
    add r0, r0, #4                @ Skip "hex " part

    bl get_number                 @ Get number after command

    cmp r0, #-1
    beq hex_error

    mov r4, r0                    @ Save number

    mov r0, #1
    ldr r1, =hex_prefix
    mov r2, #hex_prefix_len
    mov r7, #4
    swi 0                         @ Print "0x"

    mov r0, r4
    bl print_hex_number           @ Print hex number

    mov r0, #1
    ldr r1, =newline
    mov r2, #newline_len
    mov r7, #4
    swi 0                        @ Print newline

    pop {r4, r5, r6, pc}

@ If no valid number is found after "hex" , shows the "Unknown command" message

hex_error:
    mov r0, #1
    ldr r1, =unknown_msg
    mov r2, #unknown_msg_len
    mov r7, #4
    swi 0

    pop {r4, r5, r6, pc}

print_hex_number:
    push {r4, r5, r6, lr}

    mov r4, r0                    @ Number to print
    ldr r5, =temp_buffer          @ Buffer address
    mov r6, #0                    @ Count digits

    cmp r4, #0                    @ If number is zero
    bne hex_loop
    mov r1, #'0'
    strb r1, [r5]
    mov r6, #1
    b hex_print

hex_loop:
    cmp r4, #0
    beq hex_print

    and r1, r4, #0xF              @ Extract last 4 bits
    ldr r2, =hex_digits
    ldrb r1, [r2, r1]             @ Get hex digit char

    strb r1, [r5, r6]             @ Store char in buffer
    add r6, r6, #1                @ Increase digit count

    lsr r4, r4, #4                @ Shift right 4 bits
    b hex_loop

hex_print:
    mov r0, #1                    @ stdout
    mov r7, #4                    @ syscall write

hex_print_loop:
    cmp r6, #0
    beq hex_done

    sub r6, r6, #1
    add r1, r5, r6                @ Point to last stored digit
    mov r2, #1
    swi 0                        @ Print one char

    b hex_print_loop

hex_done:
    pop {r4, r5, r6, pc}


@ Adds two numbers and prints the result:

do_add:
    push {r4, r5, r6, lr}

    ldr r0, =input_buffer
    add r0, r0, #4                @ Skip "add " part

    bl get_number                 @ Get first number
    cmp r0, #-1
    beq add_error
    mov r4, r0                    @ Save first number

    ldr r0, =input_buffer
    add r0, r0, #4
    bl skip_first_number          @ Move pointer past first number & spaces

    bl get_number                 @ Get second number
    cmp r0, #-1
    beq add_error

    add r4, r4, r0               @ Add both numbers

    mov r0, r4
    bl print_number              @ Print result

    mov r0, #1
    ldr r1, =newline
    mov r2, #newline_len
    mov r7, #4
    swi 0                        @ Print newline

    pop {r4, r5, r6, pc}

add_error:
    mov r0, #1
    ldr r1, =unknown_msg
    mov r2, #unknown_msg_len
    mov r7, #4
    swi 0

    pop {r4, r5, r6, pc}

print_number:
    push {r4, r5, r6, lr}

    mov r4, r0                    @ Number to print
    ldr r5, =temp_buffer          @ Buffer for digits
    mov r6, #0                    @ Digit count

    cmp r4, #0                    @ If zero, print '0'
    bne num_loop
    mov r1, #'0'
    strb r1, [r5]
    mov r6, #1
    b num_print

num_loop:
    cmp r4, #0
    beq num_print

    mov r1, #10
    bl divide_by_ten              @ Divide number by 10

    add r1, r1, #'0'              @ Convert remainder to char
    strb r1, [r5, r6]             @ Store digit char
    add r6, r6, #1                @ Increase count

    mov r4, r0                    @ Update number to quotient
    b num_loop

num_print:
    mov r0, #1
    mov r7, #4

num_print_loop:
    cmp r6, #0
    beq num_done

    sub r6, r6, #1
    add r1, r5, r6
    mov r2, #1
    swi 0

    b num_print_loop

num_done:
    pop {r4, r5, r6, pc}

divide_by_ten:
    push {r3, lr}

    mov r0, #0                    @ Quotient
    mov r1, r4                    @ Remainder

div_loop:
    cmp r1, #10
    blt div_done
    sub r1, r1, #10
    add r0, r0, #1
    b div_loop

div_done:
    pop {r3, pc}

@ Supporting Functions
@ Number parsing and utility functions used by custom commands:

get_number:
    push {r4, r5, r6, lr}

    mov r4, #0                    @ Number accumulator
    mov r5, #0                    @ Index counter
    mov r6, r0                    @ Pointer to string

get_num_loop:
    ldrb r1, [r6, r5]             @ Load current char
    cmp r1, #0                    @ End of string?
    beq get_num_done
    cmp r1, #' '                  @ Space means end of number
    beq get_num_done

    cmp r1, #'0'                  @ Check if digit
    blt get_num_error
    cmp r1, #'9'
    bgt get_num_error

    sub r1, r1, #'0'              @ Convert char to number

    mov r2, #10
    mul r3, r4, r2                @ Multiply accumulator by 10
    add r4, r3, r1                @ Add digit value

    add r5, r5, #1                @ Move to next char
    b get_num_loop

get_num_done:
    cmp r5, #0                    @ No digits found?
    beq get_num_error
    mov r0, r4                    @ Return number
    pop {r4, r5, r6, pc}

get_num_error:
    mov r0, #-1                   @ Error code
    pop {r4, r5, r6, pc}

skip_first_number:
    push {r1, lr}

skip_loop:
    ldrb r1, [r0]                 @ Load char at pointer
    cmp r1, #0                   @ End of string?
    beq skip_done
    cmp r1, #' '                 @ Space?
    beq skip_spaces
    add r0, r0, #1               @ Move pointer forward
    b skip_loop

skip_spaces:
    ldrb r1, [r0]
    cmp r1, #' '
    bne skip_done                 @ Stop skipping spaces
    add r0, r0, #1               @ Skip space
    b skip_spaces

skip_done:
    pop {r1, pc}                  @ Return pointer to after first number