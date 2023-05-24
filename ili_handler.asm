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
    xorq %rbx, %rbx
      
    movq 120(%rsp), %rbx #loading the user code %rip into %rbx
    movq (%rbx), %rbx
    cmpb $0x0f, %bl
    jne one_byte_handler
  
one_byte_handler:
    movb %bl, %dil
    call what_to_do
    cmpq $0, %rax
    jne default_handler
    jmp ill_handler_finish

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
