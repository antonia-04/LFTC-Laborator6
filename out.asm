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

    x dd 0
    y dd 0
    z dd 0

segment code use32 class=code
start:
    ; cin >> x
    push dword x
    push dword fmt_in
    call [scanf]
    add esp, 8
    
    ; cin >> y
    push dword y
    push dword fmt_in
    call [scanf]
    add esp, 8
    
    push dword [x]
    push dword [y]
    ; add
    pop ebx
    pop eax
    add eax, ebx
    push eax
    push dword 3
    ; mul
    pop ebx
    pop eax
    imul eax, ebx
    push eax
    push dword [x]
    push dword 2
    ; mul
    pop ebx
    pop eax
    imul eax, ebx
    push eax
    ; sub
    pop ebx
    pop eax
    sub eax, ebx
    push eax
    ; store in z
    pop eax
    mov [z], eax
    
    ; cout << z
    push dword [z]
    push dword fmt_out
    call [printf]
    add esp, 8
    

    push dword 0
    call [exit]
