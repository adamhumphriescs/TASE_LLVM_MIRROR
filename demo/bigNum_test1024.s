	.text
	.file	"bigNum.c"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
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
	movl	%edi, -12(%rbp)
	movq	%rsi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	8(%rax), %rdi
	callq	atoi
.LBB0_0_CartridgeEnd:
# %bb.1:
.LBB0_1_CartridgeHead:
	leaq	.LBB0_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_1_CartridgeBody:
	movl	%eax, symIndex
	movq	-8(%rbp), %rax
	movq	16(%rax), %rdi
	callq	atoi
.LBB0_1_CartridgeEnd:
# %bb.2:
.LBB0_2_CartridgeHead:
	leaq	.LBB0_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_2_CartridgeBody:
	movl	%eax, numEntries
	movq	-8(%rbp), %rax
	movq	24(%rax), %rdi
	callq	atoi
.LBB0_2_CartridgeEnd:
# %bb.3:
.LBB0_3_CartridgeHead:
	leaq	.LBB0_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_3_CartridgeBody:
	movl	%eax, repetitions
	callq	begin_target_inner
.LBB0_3_CartridgeEnd:
# %bb.4:
.LBB0_4_CartridgeHead:
	leaq	.LBB0_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_4_CartridgeBody:
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB0_4_CartridgeEnd:
# %bb.5:
.LBB0_5_CartridgeHead:
	leaq	.LBB0_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_5_CartridgeBody:
	retq
.LBB0_5_CartridgeEnd:
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	make_byte_symbolic      # -- Begin function make_byte_symbolic
	.p2align	4, 0x90
	.type	make_byte_symbolic,@function
make_byte_symbolic:                     # @make_byte_symbolic
	.cfi_startproc
# %bb.0:
.LBB1_0_CartridgeHead:
	leaq	.LBB1_0_CartridgeBody(%rip), %r15
	jmp	sb_modeled
.LBB1_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -8(%rbp)
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB1_0_CartridgeEnd:
# %bb.1:
.LBB1_1_CartridgeHead:
	leaq	.LBB1_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_1_CartridgeBody:
	retq
.LBB1_1_CartridgeEnd:
.Lfunc_end1:
	.size	make_byte_symbolic, .Lfunc_end1-make_byte_symbolic
	.cfi_endproc
                                        # -- End function
	.globl	initializeNums          # -- Begin function initializeNums
	.p2align	4, 0x90
	.type	initializeNums,@function
initializeNums:                         # @initializeNums
	.cfi_startproc
# %bb.0:
.LBB2_0_CartridgeHead:
	leaq	.LBB2_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movl	$0, -4(%rbp)
.LBB2_0_CartridgeEnd:
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
.LBB2_1_CartridgeHead:
	leaq	.LBB2_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_1_CartridgeBody:
	movl	-4(%rbp), %eax
	movl	numEntries, %ecx
	cmpl	%ecx, %eax
	jge	.LBB2_9
.LBB2_1_CartridgeEnd:
# %bb.2:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_2_CartridgeHead:
	leaq	.LBB2_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_2_CartridgeBody:
	movl	testType, %eax
	cmpl	$0, %eax
	jne	.LBB2_4
.LBB2_2_CartridgeEnd:
# %bb.3:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_3_CartridgeHead:
	leaq	.LBB2_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_3_CartridgeBody:
	movq	-16(%rbp), %rax
	movl	-4(%rbp), %ecx
	movslq	%ecx, %rcx
	movb	$1, (%rax,%rcx)
	jmp	.LBB2_7
.LBB2_3_CartridgeEnd:
.LBB2_4:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_4_CartridgeHead:
	leaq	.LBB2_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_4_CartridgeBody:
	movl	testType, %eax
	cmpl	$1, %eax
	jne	.LBB2_6
.LBB2_4_CartridgeEnd:
# %bb.5:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_5_CartridgeHead:
	leaq	.LBB2_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_5_CartridgeBody:
	movb	garbageCtr, %al
	movzbl	%al, %eax
	movb	garbageCtr, %cl
	movzbl	%cl, %ecx
	imull	%ecx, %eax
	addl	$7, %eax
	movb	%al, garbageCtr
	movb	garbageCtr, %al
	movq	-16(%rbp), %rcx
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	movb	%al, (%rcx,%rdx)
.LBB2_5_CartridgeEnd:
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_6_CartridgeHead:
	leaq	.LBB2_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_6_CartridgeBody:
	jmp	.LBB2_7
.LBB2_6_CartridgeEnd:
.LBB2_7:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_7_CartridgeHead:
	leaq	.LBB2_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_7_CartridgeBody:
	jmp	.LBB2_8
.LBB2_7_CartridgeEnd:
.LBB2_8:                                #   in Loop: Header=BB2_1 Depth=1
.LBB2_8_CartridgeHead:
	leaq	.LBB2_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_8_CartridgeBody:
	movl	-4(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	.LBB2_1
.LBB2_8_CartridgeEnd:
.LBB2_9:
.LBB2_9_CartridgeHead:
	leaq	.LBB2_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_9_CartridgeBody:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB2_9_CartridgeEnd:
# %bb.10:
.LBB2_10_CartridgeHead:
	leaq	.LBB2_10_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_10_CartridgeBody:
	retq
.LBB2_10_CartridgeEnd:
.Lfunc_end2:
	.size	initializeNums, .Lfunc_end2-initializeNums
	.cfi_endproc
                                        # -- End function
	.globl	initializeAllOnes       # -- Begin function initializeAllOnes
	.p2align	4, 0x90
	.type	initializeAllOnes,@function
initializeAllOnes:                      # @initializeAllOnes
	.cfi_startproc
# %bb.0:
.LBB3_0_CartridgeHead:
	leaq	.LBB3_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movl	$0, -4(%rbp)
.LBB3_0_CartridgeEnd:
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
.LBB3_1_CartridgeHead:
	leaq	.LBB3_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_1_CartridgeBody:
	movl	-4(%rbp), %eax
	movl	numEntries, %ecx
	cmpl	%ecx, %eax
	jge	.LBB3_4
.LBB3_1_CartridgeEnd:
# %bb.2:                                #   in Loop: Header=BB3_1 Depth=1
.LBB3_2_CartridgeHead:
	leaq	.LBB3_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_2_CartridgeBody:
	movq	-16(%rbp), %rax
	movl	-4(%rbp), %ecx
	movslq	%ecx, %rcx
	movb	$-1, (%rax,%rcx)
.LBB3_2_CartridgeEnd:
# %bb.3:                                #   in Loop: Header=BB3_1 Depth=1
.LBB3_3_CartridgeHead:
	leaq	.LBB3_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_3_CartridgeBody:
	movl	-4(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	.LBB3_1
.LBB3_3_CartridgeEnd:
.LBB3_4:
.LBB3_4_CartridgeHead:
	leaq	.LBB3_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_4_CartridgeBody:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB3_4_CartridgeEnd:
# %bb.5:
.LBB3_5_CartridgeHead:
	leaq	.LBB3_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_5_CartridgeBody:
	retq
.LBB3_5_CartridgeEnd:
.Lfunc_end3:
	.size	initializeAllOnes, .Lfunc_end3-initializeAllOnes
	.cfi_endproc
                                        # -- End function
	.globl	initializeAllZeros      # -- Begin function initializeAllZeros
	.p2align	4, 0x90
	.type	initializeAllZeros,@function
initializeAllZeros:                     # @initializeAllZeros
	.cfi_startproc
# %bb.0:
.LBB4_0_CartridgeHead:
	leaq	.LBB4_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movl	$0, -4(%rbp)
.LBB4_0_CartridgeEnd:
.LBB4_1:                                # =>This Inner Loop Header: Depth=1
.LBB4_1_CartridgeHead:
	leaq	.LBB4_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_1_CartridgeBody:
	movl	-4(%rbp), %eax
	movl	numEntries, %ecx
	cmpl	%ecx, %eax
	jge	.LBB4_4
.LBB4_1_CartridgeEnd:
# %bb.2:                                #   in Loop: Header=BB4_1 Depth=1
.LBB4_2_CartridgeHead:
	leaq	.LBB4_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_2_CartridgeBody:
	movq	-16(%rbp), %rax
	movl	-4(%rbp), %ecx
	movslq	%ecx, %rcx
	movb	$0, (%rax,%rcx)
.LBB4_2_CartridgeEnd:
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
.LBB4_3_CartridgeHead:
	leaq	.LBB4_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_3_CartridgeBody:
	movl	-4(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	.LBB4_1
.LBB4_3_CartridgeEnd:
.LBB4_4:
.LBB4_4_CartridgeHead:
	leaq	.LBB4_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_4_CartridgeBody:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB4_4_CartridgeEnd:
# %bb.5:
.LBB4_5_CartridgeHead:
	leaq	.LBB4_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_5_CartridgeBody:
	retq
.LBB4_5_CartridgeEnd:
.Lfunc_end4:
	.size	initializeAllZeros, .Lfunc_end4-initializeAllZeros
	.cfi_endproc
                                        # -- End function
	.globl	begin_target_inner      # -- Begin function begin_target_inner
	.p2align	4, 0x90
	.type	begin_target_inner,@function
begin_target_inner:                     # @begin_target_inner
	.cfi_startproc
# %bb.0:
.LBB5_0_CartridgeHead:
	leaq	.LBB5_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$48, %rsp
	movl	numEntries, %eax
	movslq	%eax, %rdi
	callq	malloc
.LBB5_0_CartridgeEnd:
# %bb.1:
.LBB5_1_CartridgeHead:
	leaq	.LBB5_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_1_CartridgeBody:
	movq	%rax, -16(%rbp)
	movl	numEntries, %eax
	movslq	%eax, %rdi
	callq	malloc
.LBB5_1_CartridgeEnd:
# %bb.2:
.LBB5_2_CartridgeHead:
	leaq	.LBB5_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_2_CartridgeBody:
	movq	%rax, -24(%rbp)
	movl	numEntries, %eax
	addl	$1, %eax
	movslq	%eax, %rdi
	callq	malloc
.LBB5_2_CartridgeEnd:
# %bb.3:
.LBB5_3_CartridgeHead:
	leaq	.LBB5_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_3_CartridgeBody:
	movq	%rax, -40(%rbp)
	movq	-16(%rbp), %rdi
	callq	initializeNums
.LBB5_3_CartridgeEnd:
# %bb.4:
.LBB5_4_CartridgeHead:
	leaq	.LBB5_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_4_CartridgeBody:
	movq	-24(%rbp), %rdi
	callq	initializeNums
.LBB5_4_CartridgeEnd:
# %bb.5:
.LBB5_5_CartridgeHead:
	leaq	.LBB5_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_5_CartridgeBody:
	movq	-16(%rbp), %rdi
	callq	initializeAllZeros
.LBB5_5_CartridgeEnd:
# %bb.6:
.LBB5_6_CartridgeHead:
	leaq	.LBB5_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_6_CartridgeBody:
	movq	-24(%rbp), %rdi
	callq	initializeAllOnes
.LBB5_6_CartridgeEnd:
# %bb.7:
.LBB5_7_CartridgeHead:
	leaq	.LBB5_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_7_CartridgeBody:
	movl	symIndex, %eax
	cmpl	$0, %eax
	jl	.LBB5_10
.LBB5_7_CartridgeEnd:
# %bb.8:
.LBB5_8_CartridgeHead:
	leaq	.LBB5_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_8_CartridgeBody:
	movl	symIndex, %eax
	movl	numEntries, %ecx
	cmpl	%ecx, %eax
	jge	.LBB5_10
.LBB5_8_CartridgeEnd:
# %bb.9:
.LBB5_9_CartridgeHead:
	leaq	.LBB5_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_9_CartridgeBody:
	movq	-16(%rbp), %rax
	movl	symIndex, %ecx
	movslq	%ecx, %rcx
	addq	%rcx, %rax
	movq	%rax, -32(%rbp)
	leaq	-32(%rbp), %r14
	shrq	%r14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-32(%rbp), %rdi         # Instruction is Tainted 
	pinsrq	$0, -8(%rsp), %xmm15
	callq	make_byte_symbolic      # Instruction is Tainted 
.LBB5_9_CartridgeEnd:
.LBB5_10:
.LBB5_10_CartridgeHead:
	leaq	.LBB5_10_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_10_CartridgeBody:
	leaq	-4(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	$0, -4(%rbp)            # Instruction is Tainted 
.LBB5_10_CartridgeEnd:
.LBB5_11:                               # =>This Inner Loop Header: Depth=1
.LBB5_11_CartridgeHead:
	leaq	.LBB5_11_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_11_CartridgeBody:
	leaq	-4(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-4(%rbp), %eax          # Instruction is Tainted 
	movl	repetitions, %ecx
	cmpl	%ecx, %eax
	jge	.LBB5_14
.LBB5_11_CartridgeEnd:
# %bb.12:                               #   in Loop: Header=BB5_11 Depth=1
.LBB5_12_CartridgeHead:
	leaq	.LBB5_12_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_12_CartridgeBody:
	leaq	-16(%rbp), %r14
	shrq	%r14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-16(%rbp), %rdi         # Instruction is Tainted 
	leaq	-24(%rbp), %r14
	shrq	%r14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-24(%rbp), %rsi         # Instruction is Tainted 
	leaq	-40(%rbp), %r14
	shrq	%r14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-40(%rbp), %rdx         # Instruction is Tainted 
	pinsrq	$0, -8(%rsp), %xmm15
	callq	runTest                 # Instruction is Tainted 
.LBB5_12_CartridgeEnd:
# %bb.13:                               #   in Loop: Header=BB5_11 Depth=1
.LBB5_13_CartridgeHead:
	leaq	.LBB5_13_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_13_CartridgeBody:
	movl	-4(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	.LBB5_11
.LBB5_13_CartridgeEnd:
.LBB5_14:
.LBB5_14_CartridgeHead:
	leaq	.LBB5_14_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_14_CartridgeBody:
	addq	$48, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB5_14_CartridgeEnd:
# %bb.15:
.LBB5_15_CartridgeHead:
	leaq	.LBB5_15_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_15_CartridgeBody:
	retq
.LBB5_15_CartridgeEnd:
.Lfunc_end5:
	.size	begin_target_inner, .Lfunc_end5-begin_target_inner
	.cfi_endproc
                                        # -- End function
	.globl	runTest                 # -- Begin function runTest
	.p2align	4, 0x90
	.type	runTest,@function
runTest:                                # @runTest
	.cfi_startproc
# %bb.0:
.LBB6_0_CartridgeHead:
	leaq	.LBB6_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	leaq	-40(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	%rdi, -40(%rbp)         # Instruction is Tainted 
	movq	%rsi, -32(%rbp)
	movq	%rdx, -24(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, resultPtr
	movw	$0, -2(%rbp)
	movl	$0, -8(%rbp)
.LBB6_0_CartridgeEnd:
.LBB6_1:                                # =>This Inner Loop Header: Depth=1
.LBB6_1_CartridgeHead:
	leaq	.LBB6_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_1_CartridgeBody:
	leaq	-8(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-8(%rbp), %eax          # Instruction is Tainted 
	movl	numEntries, %ecx
	cmpl	%ecx, %eax
	jge	.LBB6_4
.LBB6_1_CartridgeEnd:
# %bb.2:                                #   in Loop: Header=BB6_1 Depth=1
.LBB6_2_CartridgeHead:
	leaq	.LBB6_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_2_CartridgeBody:
	leaq	-40(%rbp), %r14
	shrq	%r14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-40(%rbp), %rax         # Instruction is Tainted 
	leaq	-8(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-8(%rbp), %ecx          # Instruction is Tainted 
	movslq	%ecx, %rcx              # Instruction is Tainted 
	leaq	(%rax,%rcx), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	pinsrw	$4, (%r14,%r14), %xmm15
	movb	(%rax,%rcx), %al        # Instruction is Tainted 
	movzbl	%al, %eax               # Instruction is Tainted 
	movzwl	%ax, %eax
	leaq	-32(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	pcmpeqw	%xmm13, %xmm15
	por	%xmm15, %xmm14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-32(%rbp), %rcx         # Instruction is Tainted 
	leaq	-8(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-8(%rbp), %edx          # Instruction is Tainted 
	movslq	%edx, %rdx              # Instruction is Tainted 
	leaq	(%rcx,%rdx), %r14
	shrq	%r14
	pinsrw	$4, (%r14,%r14), %xmm15
	movb	(%rcx,%rdx), %cl        # Instruction is Tainted 
	movzbl	%cl, %ecx               # Instruction is Tainted 
	movzwl	%cx, %ecx
	addl	%ecx, %eax
	leaq	-2(%rbp), %r14
	shrq	%r14
	pinsrd	$3, (%r14,%r14), %xmm15
	movw	-2(%rbp), %cx           # Instruction is Tainted 
	movzwl	%cx, %ecx
	addl	%ecx, %eax
	leaq	-10(%rbp), %r14
	shrq	%r14
	pcmpeqw	%xmm13, %xmm15
	por	%xmm15, %xmm14
	movss	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero,zero,zero
	movw	%ax, -10(%rbp)          # Instruction is Tainted 
	leaq	-10(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	pinsrd	$1, (%r14,%r14), %xmm15
	movw	-10(%rbp), %ax          # Instruction is Tainted 
	movzwl	%ax, %eax               # Instruction is Tainted 
	cltd                            # Instruction is Tainted 
	movl	$256, %ecx              # Instruction is Tainted 
                                        # imm = 0x100
	idivl	%ecx                    # Instruction is Tainted 
	leaq	-2(%rbp), %r14
	shrq	%r14
	pinsrd	$2, (%r14,%r14), %xmm15
	movw	%ax, -2(%rbp)           # Instruction is Tainted 
	leaq	-10(%rbp), %r14
	shrq	%r14
	pinsrd	$3, (%r14,%r14), %xmm15
	movw	-10(%rbp), %ax          # Instruction is Tainted 
	movzbl	%al, %eax
	andl	$255, %eax
	leaq	-24(%rbp), %r14
	shrq	%r14
	pcmpeqw	%xmm13, %xmm15
	por	%xmm15, %xmm14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-24(%rbp), %rcx         # Instruction is Tainted 
	leaq	-8(%rbp), %r14
	shrq	%r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	-8(%rbp), %edx          # Instruction is Tainted 
	movslq	%edx, %rdx              # Instruction is Tainted 
	leaq	(%rcx,%rdx), %r14
	shrq	%r14
	pinsrw	$4, (%r14,%r14), %xmm15
	movb	%al, (%rcx,%rdx)        # Instruction is Tainted 
.LBB6_2_CartridgeEnd:
# %bb.3:                                #   in Loop: Header=BB6_1 Depth=1
.LBB6_3_CartridgeHead:
	leaq	.LBB6_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_3_CartridgeBody:
	movl	-8(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -8(%rbp)
	jmp	.LBB6_1
.LBB6_3_CartridgeEnd:
.LBB6_4:
.LBB6_4_CartridgeHead:
	leaq	.LBB6_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_4_CartridgeBody:
	leaq	-2(%rbp), %r14
	shrq	%r14
	movss	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero,zero,zero
	movw	-2(%rbp), %ax           # Instruction is Tainted 
	leaq	-24(%rbp), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	pcmpeqw	%xmm13, %xmm15
	por	%xmm15, %xmm14
	vpcmpeqw	(%r14,%r14), %xmm13, %xmm15
	por	%xmm15, %xmm14
	movq	-24(%rbp), %rcx         # Instruction is Tainted 
	leaq	numEntries, %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	movsd	(%r14,%r14), %xmm15     # xmm15 = mem[0],zero
	movl	numEntries, %edx        # Instruction is Tainted 
	movslq	%edx, %rdx              # Instruction is Tainted 
	leaq	(%rcx,%rdx), %r14
	shrq	%r14
	pinsrw	$4, (%r14,%r14), %xmm15
	movb	%al, (%rcx,%rdx)        # Instruction is Tainted 
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB6_4_CartridgeEnd:
# %bb.5:
.LBB6_5_CartridgeHead:
	leaq	.LBB6_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_5_CartridgeBody:
	retq
.LBB6_5_CartridgeEnd:
.Lfunc_end6:
	.size	runTest, .Lfunc_end6-runTest
	.cfi_endproc
                                        # -- End function
	.type	symIndex,@object        # @symIndex
	.comm	symIndex,4,4
	.type	numEntries,@object      # @numEntries
	.comm	numEntries,4,4
	.type	repetitions,@object     # @repetitions
	.data
	.globl	repetitions
	.p2align	2
repetitions:
	.long	1                       # 0x1
	.size	repetitions, 4

	.type	testType,@object        # @testType
	.globl	testType
	.p2align	2
testType:
	.long	1                       # 0x1
	.size	testType, 4

	.type	garbageCtr,@object      # @garbageCtr
	.globl	garbageCtr
garbageCtr:
	.byte	1                       # 0x1
	.size	garbageCtr, 1

	.type	resultPtr,@object       # @resultPtr
	.comm	resultPtr,8,8

	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
	.addrsig
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

	.long	.LBB1_0_CartridgeHead
	.short	.LBB1_0_CartridgeBody-.LBB1_0_CartridgeHead
	.short	.LBB1_0_CartridgeEnd-.LBB1_0_CartridgeBody

	.long	.LBB1_1_CartridgeHead
	.short	.LBB1_1_CartridgeBody-.LBB1_1_CartridgeHead
	.short	.LBB1_1_CartridgeEnd-.LBB1_1_CartridgeBody

	.long	.LBB2_0_CartridgeHead
	.short	.LBB2_0_CartridgeBody-.LBB2_0_CartridgeHead
	.short	.LBB2_0_CartridgeEnd-.LBB2_0_CartridgeBody

	.long	.LBB2_1_CartridgeHead
	.short	.LBB2_1_CartridgeBody-.LBB2_1_CartridgeHead
	.short	.LBB2_1_CartridgeEnd-.LBB2_1_CartridgeBody

	.long	.LBB2_2_CartridgeHead
	.short	.LBB2_2_CartridgeBody-.LBB2_2_CartridgeHead
	.short	.LBB2_2_CartridgeEnd-.LBB2_2_CartridgeBody

	.long	.LBB2_3_CartridgeHead
	.short	.LBB2_3_CartridgeBody-.LBB2_3_CartridgeHead
	.short	.LBB2_3_CartridgeEnd-.LBB2_3_CartridgeBody

	.long	.LBB2_4_CartridgeHead
	.short	.LBB2_4_CartridgeBody-.LBB2_4_CartridgeHead
	.short	.LBB2_4_CartridgeEnd-.LBB2_4_CartridgeBody

	.long	.LBB2_5_CartridgeHead
	.short	.LBB2_5_CartridgeBody-.LBB2_5_CartridgeHead
	.short	.LBB2_5_CartridgeEnd-.LBB2_5_CartridgeBody

	.long	.LBB2_6_CartridgeHead
	.short	.LBB2_6_CartridgeBody-.LBB2_6_CartridgeHead
	.short	.LBB2_6_CartridgeEnd-.LBB2_6_CartridgeBody

	.long	.LBB2_7_CartridgeHead
	.short	.LBB2_7_CartridgeBody-.LBB2_7_CartridgeHead
	.short	.LBB2_7_CartridgeEnd-.LBB2_7_CartridgeBody

	.long	.LBB2_8_CartridgeHead
	.short	.LBB2_8_CartridgeBody-.LBB2_8_CartridgeHead
	.short	.LBB2_8_CartridgeEnd-.LBB2_8_CartridgeBody

	.long	.LBB2_9_CartridgeHead
	.short	.LBB2_9_CartridgeBody-.LBB2_9_CartridgeHead
	.short	.LBB2_9_CartridgeEnd-.LBB2_9_CartridgeBody

	.long	.LBB2_10_CartridgeHead
	.short	.LBB2_10_CartridgeBody-.LBB2_10_CartridgeHead
	.short	.LBB2_10_CartridgeEnd-.LBB2_10_CartridgeBody

	.long	.LBB3_0_CartridgeHead
	.short	.LBB3_0_CartridgeBody-.LBB3_0_CartridgeHead
	.short	.LBB3_0_CartridgeEnd-.LBB3_0_CartridgeBody

	.long	.LBB3_1_CartridgeHead
	.short	.LBB3_1_CartridgeBody-.LBB3_1_CartridgeHead
	.short	.LBB3_1_CartridgeEnd-.LBB3_1_CartridgeBody

	.long	.LBB3_2_CartridgeHead
	.short	.LBB3_2_CartridgeBody-.LBB3_2_CartridgeHead
	.short	.LBB3_2_CartridgeEnd-.LBB3_2_CartridgeBody

	.long	.LBB3_3_CartridgeHead
	.short	.LBB3_3_CartridgeBody-.LBB3_3_CartridgeHead
	.short	.LBB3_3_CartridgeEnd-.LBB3_3_CartridgeBody

	.long	.LBB3_4_CartridgeHead
	.short	.LBB3_4_CartridgeBody-.LBB3_4_CartridgeHead
	.short	.LBB3_4_CartridgeEnd-.LBB3_4_CartridgeBody

	.long	.LBB3_5_CartridgeHead
	.short	.LBB3_5_CartridgeBody-.LBB3_5_CartridgeHead
	.short	.LBB3_5_CartridgeEnd-.LBB3_5_CartridgeBody

	.long	.LBB4_0_CartridgeHead
	.short	.LBB4_0_CartridgeBody-.LBB4_0_CartridgeHead
	.short	.LBB4_0_CartridgeEnd-.LBB4_0_CartridgeBody

	.long	.LBB4_1_CartridgeHead
	.short	.LBB4_1_CartridgeBody-.LBB4_1_CartridgeHead
	.short	.LBB4_1_CartridgeEnd-.LBB4_1_CartridgeBody

	.long	.LBB4_2_CartridgeHead
	.short	.LBB4_2_CartridgeBody-.LBB4_2_CartridgeHead
	.short	.LBB4_2_CartridgeEnd-.LBB4_2_CartridgeBody

	.long	.LBB4_3_CartridgeHead
	.short	.LBB4_3_CartridgeBody-.LBB4_3_CartridgeHead
	.short	.LBB4_3_CartridgeEnd-.LBB4_3_CartridgeBody

	.long	.LBB4_4_CartridgeHead
	.short	.LBB4_4_CartridgeBody-.LBB4_4_CartridgeHead
	.short	.LBB4_4_CartridgeEnd-.LBB4_4_CartridgeBody

	.long	.LBB4_5_CartridgeHead
	.short	.LBB4_5_CartridgeBody-.LBB4_5_CartridgeHead
	.short	.LBB4_5_CartridgeEnd-.LBB4_5_CartridgeBody

	.long	.LBB5_0_CartridgeHead
	.short	.LBB5_0_CartridgeBody-.LBB5_0_CartridgeHead
	.short	.LBB5_0_CartridgeEnd-.LBB5_0_CartridgeBody

	.long	.LBB5_1_CartridgeHead
	.short	.LBB5_1_CartridgeBody-.LBB5_1_CartridgeHead
	.short	.LBB5_1_CartridgeEnd-.LBB5_1_CartridgeBody

	.long	.LBB5_2_CartridgeHead
	.short	.LBB5_2_CartridgeBody-.LBB5_2_CartridgeHead
	.short	.LBB5_2_CartridgeEnd-.LBB5_2_CartridgeBody

	.long	.LBB5_3_CartridgeHead
	.short	.LBB5_3_CartridgeBody-.LBB5_3_CartridgeHead
	.short	.LBB5_3_CartridgeEnd-.LBB5_3_CartridgeBody

	.long	.LBB5_4_CartridgeHead
	.short	.LBB5_4_CartridgeBody-.LBB5_4_CartridgeHead
	.short	.LBB5_4_CartridgeEnd-.LBB5_4_CartridgeBody

	.long	.LBB5_5_CartridgeHead
	.short	.LBB5_5_CartridgeBody-.LBB5_5_CartridgeHead
	.short	.LBB5_5_CartridgeEnd-.LBB5_5_CartridgeBody

	.long	.LBB5_6_CartridgeHead
	.short	.LBB5_6_CartridgeBody-.LBB5_6_CartridgeHead
	.short	.LBB5_6_CartridgeEnd-.LBB5_6_CartridgeBody

	.long	.LBB5_7_CartridgeHead
	.short	.LBB5_7_CartridgeBody-.LBB5_7_CartridgeHead
	.short	.LBB5_7_CartridgeEnd-.LBB5_7_CartridgeBody

	.long	.LBB5_8_CartridgeHead
	.short	.LBB5_8_CartridgeBody-.LBB5_8_CartridgeHead
	.short	.LBB5_8_CartridgeEnd-.LBB5_8_CartridgeBody

	.long	.LBB5_9_CartridgeHead
	.short	.LBB5_9_CartridgeBody-.LBB5_9_CartridgeHead
	.short	.LBB5_9_CartridgeEnd-.LBB5_9_CartridgeBody

	.long	.LBB5_10_CartridgeHead
	.short	.LBB5_10_CartridgeBody-.LBB5_10_CartridgeHead
	.short	.LBB5_10_CartridgeEnd-.LBB5_10_CartridgeBody

	.long	.LBB5_11_CartridgeHead
	.short	.LBB5_11_CartridgeBody-.LBB5_11_CartridgeHead
	.short	.LBB5_11_CartridgeEnd-.LBB5_11_CartridgeBody

	.long	.LBB5_12_CartridgeHead
	.short	.LBB5_12_CartridgeBody-.LBB5_12_CartridgeHead
	.short	.LBB5_12_CartridgeEnd-.LBB5_12_CartridgeBody

	.long	.LBB5_13_CartridgeHead
	.short	.LBB5_13_CartridgeBody-.LBB5_13_CartridgeHead
	.short	.LBB5_13_CartridgeEnd-.LBB5_13_CartridgeBody

	.long	.LBB5_14_CartridgeHead
	.short	.LBB5_14_CartridgeBody-.LBB5_14_CartridgeHead
	.short	.LBB5_14_CartridgeEnd-.LBB5_14_CartridgeBody

	.long	.LBB5_15_CartridgeHead
	.short	.LBB5_15_CartridgeBody-.LBB5_15_CartridgeHead
	.short	.LBB5_15_CartridgeEnd-.LBB5_15_CartridgeBody

	.long	.LBB6_0_CartridgeHead
	.short	.LBB6_0_CartridgeBody-.LBB6_0_CartridgeHead
	.short	.LBB6_0_CartridgeEnd-.LBB6_0_CartridgeBody

	.long	.LBB6_1_CartridgeHead
	.short	.LBB6_1_CartridgeBody-.LBB6_1_CartridgeHead
	.short	.LBB6_1_CartridgeEnd-.LBB6_1_CartridgeBody

	.long	.LBB6_2_CartridgeHead
	.short	.LBB6_2_CartridgeBody-.LBB6_2_CartridgeHead
	.short	.LBB6_2_CartridgeEnd-.LBB6_2_CartridgeBody

	.long	.LBB6_3_CartridgeHead
	.short	.LBB6_3_CartridgeBody-.LBB6_3_CartridgeHead
	.short	.LBB6_3_CartridgeEnd-.LBB6_3_CartridgeBody

	.long	.LBB6_4_CartridgeHead
	.short	.LBB6_4_CartridgeBody-.LBB6_4_CartridgeHead
	.short	.LBB6_4_CartridgeEnd-.LBB6_4_CartridgeBody

	.long	.LBB6_5_CartridgeHead
	.short	.LBB6_5_CartridgeBody-.LBB6_5_CartridgeHead
	.short	.LBB6_5_CartridgeEnd-.LBB6_5_CartridgeBody

                                        # End of TASE Cartridge records
	.section	.rodata.tase_modeled_records,"",@progbits
	.section	.rodata.tase_live_flags_block_records,"",@progbits
                                        # Start of TASE list of blocks with live flags 
                                        # End of TASE live flags block records section
	.section	".note.GNU-stack","",@progbits
