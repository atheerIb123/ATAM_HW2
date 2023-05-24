.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  ####### Some smart student's code here #######
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx	
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %rsi
    pushq %rbp
    pushq %rsp
       
    xorq %rax, %rax
    xorq %rdi, %rdi
    xorq %rcx, %rcx
     
    movq 120(%rsp), %rcx #loading the user code %rip into %rbx
    movq (%rcx), %rcx
    cmpb $0x0f, %cl
    jne one_byte_handler
    
    movb %ch, %al
    movq %rax, %rdi
    call what_to_do
    cmpq $0, %rax
    je default_handler
    jmp ill_handler_finish

one_byte_handler:
    movb %cl, %al
    movq %rax, %rdi
    call what_to_do
    cmpq $0, %rax
    jne ill_handler_finish
    jmp default_handler

ill_handler_finish:
    movq %rax, %rdi #save the returned value from what_to_do into %rdi like required

    popq %rsp
    popq %rbp
    popq %rsi
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
    
    addq $2, (%rsp) #get to the next command
    jmp end_ill
    
default_handler:
    popq %rsp
    popq %rbp
    popq %rsi
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax

    jmp * old_ili_handler
    
end_ill:
    iretq