.intel_syntax noprefix

.macro .exec_perm addr size
mov rax, 0xa  ##//mprotect
mov rdi, \addr
mov rsi, \size
mov rdx, 7
syscall
.endm

.macro .instr_op_imm_i32 ins_op_zero imm
mov rax, \ins_op_zero
mov rcx, \imm
shl rcx, 24
or rax, rcx
.endm

.macro .make_exec_function addr size stacksize ##//stacksize < 0x80000000
.exec_perm \addr \size
.instr_op_imm_i32 0xec8148 \stacksize  ##// sub rsp, 0
mov dword ptr [rdi],   0xe5894055      ##// push rbp; mov rbp, rsp
mov qword ptr [rdi+4], rax             ##// sub rsp, \stacksize
add rdi, 11
.endm

.macro .make_epilogue addr
xchg rdi, r15
mov rdi, \addr
mov byte ptr [rdi],   0xc9  ##//leave
mov byte ptr [rdi+1], 0xc3  ##//ret
xchg rdi, r15
.endm

.macro .nopsled addr size
xchg rdi, r15
xchg rsi, r14
mov rdi, \addr
mov rsi, \size
mov byte ptr [rdi], 0x90
inc rdi
cmp rdi, rsi
jne $-9
xchg rdi, r15
xchg rsi, r14
.endm

.macro .store_load_sc_arg
mov qword ptr [rbx], rax
add rbx, 7
.endm

.macro .make_syscall addr sc arg0 arg1 arg2 arg3 arg4 arg5 ##//arguments < 0x80000000
mov rbx, \addr
.instr_op_imm_i32 0xc0c748 \sc
.store_load_sc_arg
.instr_op_imm_i32 0xc7c748 \arg0
.store_load_sc_arg
.instr_op_imm_i32 0xc6c748 \arg1
.store_load_sc_arg
.instr_op_imm_i32 0xc2c748 \arg2
.store_load_sc_arg
.instr_op_imm_i32 0xc2c749 \arg3
.store_load_sc_arg
.instr_op_imm_i32 0xc0c749 \arg4
.store_load_sc_arg
.instr_op_imm_i32 0xc1c749 \arg5
.store_load_sc_arg
mov byte ptr [rbx], 0x0f
inc rbx
mov byte ptr [rbx], 0x05
inc rbx
.endm

##//example:
.section .text
.exec_perm 0x402000 0x100
.make_syscall 0x402000 60 0 0 0 0 0 0
jmp 0x402000
.section .data
beta:
.asciz "abcdefghijklmnopqrstuvwxyz"
