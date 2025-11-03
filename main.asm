; assemble & link (PowerShell):
; nasm -f win64 main.asm -o main.obj
; gcc -nostdlib "-Wl,-e,_start" main.obj -o main.exe -lkernel32
; .\hello.exe
; echo $LASTEXITCODE   <-- shows the result (y) in PowerShell

default rel
extern ExitProcess
global _start

section .data
    ; msg is a label
    ; db = Data Bytes
    ; saves the ASCII number equivalent of this msg into memory, retrievable later by its label
    ; 10 is ASCII for a newline
    msg: db "Hello, world!", 10

    ; Define an assemble-time constant, which is calculated during compilation
    ; Calculate len = string length.  subtract the address of the start of the string from the current position ($)
    .len: equ $ - msg

section .text
_start:
    ; push args, call function
    push 2         ; slope
    push 4         ; y-intercept
    push 5         ; x
    call find_y    ; RAX <- y

    ; ExitProcess(y)
    sub  rsp, 40   ; Windows x64: 32B shadow space + keep 16B alignment
    mov  ecx, eax  ; exit code in ECX
    call ExitProcess
    ; (no return)

; y = slope * x + intercept
find_y:
    ; After CALL, stack top = return address, then x, intercept, slope.
    pop  r11       ; save return address
    pop  r8        ; x
    pop  r9        ; intercept
    pop  r10       ; slope

    imul r8, r10   ; r8 = x * slope
    add  r8, r9    ; r8 += intercept
    mov  rax, r8   ; return y in RAX

    push r11       ; restore return address
    ret
