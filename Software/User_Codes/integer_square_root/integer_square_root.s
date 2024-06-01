.text
.globl _start

_start:
    li t1, 81    # Load input value into t1 (n)
    
    # Initialize variables
    li t2, 0        # Initialize x (current guess)
    li t3, 1        # Initialize next guess increment

sqrt_loop:
    add t4, t2, t3  # t4 = x + 1
    mul t5, t4, t4  # t5 = (x + 1) * (x + 1)
    bgt t5, t1, end # if (x + 1)^2 > n, end
    addi t2, t2, 1  # x = x + 1
    j sqrt_loop     # Repeat the loop

end:
    # Final integer square root is in t2
    ebreak          # End of program
