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

    mov rbx, 0 ; iterator to keep track of how many times we have gone tru loop
               ; ^ is also x
    mov r15, 4 ; number of times to go tru loop


    .loop:
        push 2 ; slope
        push 3 ; intercept
        push rbx ; x
        
        call find_y ; send output to rax
        call print ; print rax
        add rbx, 1 ; add one to iterator
        cmp rbx, r15
        jl .loop ; restart if not at stop


    ; call find_y ; should send output to rax

    ; call print ; think this prints rax

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

print: ; this can only print one digit right now
    ; rax holds the integer
    add     al, '0'
    mov     [num], al

    ; Reserve shadow space once for all the calls we make here.
    sub     rsp, 40h              ; 32B shadow + keep 16B alignment

    ; GetStdHandle(STD_OUTPUT_HANDLE)
    mov     ecx, -11              ; STD_OUTPUT_HANDLE
    call    GetStdHandle

    ; Save handle in a VOLATILE temp (don’t use rbx/r15 here)
    mov     r10, rax

    ; WriteFile(h, &num, 1, &bytes_written, NULL)
    mov     rcx, r10              ; hFile
    lea     rdx, [rel num]
    mov     r8d, 1
    lea     r9,  [rel bytes_written]
    mov     qword [rsp+20h], 0    ; 5th arg (LPOVERLAPPED) = NULL
    call    WriteFile

    ; WriteFile(h, "\r\n", 2, &bytes_written, NULL)
    mov     rcx, r10              ; <-- reload handle (RCX is volatile)
    lea     rdx, [rel newline]
    mov     r8d, 2
    lea     r9,  [rel bytes_written]
    mov     qword [rsp+20h], 0
    call    WriteFile

    add     rsp, 40h
    ret