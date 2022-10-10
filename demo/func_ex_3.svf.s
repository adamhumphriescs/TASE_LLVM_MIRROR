	.text
	.file	"func_ex_3.c"
	.globl	func                    # -- Begin function func
	.p2align	4, 0x90
	.type	func,@function
func:                                   # @func
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
                                        # kill: def $edx killed $edx def $rdx
                                        # kill: def $esi killed $esi def $rsi
	movq	%rdi, -16(%rbp)
	leaq	-8(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	%esi, -8(%rbp)          # Instruction is Tainted 
	movl	%edx, -4(%rbp)
	leal	(%rsi,%rdx), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB0_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB0_1_CartridgeHead:
	leaq	.LBB0_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_1_CartridgeBody:
	retq
.LBB0_1_CartridgeEnd:
.Lfunc_end0:
	.size	func, .Lfunc_end0-func
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
.LBB1_0_CartridgeHead:
	leaq	.LBB1_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset %rbx, -24
	movl	$0, -24(%rbp)
	movl	$4, -16(%rbp)
	movl	$.L.str, %edi
	movl	$4, %esi
	xorl	%eax, %eax
	callq	printf
.LBB1_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB1_1_CartridgeHead:
	leaq	.LBB1_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_1_CartridgeBody:
	leaq	-12(%rbp), %rbx
	movl	$.L.str.1, %edi
	movq	%rbx, %rsi
	xorl	%eax, %eax
	callq	__isoc99_scanf
.LBB1_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB1_2_CartridgeHead:
	leaq	.LBB1_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_2_CartridgeBody:
	movl	$.L.str.2, %edx         # Instruction is Tainted 
	movq	%rbx, %rdi
	movl	$4, %esi                # Instruction is Tainted 
	pinsrq	$0, -8(%rsp), %xmm15
	callq	makesymbolic            # Instruction is Tainted 
.LBB1_2_CartridgeEnd:
# %bb.3:                                # %entry
.LBB1_3_CartridgeHead:
	leaq	.LBB1_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_3_CartridgeBody:
	leaq	-12(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-12(%rbp), %esi         # Instruction is Tainted 
	movl	$.L.str.2, %edi         # Instruction is Tainted 
	movl	$1, %edx                # Instruction is Tainted 
	pinsrq	$1, -8(%rsp), %xmm15
	callq	func                    # Instruction is Tainted 
.LBB1_3_CartridgeEnd:
# %bb.4:                                # %entry
.LBB1_4_CartridgeHead:
	leaq	.LBB1_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_4_CartridgeBody:
	leaq	-20(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	%eax, -20(%rbp)         # Instruction is Tainted 
	xorl	%eax, %eax
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB1_4_CartridgeEnd:
# %bb.5:                                # %entry
.LBB1_5_CartridgeHead:
	leaq	.LBB1_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_5_CartridgeBody:
	retq
.LBB1_5_CartridgeEnd:
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"Enter number: %d "
	.size	.L.str, 18

	.type	.L.str.1,@object        # @.str.1
.L.str.1:
	.asciz	"%d"
	.size	.L.str.1, 3

	.type	.L.str.2,@object        # @.str.2
.L.str.2:
	.zero	1
	.size	.L.str.2, 1


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

	.long	.LBB1_0_CartridgeHead
	.short	.LBB1_0_CartridgeBody-.LBB1_0_CartridgeHead
	.short	.LBB1_0_CartridgeEnd-.LBB1_0_CartridgeBody

	.long	.LBB1_1_CartridgeHead
	.short	.LBB1_1_CartridgeBody-.LBB1_1_CartridgeHead
	.short	.LBB1_1_CartridgeEnd-.LBB1_1_CartridgeBody

	.long	.LBB1_2_CartridgeHead
	.short	.LBB1_2_CartridgeBody-.LBB1_2_CartridgeHead
	.short	.LBB1_2_CartridgeEnd-.LBB1_2_CartridgeBody

	.long	.LBB1_3_CartridgeHead
	.short	.LBB1_3_CartridgeBody-.LBB1_3_CartridgeHead
	.short	.LBB1_3_CartridgeEnd-.LBB1_3_CartridgeBody

	.long	.LBB1_4_CartridgeHead
	.short	.LBB1_4_CartridgeBody-.LBB1_4_CartridgeHead
	.short	.LBB1_4_CartridgeEnd-.LBB1_4_CartridgeBody

	.long	.LBB1_5_CartridgeHead
	.short	.LBB1_5_CartridgeBody-.LBB1_5_CartridgeHead
	.short	.LBB1_5_CartridgeEnd-.LBB1_5_CartridgeBody

                                        # End of TASE Cartridge records
	.section	.rodata.tase_modeled_records,"",@progbits
	.section	.rodata.tase_live_flags_block_records,"",@progbits
                                        # Start of TASE list of blocks with live flags 
                                        # End of TASE live flags block records section
	.section	".note.GNU-stack","",@progbits
