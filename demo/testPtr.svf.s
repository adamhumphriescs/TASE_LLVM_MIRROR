	.text
	.file	"testPtr.c"
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
	subq	$16, %rsp
	movl	$0, -16(%rbp)
	movl	$0, -4(%rbp)
	movl	$4, -8(%rbp)
	leaq	-4(%rbp), %rdi
	movl	$.L.str, %edx
	movl	$4, %esi
	pinsrq	$0, -8(%rsp), %xmm15
	callq	makesymbolic            # Instruction is Tainted 
.LBB0_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB0_1_CartridgeHead:
	leaq	.LBB0_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_1_CartridgeBody:
	leaq	-4(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-4(%rbp), %eax          # Instruction is Tainted 
	leaq	-12(%rbp), %r14
	shrq	%r14
	movhps	(%r14,%r14), %xmm15     # xmm15 = xmm15[0,1],mem[0,1]
	movl	%eax, -12(%rbp)         # Instruction is Tainted 
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB0_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB0_2_CartridgeHead:
	leaq	.LBB0_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_2_CartridgeBody:
	retq
.LBB0_2_CartridgeEnd:
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.zero	1
	.size	.L.str, 1


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

                                        # End of TASE Cartridge records
	.section	.rodata.tase_modeled_records,"",@progbits
	.section	.rodata.tase_live_flags_block_records,"",@progbits
                                        # Start of TASE list of blocks with live flags 
                                        # End of TASE live flags block records section
	.section	".note.GNU-stack","",@progbits
