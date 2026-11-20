.syntax unified
.arch armv7-a
.arm
.text
.balign 4
.global _start

.type _start, %function
_start:
    andsmi r8, r0, r0, lsr r3
    dsb     sy
    mov     r0, #0
    mcr     p15, 0, r0, c8, c7, 0   @ TLBIALL
    dsb     sy
    isb     sy

    mrc     p15, 0, r0, c1, c0, 0   @ Read SCTLR
    orr     r0, r0, #1               @ Set SCTLR.M
    mcr     p15, 0, r0, c1, c0, 0
    isb     sy

    bl      sep_send_ab
.Ldone:
    b       .Ldone
.size _start, . - _start

.type sep_send_ab, %function
sep_send_ab:
    movw    r2, #0x0ba0
    movt    r2, #0x3da0              @ Mailbox VA 0x3DA00BA0

.Lcheck_full:
    ldr     r3, [r2]
    tst     r3, #0x10000             @ FULL
    beq     .Lsend
    wfe
    b       .Lcheck_full

.Lsend:
    movw    r0, #0x00ff
    movt    r0, #0x00ab              @ r0 = 0x00AB00FF
    mov     r1, #0
    str     r0, [r2, #0x10]          @ Low 32 bits
    str     r1, [r2, #0x14]          @ High 32 bits
    bx      lr
.size sep_send_ab, . - sep_send_ab
