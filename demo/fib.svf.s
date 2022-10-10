	.text
	.file	"fib.c"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
.LBB0_0_CartridgeHead:
	leaq	.LBB0_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset %rbx, -24
	movl	$0, -32(%rbp)
	movl	$0, -20(%rbp)
	movl	$1, -12(%rbp)
	movl	$.L.str, %edi
	xorl	%eax, %eax
	callq	printf
.LBB0_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB0_1_CartridgeHead:
	leaq	.LBB0_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_1_CartridgeBody:
	leaq	-24(%rbp), %rbx         # Instruction is Tainted 
	movl	$.L.str.1, %edi
	movq	%rbx, %rsi
	xorl	%eax, %eax
	callq	__isoc99_scanf
.LBB0_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB0_2_CartridgeHead:
	leaq	.LBB0_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_2_CartridgeBody:
	movl	$.L.str.2, %edx         # Instruction is Tainted 
	movq	%rbx, %rdi              # Instruction is Tainted 
	movl	$4, %esi                # Instruction is Tainted 
	pinsrq	$0, -8(%rsp), %xmm15
	callq	makesymbolic            # Instruction is Tainted 
.LBB0_2_CartridgeEnd:
# %bb.3:                                # %entry
.LBB0_3_CartridgeHead:
	leaq	.LBB0_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_3_CartridgeBody:
	movl	-20(%rbp), %esi
	movl	-12(%rbp), %edx
	movl	$.L.str.3, %edi
	xorl	%eax, %eax
	callq	printf
.LBB0_3_CartridgeEnd:
# %bb.4:                                # %entry
.LBB0_4_CartridgeHead:
	leaq	.LBB0_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_4_CartridgeBody:
	movl	$2, -16(%rbp)
	jmp	.LBB0_7
.LBB0_4_CartridgeEnd:
	.p2align	4, 0x90
.LBB0_5:                                # %for.body
                                        #   in Loop: Header=BB0_7 Depth=1
.LBB0_5_CartridgeHead:
	leaq	.LBB0_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_5_CartridgeBody:
	movl	-20(%rbp), %eax
	movl	-12(%rbp), %esi
	addl	%eax, %esi
	movl	%esi, -28(%rbp)
	movl	$.L.str.4, %edi
	xorl	%eax, %eax
	callq	printf
.LBB0_5_CartridgeEnd:
# %bb.6:                                # %for.body
                                        #   in Loop: Header=BB0_7 Depth=1
.LBB0_6_CartridgeHead:
	leaq	.LBB0_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_6_CartridgeBody:
	movl	-12(%rbp), %eax
	movl	%eax, -20(%rbp)
	movl	-28(%rbp), %eax
	movl	%eax, -12(%rbp)
	movl	-16(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -16(%rbp)
.LBB0_6_CartridgeEnd:
.LBB0_7:                                # %for.cond
                                        # =>This Inner Loop Header: Depth=1
.LBB0_7_CartridgeHead:
	leaq	.LBB0_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_7_CartridgeBody:
	leaq	-16(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-16(%rbp), %eax         # Instruction is Tainted 
	leaq	-24(%rbp), %r14
	shrq	%r14
	movhps	(%r14,%r14), %xmm15     # xmm15 = xmm15[0,1],mem[0,1]
	movl	-24(%rbp), %ecx         # Instruction is Tainted 
	cmpl	%ecx, %eax              # Instruction is Tainted 
	jl	.LBB0_5
.LBB0_7_CartridgeEnd:
# %bb.8:                                # %for.end
.LBB0_8_CartridgeHead:
	leaq	.LBB0_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_8_CartridgeBody:
	xorl	%eax, %eax
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB0_8_CartridgeEnd:
# %bb.9:                                # %for.end
.LBB0_9_CartridgeHead:
	leaq	.LBB0_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_9_CartridgeBody:
	retq
.LBB0_9_CartridgeEnd:
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"Enter the number of elements: "
	.size	.L.str, 31

	.type	.L.str.1,@object        # @.str.1
.L.str.1:
	.asciz	"%d"
	.size	.L.str.1, 3

	.type	.L.str.2,@object        # @.str.2
.L.str.2:
	.zero	1
	.size	.L.str.2, 1

	.type	.L.str.3,@object        # @.str.3
.L.str.3:
	.asciz	"%d, %d\n"
	.size	.L.str.3, 8

	.type	.L.str.4,@object        # @.str.4
.L.str.4:
	.asciz	"%d\n"
	.size	.L.str.4, 4


	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
	.section	.rodata.tase_records,"",@progbits
                                        # Start of TASE Cartridge records
	.long	.LBB0_0_CartridgeHead
	.short	.LBB0_0_CartridgeBody-.LBB0_0_CartridgeHead
	.short	.LBB0_0_CartridgeEnd-.LBB0_0_CartridgeBody

	.long	.LBB0_1_CartridgeHead
	.short	.LBB0_1_CartridgeBody-.LBB0_1_CartridgeHead
	.short	.LBB0_1_CartridgeEnd-.LBB0_1_CartridgeBody

	.long	.LBB0_2_CartridgeHead
	.short	.LBB0_2_CartridgeBody-.LBB0_2_CartridgeHead
	.short	.LBB0_2_CartridgeEnd-.LBB0_2_CartridgeBody

	.long	.LBB0_3_CartridgeHead
	.short	.LBB0_3_CartridgeBody-.LBB0_3_CartridgeHead
	.short	.LBB0_3_CartridgeEnd-.LBB0_3_CartridgeBody

	.long	.LBB0_4_CartridgeHead
	.short	.LBB0_4_CartridgeBody-.LBB0_4_CartridgeHead
	.short	.LBB0_4_CartridgeEnd-.LBB0_4_CartridgeBody

	.long	.LBB0_5_CartridgeHead
	.short	.LBB0_5_CartridgeBody-.LBB0_5_CartridgeHead
	.short	.LBB0_5_CartridgeEnd-.LBB0_5_CartridgeBody

	.long	.LBB0_6_CartridgeHead
	.short	.LBB0_6_CartridgeBody-.LBB0_6_CartridgeHead
	.short	.LBB0_6_CartridgeEnd-.LBB0_6_CartridgeBody

	.long	.LBB0_7_CartridgeHead
	.short	.LBB0_7_CartridgeBody-.LBB0_7_CartridgeHead
	.short	.LBB0_7_CartridgeEnd-.LBB0_7_CartridgeBody

	.long	.LBB0_8_CartridgeHead
	.short	.LBB0_8_CartridgeBody-.LBB0_8_CartridgeHead
	.short	.LBB0_8_CartridgeEnd-.LBB0_8_CartridgeBody

	.long	.LBB0_9_CartridgeHead
	.short	.LBB0_9_CartridgeBody-.LBB0_9_CartridgeHead
	.short	.LBB0_9_CartridgeEnd-.LBB0_9_CartridgeBody

                                        # End of TASE Cartridge records
	.section	.rodata.tase_modeled_records,"",@progbits
	.section	.rodata.tase_live_flags_block_records,"",@progbits
                                        # Start of TASE list of blocks with live flags 
                                        # End of TASE live flags block records section
	.section	".note.GNU-stack","",@progbits
