	.text
	.file	"bigNum.c"
	.globl	make_byte_symbolic      # -- Begin function make_byte_symbolic
	.p2align	4, 0x90
	.type	make_byte_symbolic,@function
make_byte_symbolic:                     # @make_byte_symbolic
	.cfi_startproc
# %bb.0:                                # %entry
.LBB0_0_CartridgeHead:
	leaq	.LBB0_0_CartridgeBody(%rip), %r15
	jmp	sb_modeled
.LBB0_0_CartridgeBody:
	movq	%rdi, %rsi
	movl	$.L.str, %edi
	xorl	%eax, %eax
	jmp	printf                  # TAILCALL
.LBB0_0_CartridgeEnd:
.Lfunc_end0:
	.size	make_byte_symbolic, .Lfunc_end0-make_byte_symbolic
	.cfi_endproc
                                        # -- End function
	.globl	initializeNums          # -- Begin function initializeNums
	.p2align	4, 0x90
	.type	initializeNums,@function
initializeNums:                         # @initializeNums
	.cfi_startproc
# %bb.0:                                # %entry
.LBB1_0_CartridgeHead:
	leaq	.LBB1_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_0_CartridgeBody:
	movl	numEntries(%rip), %eax
	testl	%eax, %eax
	jle	.LBB1_8
.LBB1_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB1_1_CartridgeHead:
	leaq	.LBB1_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_1_CartridgeBody:
	xorl	%ecx, %ecx
.LBB1_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB1_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB1_2_CartridgeHead:
	leaq	.LBB1_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_2_CartridgeBody:
	movl	testType(%rip), %eax
	testl	%eax, %eax
	je	.LBB1_5
.LBB1_2_CartridgeEnd:
# %bb.3:                                # %for.body
                                        #   in Loop: Header=BB1_2 Depth=1
.LBB1_3_CartridgeHead:
	leaq	.LBB1_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_3_CartridgeBody:
	cmpl	$1, %eax
	jne	.LBB1_7
.LBB1_3_CartridgeEnd:
# %bb.4:                                # %if.then3
                                        #   in Loop: Header=BB1_2 Depth=1
.LBB1_4_CartridgeHead:
	leaq	.LBB1_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_4_CartridgeBody:
	movzbl	garbageCtr(%rip), %eax
	mulb	%al
	addb	$7, %al
	movb	%al, garbageCtr(%rip)
	jmp	.LBB1_6
.LBB1_4_CartridgeEnd:
	.p2align	4, 0x90
.LBB1_5:                                #   in Loop: Header=BB1_2 Depth=1
.LBB1_5_CartridgeHead:
	leaq	.LBB1_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_5_CartridgeBody:
	movb	$1, %al
.LBB1_5_CartridgeEnd:
.LBB1_6:                                # %for.inc.sink.split
                                        #   in Loop: Header=BB1_2 Depth=1
.LBB1_6_CartridgeHead:
	leaq	.LBB1_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_6_CartridgeBody:
	movb	%al, (%rdi,%rcx)
.LBB1_6_CartridgeEnd:
.LBB1_7:                                # %for.inc
                                        #   in Loop: Header=BB1_2 Depth=1
.LBB1_7_CartridgeHead:
	leaq	.LBB1_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_7_CartridgeBody:
	addq	$1, %rcx
	movslq	numEntries(%rip), %rax
	cmpq	%rax, %rcx
	jl	.LBB1_2
.LBB1_7_CartridgeEnd:
.LBB1_8:                                # %for.cond.cleanup
.LBB1_8_CartridgeHead:
	leaq	.LBB1_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_8_CartridgeBody:
	movq	(%rsp), %r14
.LBB1_8_CartridgeEnd:
# %bb.9:                                # %for.cond.cleanup
.LBB1_9_CartridgeHead:
	leaq	.LBB1_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_9_CartridgeBody:
	retq
.LBB1_9_CartridgeEnd:
.Lfunc_end1:
	.size	initializeNums, .Lfunc_end1-initializeNums
	.cfi_endproc
                                        # -- End function
	.globl	initializeAllOnes       # -- Begin function initializeAllOnes
	.p2align	4, 0x90
	.type	initializeAllOnes,@function
initializeAllOnes:                      # @initializeAllOnes
	.cfi_startproc
# %bb.0:                                # %entry
.LBB2_0_CartridgeHead:
	leaq	.LBB2_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_0_CartridgeBody:
	movl	numEntries(%rip), %eax
	testl	%eax, %eax
	jle	.LBB2_3
.LBB2_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB2_1_CartridgeHead:
	leaq	.LBB2_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_1_CartridgeBody:
	xorl	%eax, %eax
.LBB2_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB2_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB2_2_CartridgeHead:
	leaq	.LBB2_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_2_CartridgeBody:
	movb	$-1, (%rdi,%rax)
	addq	$1, %rax
	movslq	numEntries(%rip), %rcx
	cmpq	%rcx, %rax
	jl	.LBB2_2
.LBB2_2_CartridgeEnd:
.LBB2_3:                                # %for.cond.cleanup
.LBB2_3_CartridgeHead:
	leaq	.LBB2_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_3_CartridgeBody:
	movq	(%rsp), %r14
.LBB2_3_CartridgeEnd:
# %bb.4:                                # %for.cond.cleanup
.LBB2_4_CartridgeHead:
	leaq	.LBB2_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_4_CartridgeBody:
	retq
.LBB2_4_CartridgeEnd:
.Lfunc_end2:
	.size	initializeAllOnes, .Lfunc_end2-initializeAllOnes
	.cfi_endproc
                                        # -- End function
	.globl	initializeAllZeros      # -- Begin function initializeAllZeros
	.p2align	4, 0x90
	.type	initializeAllZeros,@function
initializeAllZeros:                     # @initializeAllZeros
	.cfi_startproc
# %bb.0:                                # %entry
.LBB3_0_CartridgeHead:
	leaq	.LBB3_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_0_CartridgeBody:
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
	movb	$0, (%rdi,%rax)
	addq	$1, %rax
	movslq	numEntries(%rip), %rcx
	cmpq	%rcx, %rax
	jl	.LBB3_2
.LBB3_2_CartridgeEnd:
.LBB3_3:                                # %for.cond.cleanup
.LBB3_3_CartridgeHead:
	leaq	.LBB3_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_3_CartridgeBody:
	movq	(%rsp), %r14
.LBB3_3_CartridgeEnd:
# %bb.4:                                # %for.cond.cleanup
.LBB3_4_CartridgeHead:
	leaq	.LBB3_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_4_CartridgeBody:
	retq
.LBB3_4_CartridgeEnd:
.Lfunc_end3:
	.size	initializeAllZeros, .Lfunc_end3-initializeAllZeros
	.cfi_endproc
                                        # -- End function
	.globl	begin_target_inner      # -- Begin function begin_target_inner
	.p2align	4, 0x90
	.type	begin_target_inner,@function
begin_target_inner:                     # @begin_target_inner
	.cfi_startproc
# %bb.0:                                # %entry
.LBB4_0_CartridgeHead:
	leaq	.LBB4_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_0_CartridgeBody:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r13
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r13, -24
	.cfi_offset %rbp, -16
	movl	numEntries(%rip), %edi
	callq	malloc_tase
.LBB4_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB4_1_CartridgeHead:
	leaq	.LBB4_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_1_CartridgeBody:
	movq	%rax, %r12
	movl	numEntries(%rip), %edi
	callq	malloc_tase
.LBB4_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB4_2_CartridgeHead:
	leaq	.LBB4_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_2_CartridgeBody:
	movq	%rax, %rbx
	movl	numEntries(%rip), %edi
	addl	$1, %edi
	callq	malloc_tase
.LBB4_2_CartridgeEnd:
# %bb.3:                                # %entry
.LBB4_3_CartridgeHead:
	leaq	.LBB4_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_3_CartridgeBody:
	movq	%rax, %r13
	movq	%r12, %rdi
	callq	initializeNums
.LBB4_3_CartridgeEnd:
# %bb.4:                                # %entry
.LBB4_4_CartridgeHead:
	leaq	.LBB4_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_4_CartridgeBody:
	movq	%rbx, %rdi
	callq	initializeNums
.LBB4_4_CartridgeEnd:
# %bb.5:                                # %entry
.LBB4_5_CartridgeHead:
	leaq	.LBB4_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_5_CartridgeBody:
	movq	%r12, %rdi
	callq	initializeAllZeros
.LBB4_5_CartridgeEnd:
# %bb.6:                                # %entry
.LBB4_6_CartridgeHead:
	leaq	.LBB4_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_6_CartridgeBody:
	movq	%rbx, %rdi
	callq	initializeAllOnes
.LBB4_6_CartridgeEnd:
# %bb.7:                                # %entry
.LBB4_7_CartridgeHead:
	leaq	.LBB4_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_7_CartridgeBody:
	movslq	symIndex(%rip), %rdi
	testq	%rdi, %rdi
	js	.LBB4_10
.LBB4_7_CartridgeEnd:
# %bb.8:                                # %entry
.LBB4_8_CartridgeHead:
	leaq	.LBB4_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_8_CartridgeBody:
	movl	numEntries(%rip), %eax
	cmpl	%eax, %edi
	jge	.LBB4_10
.LBB4_8_CartridgeEnd:
# %bb.9:                                # %if.then
.LBB4_9_CartridgeHead:
	leaq	.LBB4_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_9_CartridgeBody:
	addq	%r12, %rdi
	pinsrq	$0, -8(%rsp), %xmm15
	callq	make_byte_symbolic      # Instruction is Tainted 
.LBB4_9_CartridgeEnd:
.LBB4_10:                               # %if.end
.LBB4_10_CartridgeHead:
	leaq	.LBB4_10_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_10_CartridgeBody:
	movl	repetitions(%rip), %eax
	testl	%eax, %eax
	jle	.LBB4_14
.LBB4_10_CartridgeEnd:
# %bb.11:                               # %for.body.preheader
.LBB4_11_CartridgeHead:
	leaq	.LBB4_11_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_11_CartridgeBody:
	xorl	%ebp, %ebp
.LBB4_11_CartridgeEnd:
	.p2align	4, 0x90
.LBB4_12:                               # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB4_12_CartridgeHead:
	leaq	.LBB4_12_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_12_CartridgeBody:
	movq	%r12, %rdi              # Instruction is Tainted 
	movq	%rbx, %rsi              # Instruction is Tainted 
	movq	%r13, %rdx              # Instruction is Tainted 
	pinsrq	$0, -8(%rsp), %xmm15
	callq	runTest                 # Instruction is Tainted 
.LBB4_12_CartridgeEnd:
# %bb.13:                               # %for.body
                                        #   in Loop: Header=BB4_12 Depth=1
.LBB4_13_CartridgeHead:
	leaq	.LBB4_13_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_13_CartridgeBody:
	addl	$1, %ebp
	movl	repetitions(%rip), %eax
	cmpl	%eax, %ebp
	jl	.LBB4_12
.LBB4_13_CartridgeEnd:
.LBB4_14:                               # %for.cond.cleanup
.LBB4_14_CartridgeHead:
	leaq	.LBB4_14_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_14_CartridgeBody:
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	movq	(%rsp), %r14
.LBB4_14_CartridgeEnd:
# %bb.15:                               # %for.cond.cleanup
.LBB4_15_CartridgeHead:
	leaq	.LBB4_15_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_15_CartridgeBody:
	retq
.LBB4_15_CartridgeEnd:
.Lfunc_end4:
	.size	begin_target_inner, .Lfunc_end4-begin_target_inner
	.cfi_endproc
                                        # -- End function
	.globl	runTest                 # -- Begin function runTest
	.p2align	4, 0x90
	.type	runTest,@function
runTest:                                # @runTest
	.cfi_startproc
# %bb.0:                                # %entry
.LBB5_0_CartridgeHead:
	leaq	.LBB5_0_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_0_CartridgeBody:
	movq	%rdx, resultPtr(%rip)
	movl	numEntries(%rip), %r8d
	testl	%r8d, %r8d
	jle	.LBB5_3
.LBB5_0_CartridgeEnd:
# %bb.1:                                # %for.body.preheader
.LBB5_1_CartridgeHead:
	leaq	.LBB5_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_1_CartridgeBody:
	xorl	%ecx, %ecx
	xorl	%eax, %eax
.LBB5_1_CartridgeEnd:
	.p2align	4, 0x90
.LBB5_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB5_2_CartridgeHead:
	leaq	.LBB5_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_2_CartridgeBody:
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
	jl	.LBB5_2
.LBB5_2_CartridgeEnd:
	jmp	.LBB5_4
.LBB5_3:
.LBB5_3_CartridgeHead:
	leaq	.LBB5_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_3_CartridgeBody:
	xorl	%eax, %eax
.LBB5_3_CartridgeEnd:
.LBB5_4:                                # %for.cond.cleanup
.LBB5_4_CartridgeHead:
	leaq	.LBB5_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_4_CartridgeBody:
	movslq	%r8d, %rcx              # Instruction is Tainted 
	leaq	(%rdx,%rcx), %r14
	shrq	%r14
	pinsrw	$0, (%r14,%r14), %xmm15
	movb	%al, (%rdx,%rcx)        # Instruction is Tainted 
	movq	(%rsp), %r14
.LBB5_4_CartridgeEnd:
# %bb.5:                                # %for.cond.cleanup
.LBB5_5_CartridgeHead:
	leaq	.LBB5_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_5_CartridgeBody:
	retq
.LBB5_5_CartridgeEnd:
.Lfunc_end5:
	.size	runTest, .Lfunc_end5-runTest
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"Should never reach this line! Should've marked 0x%lx symbolic \n"
	.size	.L.str, 64

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

	.type	numEntries,@object      # @numEntries
	.comm	numEntries,4,4
	.type	symIndex,@object        # @symIndex
	.comm	symIndex,4,4
	.type	resultPtr,@object       # @resultPtr
	.comm	resultPtr,8,8

	.ident	"clang version 8.0.1 (https://github.com/llvm-mirror/clang.git 2e4c9c5fc864c2c432e4c262a67c42d824b265c6) (https://github.com/adamhumphriescs/TASE_LLVM_MIRROR.git dabda23bb422131c9fbd5aab29724697eafdf7d3)"
	.section	".note.GNU-stack","",@progbits
	.section	.rodata.tase_records,"",@progbits
                                        # Start of TASE Cartridge records
	.long	.LBB0_0_CartridgeHead
	.short	.LBB0_0_CartridgeBody-.LBB0_0_CartridgeHead
	.short	.LBB0_0_CartridgeEnd-.LBB0_0_CartridgeBody

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

	.long	.LBB1_6_CartridgeHead
	.short	.LBB1_6_CartridgeBody-.LBB1_6_CartridgeHead
	.short	.LBB1_6_CartridgeEnd-.LBB1_6_CartridgeBody

	.long	.LBB1_7_CartridgeHead
	.short	.LBB1_7_CartridgeBody-.LBB1_7_CartridgeHead
	.short	.LBB1_7_CartridgeEnd-.LBB1_7_CartridgeBody

	.long	.LBB1_8_CartridgeHead
	.short	.LBB1_8_CartridgeBody-.LBB1_8_CartridgeHead
	.short	.LBB1_8_CartridgeEnd-.LBB1_8_CartridgeBody

	.long	.LBB1_9_CartridgeHead
	.short	.LBB1_9_CartridgeBody-.LBB1_9_CartridgeHead
	.short	.LBB1_9_CartridgeEnd-.LBB1_9_CartridgeBody

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

	.long	.LBB4_5_CartridgeHead
	.short	.LBB4_5_CartridgeBody-.LBB4_5_CartridgeHead
	.short	.LBB4_5_CartridgeEnd-.LBB4_5_CartridgeBody

	.long	.LBB4_6_CartridgeHead
	.short	.LBB4_6_CartridgeBody-.LBB4_6_CartridgeHead
	.short	.LBB4_6_CartridgeEnd-.LBB4_6_CartridgeBody

	.long	.LBB4_7_CartridgeHead
	.short	.LBB4_7_CartridgeBody-.LBB4_7_CartridgeHead
	.short	.LBB4_7_CartridgeEnd-.LBB4_7_CartridgeBody

	.long	.LBB4_8_CartridgeHead
	.short	.LBB4_8_CartridgeBody-.LBB4_8_CartridgeHead
	.short	.LBB4_8_CartridgeEnd-.LBB4_8_CartridgeBody

	.long	.LBB4_9_CartridgeHead
	.short	.LBB4_9_CartridgeBody-.LBB4_9_CartridgeHead
	.short	.LBB4_9_CartridgeEnd-.LBB4_9_CartridgeBody

	.long	.LBB4_10_CartridgeHead
	.short	.LBB4_10_CartridgeBody-.LBB4_10_CartridgeHead
	.short	.LBB4_10_CartridgeEnd-.LBB4_10_CartridgeBody

	.long	.LBB4_11_CartridgeHead
	.short	.LBB4_11_CartridgeBody-.LBB4_11_CartridgeHead
	.short	.LBB4_11_CartridgeEnd-.LBB4_11_CartridgeBody

	.long	.LBB4_12_CartridgeHead
	.short	.LBB4_12_CartridgeBody-.LBB4_12_CartridgeHead
	.short	.LBB4_12_CartridgeEnd-.LBB4_12_CartridgeBody

	.long	.LBB4_13_CartridgeHead
	.short	.LBB4_13_CartridgeBody-.LBB4_13_CartridgeHead
	.short	.LBB4_13_CartridgeEnd-.LBB4_13_CartridgeBody

	.long	.LBB4_14_CartridgeHead
	.short	.LBB4_14_CartridgeBody-.LBB4_14_CartridgeHead
	.short	.LBB4_14_CartridgeEnd-.LBB4_14_CartridgeBody

	.long	.LBB4_15_CartridgeHead
	.short	.LBB4_15_CartridgeBody-.LBB4_15_CartridgeHead
	.short	.LBB4_15_CartridgeEnd-.LBB4_15_CartridgeBody

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

                                        # End of TASE Cartridge records
	.section	.rodata.tase_modeled_records,"",@progbits
	.section	.rodata.tase_live_flags_block_records,"",@progbits
                                        # Start of TASE list of blocks with live flags 
                                        # End of TASE live flags block records section
	.section	".note.GNU-stack","",@progbits
