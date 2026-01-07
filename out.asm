bits 32

global start

extern exit
import exit msvcrt.dll

extern scanf
import scanf msvcrt.dll

extern printf
import printf msvcrt.dll

segment data use32 class=data
    fmt_in  db "%d", 0
    fmt_out db "%d", 10, 0

    a dd 0
    b dd 0

segment code use32 class=code
start:
    ; cin >> a
    push dword a
    push dword fmt_in
    call [scanf]
    add esp, 8
    
    push dword [a]
    push dword 2
    ; mul
    pop ebx
    pop eax
    imul eax, ebx
    push eax
    push dword 1
    ; add
    pop ebx
    pop eax
    add eax, ebx
    push eax
    ; store in b
    pop eax
    mov [b], eax
    
    ; cout << b
    push dword [b]
    push dword fmt_out
    call [printf]
    add esp, 8
    

    push dword 0
    call [exit]
