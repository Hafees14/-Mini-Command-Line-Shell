@ Handles command matching using string comparison and conditional branching:

check_commands:
    push {lr}                      @ Save return address

    @ by default, here we are checking "hello" command

    ldr r0, =input_buffer
    ldr r1, =hello_cmd
    mov r2, #hello_len
    bl compare_strings

    cmp r0, #1
    bne check_help

    bl do_hello
    pop {pc}

check_help:
    here we are checking "help" command

    ldr r0, =input_buffer
    ldr r1, =help_cmd
    mov r2, #help_len
    bl compare_strings

    cmp r0, #1
    bne check_exit

    bl do_help
    pop {pc}

check_exit:
    here we are checking "exit" command

    ldr r0, =input_buffer
    ldr r1, =exit_cmd
    mov r2, #exit_len
    bl compare_strings

    cmp r0, #1
    bne check_clear

    bl do_exit
    pop {pc}

check_clear:
    here we are checking "clear" command

    ldr r0, =input_buffer
    ldr r1, =clear_cmd
    mov r2, #clear_len
    bl compare_strings

    cmp r0, #1
    bne check_hex      

    bl do_clear
    pop {pc}

unknown_command:
    mov r0, #1                     @ Print unknown command message
    ldr r1, =unknown_msg
    mov r2, #unknown_msg_len
    mov r7, #4
    swi 0

    pop {pc}                      @ Return to main loop

@ Reusable String Comparison Function
@ Implements string comparison logic with register preservation:

compare_strings:
    push {r4, r5, r6, lr}          @ Save used registers

    mov r4, #0                     @ Index counter
    mov r5, #1                     @ Assume strings are equal

compare_loop:
    cmp r4, r2                     @ Check if reached end of compare length
    bge compare_done

    ldrb r6, [r0, r4]              @ Load char from first string
    ldrb r3, [r1, r4]              @ Load char from second string

    cmp r6, r3                     @ Compare chars
    bne not_equal

    add r4, r4, #1                @ Move to next char
    b compare_loop

not_equal:
    mov r5, #0                    @ Mark strings not equal

compare_done:
    mov r0, r5                    @ Return 1 if equal, else 0
    pop {r4, r5, r6, pc}          @ Restore registers and return

@ Command-Specific Functions
@ Distinct code paths for each command with proper register preservation:

do_hello:
    push {lr}

    mov r0, #1                    @ stdout
    ldr r1, =hello_msg
    mov r2, #hello_msg_len
    mov r7, #4                    @ syscall write
    swi 0

    pop {pc}

do_help:
    push {lr}

    mov r0, #1
    ldr r1, =help_msg
    mov r2, #help_msg_len
    mov r7, #4
    swi 0

    pop {pc}

do_exit:
    push {lr}

    mov r0, #1
    ldr r1, =exit_msg
    mov r2, #exit_msg_len
    mov r7, #4
    swi 0

    mov r0, #0                    @ Exit code 0
    mov r7, #1                    @ syscall exit
    swi 0

    pop {pc}

do_clear:
    push {lr}

    mov r0, #1
    ldr r1, =clear_seq
    mov r2, #clear_seq_len
    mov r7, #4
    swi 0

    pop {pc}