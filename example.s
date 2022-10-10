.intel_syntax noprefix
.include "macros.s"
.section .text
.exec_perm 0x402000 0x100
.make_syscall 0x402000 60 0 0 0 0 0 0
jmp 0x402000
.section .data
beta:
.asciz "abcdefghijklmnopqrstuvwxyz"
