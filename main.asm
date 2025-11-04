; assemble & link (PowerShell):
; nasm -f win64 main.asm -o main.obj
; gcc -nostdlib "-Wl,-e,main" main.obj -o main.exe -lkernel32
; .\hello.exe
; echo $LASTEXITCODE   <-- shows the result (y) in PowerShell

default rel
extern ExitProcess
global main


section .data ; init data here
    num db 0           ; for storing ASCII char
    newline db 13,10

section .bss ; reserve space here
    bytes_written resd 1

section .text
    global main
    extern GetStdHandle, WriteFile, ExitProcess
    STD_OUTPUT_HANDLE equ -11

main:
    sub rsp, 32

    mov rax, 0 ; init rax as 0. rax is the value we are passing to the function
    mov rbx, 0 ; iterator to keep track of how many times we have gone tru loop
    mov r15, 4 ; number of times to go tru loop


    .loop
        call find_y ; send output to rax
        call print ; print rax
        add rbx, 1 ; add one to iterator
        cmp rbx, r15
        jl .loop ; restart if not at stop

    push 2 ; slope
    push 3 ; intercept
    push 2 ; x
    call find_y ; should send output to rax

    call print ; think this prints rax

    xor ecx, ecx
    call ExitProcess

; y = slope * x + intercept
find_y:
    ; After CALL, stack top = return address, then x, intercept, slope.
    pop  r13       ; save return address
    pop  r10        ; x
    pop  r11        ; intercept
    pop  r12       ; slope

    imul r10, r12   ; r10 = x * slope
    add  r10, r11    ; r10 += intercept
    mov  rax, r10   ; return y in RAX

    push r13       ; restore return address
    ret

print: ; right now this can only print one digit, need to read up on how to make it do multiple digits
    ; Convert integer 7 -> ASCII '7'
    add al, '0'
    mov [num], al

    ; Get handle to stdout
    mov ecx, STD_OUTPUT_HANDLE
    call GetStdHandle

    ; WriteFile(hOut, num, 1, &bytes_written, NULL)
    mov rcx, rax
    lea rdx, [rel num]
    mov r8d, 1
    lea r9, [rel bytes_written]
    mov qword [rsp+20h], 0
    call WriteFile

    ; Write newline
    lea rdx, [rel newline]
    mov r8d, 2
    call WriteFile