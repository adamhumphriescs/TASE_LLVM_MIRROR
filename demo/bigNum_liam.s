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
	movl	$.L.str, %eax
	xorl	%ecx, %ecx
	movb	%cl, %dl
	movq	%rdi, -8(%rsp)          # 8-byte Spill
	movq	%rax, %rdi
	movq	-8(%rsp), %rsi          # 8-byte Reload
	movb	%dl, %al
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
	xorl	%eax, %eax
	movl	%eax, %ecx
	movl	numEntries, %eax
	cmpl	$0, %eax
	movq	%rdi, -8(%rsp)          # 8-byte Spill
	movq	%rcx, -16(%rsp)         # 8-byte Spill
	jg	.LBB1_3
.LBB1_0_CartridgeEnd:
.LBB1_1:                                # %for.cond.cleanup
.LBB1_1_CartridgeHead:
	leaq	.LBB1_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_1_CartridgeBody:
	movq	(%rsp), %r14
.LBB1_1_CartridgeEnd:
# %bb.2:                                # %for.cond.cleanup
.LBB1_2_CartridgeHead:
	leaq	.LBB1_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_2_CartridgeBody:
	retq
.LBB1_2_CartridgeEnd:
.LBB1_3:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB1_3_CartridgeHead:
	leaq	.LBB1_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_3_CartridgeBody:
	movq	-16(%rsp), %rax         # 8-byte Reload
	movb	$1, %cl
	movl	testType(%rip), %edx
	testl	%edx, %edx
	movq	%rax, -24(%rsp)         # 8-byte Spill
	movl	%edx, -28(%rsp)         # 4-byte Spill
	movb	%cl, -29(%rsp)          # 1-byte Spill
	je	.LBB1_6
.LBB1_3_CartridgeEnd:
	jmp	.LBB1_4
.LBB1_4:                                # %for.body
                                        #   in Loop: Header=BB1_3 Depth=1
.LBB1_4_CartridgeHead:
	leaq	.LBB1_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_4_CartridgeBody:
	movl	-28(%rsp), %eax         # 4-byte Reload
	subl	$1, %eax
	movl	%eax, -36(%rsp)         # 4-byte Spill
	jne	.LBB1_7
.LBB1_4_CartridgeEnd:
	jmp	.LBB1_5
.LBB1_5:                                # %if.then3
                                        #   in Loop: Header=BB1_3 Depth=1
.LBB1_5_CartridgeHead:
	leaq	.LBB1_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_5_CartridgeBody:
	movb	garbageCtr, %al
	movb	%al, -37(%rsp)          # 1-byte Spill
	movb	-37(%rsp), %cl          # 1-byte Reload
	mulb	%cl
	addb	$7, %al
	movb	%al, garbageCtr
	movb	%al, -29(%rsp)          # 1-byte Spill
.LBB1_5_CartridgeEnd:
.LBB1_6:                                # %for.inc.sink.split
                                        #   in Loop: Header=BB1_3 Depth=1
.LBB1_6_CartridgeHead:
	leaq	.LBB1_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_6_CartridgeBody:
	movb	-29(%rsp), %al          # 1-byte Reload
	movq	-8(%rsp), %rcx          # 8-byte Reload
	movq	-24(%rsp), %rdx         # 8-byte Reload
	movb	%al, (%rcx,%rdx)
.LBB1_6_CartridgeEnd:
.LBB1_7:                                # %for.inc
                                        #   in Loop: Header=BB1_3 Depth=1
.LBB1_7_CartridgeHead:
	leaq	.LBB1_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB1_7_CartridgeBody:
	movq	-24(%rsp), %rax         # 8-byte Reload
	addq	$1, %rax
	movl	numEntries, %ecx
	movslq	%ecx, %rdx
	cmpq	%rdx, %rax
	movq	%rax, -16(%rsp)         # 8-byte Spill
	jl	.LBB1_3
.LBB1_7_CartridgeEnd:
	jmp	.LBB1_1
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
	xorl	%eax, %eax
	movl	%eax, %ecx
	movl	numEntries, %eax
	cmpl	$0, %eax
	movq	%rdi, -8(%rsp)          # 8-byte Spill
	movq	%rcx, -16(%rsp)         # 8-byte Spill
	jg	.LBB2_3
.LBB2_0_CartridgeEnd:
.LBB2_1:                                # %for.cond.cleanup
.LBB2_1_CartridgeHead:
	leaq	.LBB2_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_1_CartridgeBody:
	movq	(%rsp), %r14
.LBB2_1_CartridgeEnd:
# %bb.2:                                # %for.cond.cleanup
.LBB2_2_CartridgeHead:
	leaq	.LBB2_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_2_CartridgeBody:
	retq
.LBB2_2_CartridgeEnd:
.LBB2_3:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB2_3_CartridgeHead:
	leaq	.LBB2_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB2_3_CartridgeBody:
	movq	-16(%rsp), %rax         # 8-byte Reload
	movq	-8(%rsp), %rcx          # 8-byte Reload
	movb	$-1, (%rcx,%rax)
	addq	$1, %rax
	movl	numEntries, %edx
	movslq	%edx, %rsi
	cmpq	%rsi, %rax
	movq	%rax, -16(%rsp)         # 8-byte Spill
	jl	.LBB2_3
.LBB2_3_CartridgeEnd:
	jmp	.LBB2_1
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
	xorl	%eax, %eax
	movl	%eax, %ecx
	movl	numEntries, %eax
	cmpl	$0, %eax
	movq	%rdi, -8(%rsp)          # 8-byte Spill
	movq	%rcx, -16(%rsp)         # 8-byte Spill
	jg	.LBB3_3
.LBB3_0_CartridgeEnd:
.LBB3_1:                                # %for.cond.cleanup
.LBB3_1_CartridgeHead:
	leaq	.LBB3_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_1_CartridgeBody:
	movq	(%rsp), %r14
.LBB3_1_CartridgeEnd:
# %bb.2:                                # %for.cond.cleanup
.LBB3_2_CartridgeHead:
	leaq	.LBB3_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_2_CartridgeBody:
	retq
.LBB3_2_CartridgeEnd:
.LBB3_3:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB3_3_CartridgeHead:
	leaq	.LBB3_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB3_3_CartridgeBody:
	movq	-16(%rsp), %rax         # 8-byte Reload
	movq	-8(%rsp), %rcx          # 8-byte Reload
	movb	$0, (%rcx,%rax)
	addq	$1, %rax
	movl	numEntries, %edx
	movslq	%edx, %rsi
	cmpq	%rsi, %rax
	movq	%rax, -16(%rsp)         # 8-byte Spill
	jl	.LBB3_3
.LBB3_3_CartridgeEnd:
	jmp	.LBB3_1
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
	subq	$40, %rsp
	.cfi_def_cfa_offset 48
	movl	numEntries, %edi
	callq	malloc_tase
.LBB4_0_CartridgeEnd:
# %bb.1:                                # %entry
.LBB4_1_CartridgeHead:
	leaq	.LBB4_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_1_CartridgeBody:
	movl	numEntries, %edi
	movq	%rax, 32(%rsp)          # 8-byte Spill
	callq	malloc_tase
.LBB4_1_CartridgeEnd:
# %bb.2:                                # %entry
.LBB4_2_CartridgeHead:
	leaq	.LBB4_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_2_CartridgeBody:
	movl	numEntries, %edi
	addl	$1, %edi
	movq	%rax, 24(%rsp)          # 8-byte Spill
	callq	malloc_tase
.LBB4_2_CartridgeEnd:
# %bb.3:                                # %entry
.LBB4_3_CartridgeHead:
	leaq	.LBB4_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_3_CartridgeBody:
	movq	32(%rsp), %rdi          # 8-byte Reload
	movq	%rax, 16(%rsp)          # 8-byte Spill
	callq	initializeNums
.LBB4_3_CartridgeEnd:
# %bb.4:                                # %entry
.LBB4_4_CartridgeHead:
	leaq	.LBB4_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_4_CartridgeBody:
	movq	24(%rsp), %rdi          # 8-byte Reload
	callq	initializeNums
.LBB4_4_CartridgeEnd:
# %bb.5:                                # %entry
.LBB4_5_CartridgeHead:
	leaq	.LBB4_5_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_5_CartridgeBody:
	movq	32(%rsp), %rdi          # 8-byte Reload
	callq	initializeAllZeros
.LBB4_5_CartridgeEnd:
# %bb.6:                                # %entry
.LBB4_6_CartridgeHead:
	leaq	.LBB4_6_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_6_CartridgeBody:
	movq	24(%rsp), %rdi          # 8-byte Reload
	callq	initializeAllOnes
.LBB4_6_CartridgeEnd:
# %bb.7:                                # %entry
.LBB4_7_CartridgeHead:
	leaq	.LBB4_7_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_7_CartridgeBody:
	movl	symIndex, %ecx
	cmpl	$-1, %ecx
	setg	%dl
	movl	numEntries, %esi
	cmpl	%esi, %ecx
	setl	%r8b
	andb	%r8b, %dl
	testb	$1, %dl
	movl	%ecx, 12(%rsp)          # 4-byte Spill
	jne	.LBB4_8
.LBB4_7_CartridgeEnd:
	jmp	.LBB4_9
.LBB4_8:                                # %if.then
.LBB4_8_CartridgeHead:
	leaq	.LBB4_8_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_8_CartridgeBody:
	movl	12(%rsp), %eax          # 4-byte Reload
	movslq	%eax, %rcx
	movq	32(%rsp), %rdx          # 8-byte Reload
	addq	%rcx, %rdx
	movq	%rdx, %rdi              # Instruction is Tainted 
	pinsrq	$0, -8(%rsp), %xmm15
	callq	make_byte_symbolic      # Instruction is Tainted 
.LBB4_8_CartridgeEnd:
.LBB4_9:                                # %if.end
.LBB4_9_CartridgeHead:
	leaq	.LBB4_9_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_9_CartridgeBody:
	xorl	%eax, %eax
	movl	repetitions, %ecx
	cmpl	$0, %ecx
	movl	%eax, 8(%rsp)           # 4-byte Spill
	jg	.LBB4_12
.LBB4_9_CartridgeEnd:
.LBB4_10:                               # %for.cond.cleanup
.LBB4_10_CartridgeHead:
	leaq	.LBB4_10_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_10_CartridgeBody:
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	movq	(%rsp), %r14
.LBB4_10_CartridgeEnd:
# %bb.11:                               # %for.cond.cleanup
.LBB4_11_CartridgeHead:
	leaq	.LBB4_11_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_11_CartridgeBody:
	retq
.LBB4_11_CartridgeEnd:
.LBB4_12:                               # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB4_12_CartridgeHead:
	leaq	.LBB4_12_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_12_CartridgeBody:
	.cfi_def_cfa_offset 48
	movl	8(%rsp), %eax           # 4-byte Reload
	movq	32(%rsp), %rdi          # 8-byte Reload
	movq	24(%rsp), %rsi          # 8-byte Reload
	movq	16(%rsp), %rdx          # 8-byte Reload
	movl	%eax, 4(%rsp)           # 4-byte Spill
	pinsrq	$0, -8(%rsp), %xmm15
	callq	runTest                 # Instruction is Tainted 
.LBB4_12_CartridgeEnd:
# %bb.13:                               # %for.body
                                        #   in Loop: Header=BB4_12 Depth=1
.LBB4_13_CartridgeHead:
	leaq	.LBB4_13_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB4_13_CartridgeBody:
	movl	4(%rsp), %eax           # 4-byte Reload
	addl	$1, %eax
	movl	repetitions, %ecx
	cmpl	%ecx, %eax
	movl	%eax, 8(%rsp)           # 4-byte Spill
	jl	.LBB4_12
.LBB4_13_CartridgeEnd:
	jmp	.LBB4_10
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
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	xorl	%eax, %eax
	movl	%eax, %ecx
	xorl	%eax, %eax
	movw	%ax, %r8w
	xorl	%eax, %eax
	movb	%al, %r9b
	movq	%rdx, resultPtr
	movl	numEntries, %eax
	cmpl	$0, %eax
	movq	%rdi, -8(%rsp)          # 8-byte Spill
	movq	%rsi, -16(%rsp)         # 8-byte Spill
	movq	%rdx, -24(%rsp)         # 8-byte Spill
	movb	%r9b, -25(%rsp)         # 1-byte Spill
	movl	%eax, -32(%rsp)         # 4-byte Spill
	movq	%rcx, -40(%rsp)         # 8-byte Spill
	movw	%r8w, -42(%rsp)         # 2-byte Spill
	jg	.LBB5_4
.LBB5_0_CartridgeEnd:
	jmp	.LBB5_2
.LBB5_1:                                # %for.cond.cleanup.loopexit
.LBB5_1_CartridgeHead:
	leaq	.LBB5_1_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_1_CartridgeBody:
	movw	-44(%rsp), %ax          # 2-byte Reload
	movb	%al, %cl
	movl	-48(%rsp), %edx         # 4-byte Reload
	movb	%cl, -25(%rsp)          # 1-byte Spill
	movl	%edx, -32(%rsp)         # 4-byte Spill
.LBB5_1_CartridgeEnd:
.LBB5_2:                                # %for.cond.cleanup
.LBB5_2_CartridgeHead:
	leaq	.LBB5_2_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_2_CartridgeBody:
	movl	-32(%rsp), %eax         # 4-byte Reload
	movb	-25(%rsp), %cl          # 1-byte Reload
	movslq	%eax, %rdx
	movq	-24(%rsp), %rsi         # 8-byte Reload
	leaq	(%rsi,%rdx), %r14
	shrq	%r14
	pinsrw	$0, (%r14,%r14), %xmm15
	movb	%cl, (%rsi,%rdx)        # Instruction is Tainted 
	popq	%rbx
	.cfi_def_cfa_offset 8
	movq	(%rsp), %r14
.LBB5_2_CartridgeEnd:
# %bb.3:                                # %for.cond.cleanup
.LBB5_3_CartridgeHead:
	leaq	.LBB5_3_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_3_CartridgeBody:
	retq
.LBB5_3_CartridgeEnd:
.LBB5_4:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
.LBB5_4_CartridgeHead:
	leaq	.LBB5_4_CartridgeBody(%rip), %r15
	jmp	sb_reopen
.LBB5_4_CartridgeBody:
	.cfi_def_cfa_offset 16
	movw	-42(%rsp), %ax          # 2-byte Reload
	movq	-40(%rsp), %rcx         # 8-byte Reload
	movq	-8(%rsp), %rdx          # 8-byte Reload
	leaq	(%rdx,%rcx), %r14
	movl	$1, %r15d
	shrxq	%r15, %r14, %r14
	pinsrw	$0, (%r14,%r14), %xmm15
	movb	(%rdx,%rcx), %sil       # Instruction is Tainted 
	movzbl	%sil, %edi              # Instruction is Tainted 
	movw	%di, %r8w
	movq	-16(%rsp), %r9          # 8-byte Reload
	movb	(%r9,%rcx), %sil
	movzbl	%sil, %edi
	movw	%di, %r10w
	addw	%r8w, %ax
	addw	%r10w, %ax
	movw	%ax, %r8w
	shrw	$8, %r8w
	movb	%al, %sil
	movq	-24(%rsp), %r11         # 8-byte Reload
	leaq	(%r11,%rcx), %r14
	shrq	%r14
	pinsrw	$1, (%r14,%r14), %xmm15
	movb	%sil, (%r11,%rcx)       # Instruction is Tainted 
	addq	$1, %rcx
	movl	numEntries, %edi
	movslq	%edi, %rbx
	cmpq	%rbx, %rcx
	movw	%r8w, %ax
	movw	%ax, -42(%rsp)          # 2-byte Spill
	movq	%rcx, -40(%rsp)         # 8-byte Spill
	movw	%r8w, -44(%rsp)         # 2-byte Spill
	movl	%edi, -48(%rsp)         # 4-byte Spill
	jl	.LBB5_4
.LBB5_4_CartridgeEnd:
	jmp	.LBB5_1
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

	.ident	"clang version 8.0.1 (https://github.com/llvm-mirror/clang.git 2e4c9c5fc864c2c432e4c262a67c42d824b265c6) (https://github.com/adamhumphriescs/TASE_LLVM_MIRROR.git 98f7954ecbac2ab616d41a2d82d78876f763bd27)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
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

                                        # End of TASE Cartridge records
	.section	.rodata.tase_modeled_records,"",@progbits
	.section	.rodata.tase_live_flags_block_records,"",@progbits
                                        # Start of TASE list of blocks with live flags 
                                        # End of TASE live flags block records section
	.section	".note.GNU-stack","",@progbits
