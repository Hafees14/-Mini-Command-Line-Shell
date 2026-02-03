@ .data Section

.data
    @ "shell> " text shown as prompt

    prompt: .ascii "shell> "              
    prompt_len = . - prompt

    @ Command strings stored here

    hello_cmd: .ascii "hello"            
    hello_len = . - hello_cmd

    help_cmd: .ascii "help"
    help_len = . - help_cmd

    exit_cmd: .ascii "exit"
    exit_len = . - exit_cmd

    clear_cmd: .ascii "clear"
    clear_len = . - clear_cmd

    hex_cmd: .ascii "hex"
    hex_len = . - hex_cmd

    add_cmd: .ascii "add"
    add_len = . - add_cmd

    @ Messages to print for commands

    hello_msg: .ascii "Hello World!\n"   
    hello_msg_len = . - hello_msg

    help_msg: .ascii "Commands:\nhello - say hello\nhelp - list commands\nexit - quit shell\nclear - clear screen\nhex - convert number to hex\nadd - add two numbers\n"
    help_msg_len = . - help_msg

    exit_msg: .ascii "Goodbye!\n"
    exit_msg_len = . - exit_msg

    @ Codes to clear the terminal screen

    clear_seq: .ascii "\033[2J\033[H"     
    clear_seq_len = . - clear_seq

    @ Used texts to show
    unknown_msg: .ascii "Unknown command\n"
    unknown_msg_len = . - unknown_msg

    newline: .ascii "\n"
    newline_len = . - newline

@ .bss Section

.bss
    @ Buffer for user input string

    input_buffer: .space 100           

    @ Temporary buffer for printing numbers

    temp_buffer: .space 50                


@ .text Section

.text
.global main

main:
    push {lr}                           @ Save lr on stack

main_loop:

    @ this part prints the prompt to the terminal ("shell>")

    mov r0, #1                          @ File descriptor 1 = stdout
    ldr r1, =prompt                     @ Load prompt string address
    mov r2, #prompt_len                 @ Length of prompt string
    mov r7, #4                          @ Linux Syscall write
    swi 0                               @ Print prompt (swi stands for SoftWare Interrupt)

    @ reads upto 99 characters from the keyboard (standard input) into input_buffer

    mov r0, #0                          @ File descriptor 0 = stdin
    ldr r1, =input_buffer               @ Load input buffer address
    mov r2, #99                         @ Max chars to read (leave space for null)
    mov r7, #3                          @ Linux Syscall read
    swi 0                               @ Read user input

    @ trim the newline and add null terminator
    @ when user presses enter it adds a new line character to the input
    @ We need to remove that new line character

    sub r0, r0, #1                      @ Remove newline char count
    ldr r1, =input_buffer
    mov r2, #0
    strb r2, [r1, r0]                   @ Put null terminator at end

    @ check which command user entered
    
    bl check_commands                   @ Check which command user entered

    @ display prompt -> read input -> check command -> repeat

    b main_loop                         @ Repeat prompt and input

    pop {pc}                            @ Return from main (not used)