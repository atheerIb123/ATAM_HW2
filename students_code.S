.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
    pushq %rbx #local variable
    xorq %rax, %rax
    xorq %rbx, %rbx
    xorq %r10, %r10
    xorq %r11, %r11
	
    movq (%rdi), %rax #rax = first 64-bits of input
    movq 8(%rdi), %rbx  #rbx = 64-128 of input
    movq (%rsi), %r10  #r10 -> caller saved register = first 64-bits of key 
    movq 8(%rsi), %r11 #r11 -> caller saved register = 64-128 bits of key 

    xorq %r10, %rax #performing xor bit-wise on the first 64 bits of input and key
    xorq %r11, %rbx #performing xor bit-wise on the remaining bits of input and key

    #saving the result in input
    movq %rax, (%rdi)
    movq %rbx, 8(%rdi)
    popq %rbx
    ret

byteSubstitution:
    pushq %rbx #local variable
    
    xorq %r10, %r10
    xorq %r11, %r11
    xorq %rax, %rax 
    xorq %rbx, %rbx
    
    movq %rdi, %rax #rax = address of input
    leaq sbox(%rip), %r10 #r10 = address of sbox (base)
    
substitution_loop:
    cmpq $16, %rbx
    je end_HW2
    
    movb (%rax, %rbx), %r11b
    movb (%r10,%r11), %r11b # r11 = sbox[#input]
    movb %r11b, (%rax, %rbx) # #input = sbox[#input]
    incq %rbx
    
    jmp substitution_loop

end_HW2:   
    popq %rbx
    ret
    


shiftRows:
    pushq %rbx
    pushq %r12
    
    xorq %r10, %r10
    xorq %rax, %rax
    xorq %r11, %r11
    xorq %rcx, %rcx
    xorq %r9, %r9 
    xorq %rbx, %rbx
    movq %rdi, %r9
    
shift_loop:
    cmpq $4, %r10
    je end_shift
    
    cmpq $2, %r10
    je even_handler
    
    xorq %r12, %r12
    movb (%r9), %bl
    
inner_loop:  
    cmpq $4, %r12  
    je inner_finish
    
    subq %r10, %rcx
    cmpq $0, %rcx
    jge lab
    addq $4, %rcx
lab:    
    movb %bl, %al
    movb (%r9, %rcx), %bl
    movb %al, (%r9, %rcx)
    
    incq %r12
    jmp inner_loop
    
inner_finish:
    addq $4, %r9
    incq %r10
    jmp shift_loop 
    
even_handler:
    movb (%r9), %bl
    movb 2(%r9), %al
    movb %bl, 2(%r9)
    movb %al, (%r9)
    
    movb 1(%r9), %bl
    movb 3(%r9), %al
    movb %al, 1(%r9)
    movb %bl, 3(%r9)
    incq %r10
    addq $4, %r9
    jmp shift_loop
    
end_shift:
    popq %r12
    popq %rbx
    ret


cipher:
#calling keyMixing --- a ----
    pushq %rdx	
    pushq %rdi
    pushq %rsi    
    call keyMixing
    popq %rsi
    popq %rdi
    popq %rdx
    
    xorq %rcx, %rcx
    loop_nine_b:      #the loob of step b, 9 times
        cmpq $9, %rcx
        je loop_nine_b_end
       #calling Byte Substitution
         pushq %rdx	
        pushq %rdi
        pushq %rsi  
        pushq %rcx
        call byteSubstitution
        popq %rcx
        popq %rsi
        popq %rdi
        popq %rdx
        
       #calling Shift Rows
        pushq %rdx	
        pushq %rdi
        pushq %rsi  
        pushq %rcx
        call shiftRows
        popq %rcx
        popq %rsi
        popq %rdi
        popq %rdx
       
        #calling mix columns
        pushq %rdx	
        pushq %rdi
        pushq %rsi  
        pushq %rcx
        call mixColumns
        popq %rcx
        popq %rsi
        popq %rdi
        popq %rdx
              
       
        pushq %rdx	
        pushq %rdi
        pushq %rsi
        pushq %rcx
        call keyMixing
        popq %rcx
        popq %rsi
        popq %rdi
        popq %rdx
                
        inc %rcx
        jmp loop_nine_b
    
    
    loop_nine_b_end:

        pushq %rdx	
        pushq %rdi
        pushq %rsi
        call byteSubstitution
        popq %rsi
        popq %rdi
        popq %rdx     
        
           
              
        pushq %rdx	
        pushq %rdi
        pushq %rsi
        call shiftRows
        popq %rsi
        popq %rdi
        popq %rdx         
    
    
        pushq %rdx	
        pushq %rdi
        pushq %rsi
        call keyMixing
        popq %rsi
        popq %rdi
        popq %rdx     
        
        
        lea 16(%rdi), %rdi
        dec %rdx
        cmpq $0, %rdx
        jne cipher
    
    
        ret
