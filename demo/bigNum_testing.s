	.text
	.file	"bigNum.c"
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
	pushq	%rax
	.cfi_offset %rbx, -24
	movq	%rsi, %rbx
	movq	8(%rsi), %rdi
	callq	atoi
.LBB0_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB0_1_CartridgeHead:
	leaq	.LBB0_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_1_CartridgeBody:
	movl	%eax, symIndex(%rip)
	movq	16(%rbx), %rdi
	callq	atoi
.LBB0_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB0_2_CartridgeHead:
	leaq	.LBB0_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_2_CartridgeBody:
	movl	%eax, numEntries(%rip)
	movq	24(%rbx), %rdi
	callq	atoi
.LBB0_2_CartridgeEnd:
# %bb.3:                                # %entry
.LBB0_3_CartridgeHead:
	leaq	.LBB0_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_3_CartridgeBody:
	movl	%eax, repetitions(%rip)
	callq	begin_target_inner
.LBB0_3_CartridgeEnd:
# %bb.4:                                # %entry
.LBB0_4_CartridgeHead:
	leaq	.LBB0_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB0_4_CartridgeBody:
	xorl	%eax, %eax
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB0_4_CartridgeEnd:
# %bb.5:                                # %entry
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
# %bb.0:                                # %entry
.LBB1_0_CartridgeHead:
	leaq	.LBB1_0_CartridgeBody(%rip), %r15
	jmp	sb_modeled
.LBB1_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB1_0_CartridgeEnd:
# %bb.1:                                # %entry
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
# %bb.0:                                # %entry
.LBB2_0_CartridgeHead:
	leaq	.LBB2_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	numEntries(%rip), %eax
	testl	%eax, %eax
	jle	.LBB2_8
.LBB2_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB2_1_CartridgeHead:
	leaq	.LBB2_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_1_CartridgeBody:
	xorl	%ecx, %ecx
.LBB2_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB2_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB2_2_CartridgeHead:
	leaq	.LBB2_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_2_CartridgeBody:
	movl	testType(%rip), %eax
	testl	%eax, %eax
	je	.LBB2_5
.LBB2_2_CartridgeEnd:
# %bb.3:                                # %for.body
                                        #   in Loop: Header=BB2_2 Depth=1
.LBB2_3_CartridgeHead:
	leaq	.LBB2_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_3_CartridgeBody:
	cmpl	$1, %eax
	jne	.LBB2_7
.LBB2_3_CartridgeEnd:
# %bb.4:                                # %if.then3
                                        #   in Loop: Header=BB2_2 Depth=1
.LBB2_4_CartridgeHead:
	leaq	.LBB2_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_4_CartridgeBody:
	movzbl	garbageCtr(%rip), %eax
	mulb	%al
	addb	$7, %al
	movb	%al, garbageCtr(%rip)
	jmp	.LBB2_6
.LBB2_4_CartridgeEnd:
	.p2align	4, 0x90
.LBB2_5:                                #   in Loop: Header=BB2_2 Depth=1
.LBB2_5_CartridgeHead:
	leaq	.LBB2_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_5_CartridgeBody:
	movb	$1, %al
.LBB2_5_CartridgeEnd:
.LBB2_6:                                # %for.inc.sink.split
                                        #   in Loop: Header=BB2_2 Depth=1
.LBB2_6_CartridgeHead:
	leaq	.LBB2_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_6_CartridgeBody:
	movb	%al, (%rdi,%rcx)
.LBB2_6_CartridgeEnd:
.LBB2_7:                                # %for.inc
                                        #   in Loop: Header=BB2_2 Depth=1
.LBB2_7_CartridgeHead:
	leaq	.LBB2_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_7_CartridgeBody:
	addq	$1, %rcx
	movslq	numEntries(%rip), %rax
	cmpq	%rax, %rcx
	jl	.LBB2_2
.LBB2_7_CartridgeEnd:
.LBB2_8:                                # %for.end
.LBB2_8_CartridgeHead:
	leaq	.LBB2_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_8_CartridgeBody:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB2_8_CartridgeEnd:
# %bb.9:                                # %for.end
.LBB2_9_CartridgeHead:
	leaq	.LBB2_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_9_CartridgeBody:
	retq
.LBB2_9_CartridgeEnd:
.Lfunc_end2:
	.size	initializeNums, .Lfunc_end2-initializeNums
	.cfi_endproc
                                        # -- End function
	.globl	initializeAllOnes       # -- Begin function initializeAllOnes
	.p2align	4, 0x90
	.type	initializeAllOnes,@function
initializeAllOnes:                      # @initializeAllOnes
	.cfi_startproc
# %bb.0:                                # %entry
.LBB3_0_CartridgeHead:
	leaq	.LBB3_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	numEntries(%rip), %eax
	testl	%eax, %eax
	jle	.LBB3_3
.LBB3_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB3_1_CartridgeHead:
	leaq	.LBB3_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_1_CartridgeBody:
	xorl	%eax, %eax
.LBB3_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB3_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB3_2_CartridgeHead:
	leaq	.LBB3_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_2_CartridgeBody:
	movb	$-1, (%rdi,%rax)
	addq	$1, %rax
	movslq	numEntries(%rip), %rcx
	cmpq	%rcx, %rax
	jl	.LBB3_2
.LBB3_2_CartridgeEnd:
.LBB3_3:                                # %for.end
.LBB3_3_CartridgeHead:
	leaq	.LBB3_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_3_CartridgeBody:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB3_3_CartridgeEnd:
# %bb.4:                                # %for.end
.LBB3_4_CartridgeHead:
	leaq	.LBB3_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_4_CartridgeBody:
	retq
.LBB3_4_CartridgeEnd:
.Lfunc_end3:
	.size	initializeAllOnes, .Lfunc_end3-initializeAllOnes
	.cfi_endproc
                                        # -- End function
	.globl	initializeAllZeros      # -- Begin function initializeAllZeros
	.p2align	4, 0x90
	.type	initializeAllZeros,@function
initializeAllZeros:                     # @initializeAllZeros
	.cfi_startproc
# %bb.0:                                # %entry
.LBB4_0_CartridgeHead:
	leaq	.LBB4_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	numEntries(%rip), %eax
	testl	%eax, %eax
	jle	.LBB4_3
.LBB4_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB4_1_CartridgeHead:
	leaq	.LBB4_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_1_CartridgeBody:
	xorl	%eax, %eax
.LBB4_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB4_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB4_2_CartridgeHead:
	leaq	.LBB4_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_2_CartridgeBody:
	movb	$0, (%rdi,%rax)
	addq	$1, %rax
	movslq	numEntries(%rip), %rcx
	cmpq	%rcx, %rax
	jl	.LBB4_2
.LBB4_2_CartridgeEnd:
.LBB4_3:                                # %for.end
.LBB4_3_CartridgeHead:
	leaq	.LBB4_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_3_CartridgeBody:
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB4_3_CartridgeEnd:
# %bb.4:                                # %for.end
.LBB4_4_CartridgeHead:
	leaq	.LBB4_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_4_CartridgeBody:
	retq
.LBB4_4_CartridgeEnd:
.Lfunc_end4:
	.size	initializeAllZeros, .Lfunc_end4-initializeAllZeros
	.cfi_endproc
                                        # -- End function
	.globl	begin_target_inner      # -- Begin function begin_target_inner
	.p2align	4, 0x90
	.type	begin_target_inner,@function
begin_target_inner:                     # @begin_target_inner
	.cfi_startproc
# %bb.0:                                # %entry
.LBB5_0_CartridgeHead:
	leaq	.LBB5_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r13, -24
	movslq	numEntries(%rip), %rbx
	movq	%rbx, %rdi
	callq	malloc
.LBB5_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB5_1_CartridgeHead:
	leaq	.LBB5_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_1_CartridgeBody:
	movq	%rax, %r13
	movq	%rbx, %rdi
	callq	malloc
.LBB5_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB5_2_CartridgeHead:
	leaq	.LBB5_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_2_CartridgeBody:
	movq	%rax, %r12
	addq	$1, %rbx
	movq	%rbx, %rdi
	callq	malloc
.LBB5_2_CartridgeEnd:
# %bb.3:                                # %entry
.LBB5_3_CartridgeHead:
	leaq	.LBB5_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_3_CartridgeBody:
	movq	%rax, -32(%rbp)         # 8-byte Spill
	movq	%r13, %rbx
	movq	%r13, %rdi
	callq	initializeNums
.LBB5_3_CartridgeEnd:
# %bb.4:                                # %entry
.LBB5_4_CartridgeHead:
	leaq	.LBB5_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_4_CartridgeBody:
	movq	%r12, %rdi
	callq	initializeNums
.LBB5_4_CartridgeEnd:
# %bb.5:                                # %entry
.LBB5_5_CartridgeHead:
	leaq	.LBB5_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_5_CartridgeBody:
	movq	%r13, %rdi
	callq	initializeAllZeros
.LBB5_5_CartridgeEnd:
# %bb.6:                                # %entry
.LBB5_6_CartridgeHead:
	leaq	.LBB5_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_6_CartridgeBody:
	movq	%r12, %rbx
	movq	%r12, %rdi
	callq	initializeAllOnes
.LBB5_6_CartridgeEnd:
# %bb.7:                                # %entry
.LBB5_7_CartridgeHead:
	leaq	.LBB5_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_7_CartridgeBody:
	movl	repetitions(%rip), %eax
	testl	%eax, %eax
	jle	.LBB5_11
.LBB5_7_CartridgeEnd:
# %bb.8:                                # %for.body.preheader
.LBB5_8_CartridgeHead:
	leaq	.LBB5_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_8_CartridgeBody:
	xorl	%r12d, %r12d
.LBB5_8_CartridgeEnd:
	.p2align	4, 0x90
.LBB5_9:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB5_9_CartridgeHead:
	leaq	.LBB5_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_9_CartridgeBody:
	movq	%r13, %rdi              # Instruction is Tainted 
	movq	%rbx, %rsi              # Instruction is Tainted 
	movq	-32(%rbp), %rdx         # 8-byte Reload
	pinsrq	$0, -8(%rsp), %xmm15
	callq	runTest                 # Instruction is Tainted 
.LBB5_9_CartridgeEnd:
# %bb.10:                               # %for.body
                                        #   in Loop: Header=BB5_9 Depth=1
.LBB5_10_CartridgeHead:
	leaq	.LBB5_10_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_10_CartridgeBody:
	addl	$1, %r12d
	movl	repetitions(%rip), %eax
	cmpl	%eax, %r12d
	jl	.LBB5_9
.LBB5_10_CartridgeEnd:
.LBB5_11:                               # %for.end
.LBB5_11_CartridgeHead:
	leaq	.LBB5_11_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_11_CartridgeBody:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB5_11_CartridgeEnd:
# %bb.12:                               # %for.end
.LBB5_12_CartridgeHead:
	leaq	.LBB5_12_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_12_CartridgeBody:
	retq
.LBB5_12_CartridgeEnd:
.Lfunc_end5:
	.size	begin_target_inner, .Lfunc_end5-begin_target_inner
	.cfi_endproc
                                        # -- End function
	.globl	runTest                 # -- Begin function runTest
	.p2align	4, 0x90
	.type	runTest,@function
runTest:                                # @runTest
	.cfi_startproc
# %bb.0:                                # %entry
.LBB6_0_CartridgeHead:
	leaq	.LBB6_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdx, resultPtr(%rip)
	movl	numEntries(%rip), %r8d
	testl	%r8d, %r8d
	jle	.LBB6_3
.LBB6_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB6_1_CartridgeHead:
	leaq	.LBB6_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_1_CartridgeBody:
	xorl	%ecx, %ecx
	xorl	%eax, %eax
.LBB6_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB6_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB6_2_CartridgeHead:
	leaq	.LBB6_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_2_CartridgeBody:
	movzbl	(%rdi,%rcx), %r8d
	movzbl	(%rsi,%rcx), %r9d
	addl	%r8d, %eax
	addl	%r9d, %eax
	leaq	(%rdx,%rcx), %r14
	shrq	%r14
	pinsrw	$0, (%r14,%r14), %xmm15
	movb	%al, (%rdx,%rcx)        # Instruction is Tainted 
	movzbl	%ah, %eax
	addq	$1, %rcx
	movslq	numEntries(%rip), %r8
	cmpq	%r8, %rcx
	jl	.LBB6_2
.LBB6_2_CartridgeEnd:
	jmp	.LBB6_4
.LBB6_3:
.LBB6_3_CartridgeHead:
	leaq	.LBB6_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_3_CartridgeBody:
	xorl	%eax, %eax
.LBB6_3_CartridgeEnd:
.LBB6_4:                                # %for.end
.LBB6_4_CartridgeHead:
	leaq	.LBB6_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB6_4_CartridgeBody:
	movslq	%r8d, %rcx              # Instruction is Tainted 
	leaq	(%rdx,%rcx), %r14
	shrq	%r14
	pinsrw	$0, (%r14,%r14), %xmm15
	movb	%al, (%rdx,%rcx)        # Instruction is Tainted 
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	movq	(%rsp), %r14
.LBB6_4_CartridgeEnd:
# %bb.5:                                # %for.end
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
