//
//  MNNDepthwiseConvFastKernel.S
//  MNN
//
//  Created by MNN on 2019/02/04.
//  Copyright © 2018, Alibaba Group Holding Limited
//

#ifdef __arm__
#ifndef __aarch64__

#include "MNNAsmGlobal.h"

.text
.align 5

asm_function MNNDepthwiseConvFastKernel
//void MNNDepthwiseConvFastKernel(float* dst, const float* src, const float* weight, size_t width, size_t src_w_setup,
//                                size_t fw, size_t fh, size_t dilateX_step, size_t dilateY_step, size_t height, size_t srcHStep, size_t dstHStep)


//Auto Load:
//r0:dst, r1:src, r2:weight, r3:width

push {r4-r8, r10, r11, lr}

//Load From Sp
//r4:src_w_setup, r5:fw, r6:fh, r7:dilate_x_step, r8:dilate_y_step, lr: height, r10:srcHStep, r11:dstHStep
ldr r4, [sp, #32]
ldr r5, [sp, #36]
ldr r6, [sp, #40]
ldr r7, [sp, #44]
ldr r8, [sp, #48]
ldr lr, [sp, #52]
ldr r10, [sp, #56]
ldr r11, [sp, #60]
ldr r12, [sp, #64] // bias
vld1.32 {q0}, [r12] // bias
ldr r12, [sp, #68]  // min,max
vld1.32 {d2[0]}, [r12]!
vld1.32 {d2[1]}, [r12]

vpush {q4-q7}
vmov.f32 q5, q0 // bias
vdup.f32 q4, d2[0] // min
vdup.f32 q6, d2[1] // max

mov r12, #4
mul r4, r12, r4
mul r7, r12, r7
mul r8, r12, r8
mul r10, r12, r10
mul r11, r12, r11

//dilate_y_step -> dilate_y_step - fw*dilate_x_step
mul r12, r5, r7
sub r8, r8, r12

LoopDY:
push {r0, r1, r3, r10, r11, lr}

L8:
cmp r3, #7
ble L4

L8Loop:
    vmov.f32 q8,  q5 // use bias to init
    vmov.f32 q9,  q5
    vmov.f32 q10, q5
    vmov.f32 q11, q5
    vmov.f32 q12, q5
    vmov.f32 q13, q5
    vmov.f32 q14, q5
    vmov.f32 q15, q5

    mov r12, r1
    mov r4, r2
    mov lr, r6
    L8LoopH:
        mov r10, r5
        L8LoopW:
            vld1.32 {q7}, [r2]!
            vld1.32 {q0, q1}, [r1]!
            vld1.32 {q2, q3}, [r1]!
            subs r10, r10, #1
            vmla.f32 q8, q0, q7
            vmla.f32 q9, q1, q7
            vmla.f32 q10, q2, q7
            vmla.f32 q11, q3, q7
            vld1.32 {q0, q1}, [r1]!
            vld1.32 {q2, q3}, [r1]
            vmla.f32 q12, q0, q7
            vmla.f32 q13, q1, q7
            vmla.f32 q14, q2, q7
            vmla.f32 q15, q3, q7
            sub r1, r1, #80

            bne L8LoopW
        L8LoopWEnd:
        subs lr, lr, #1
        add r1, r1, r8
        bne L8LoopH

    sub r3, r3, #8
    vmax.f32 q8, q8, q4
    vmax.f32 q9, q9, q4
    vmax.f32 q10, q10, q4
    vmax.f32 q11, q11, q4
    vmax.f32 q12, q12, q4
    vmax.f32 q13, q13, q4
    vmax.f32 q14, q14, q4
    vmax.f32 q15, q15, q4
    vmin.f32 q8, q8, q6
    vmin.f32 q9, q9, q6
    vmin.f32 q10, q10, q6
    vmin.f32 q11, q11, q6
    vmin.f32 q12, q12, q6
    vmin.f32 q13, q13, q6
    vmin.f32 q14, q14, q6
    vmin.f32 q15, q15, q6
    vst1.32 {q8, q9}, [r0]!
    mov r1, r12
    mov r2, r4
    vst1.32 {q10, q11}, [r0]!
    vst1.32 {q12, q13}, [r0]!
    vst1.32 {q14, q15}, [r0]!
    add r1, r1, #128
    cmp r3, #8
    bge L8Loop

L4:
cmp r3, #3
ble L1

L4Loop:
    vmov.f32 q8,  q5
    vmov.f32 q9,  q5
    vmov.f32 q10, q5
    vmov.f32 q11, q5

    mov r12, r1
    mov r4, r2
    mov lr, r6
    L4LoopH:
        mov r10, r5
        L4LoopW:
            vld1.32 {q12}, [r2]!
            vld1.32 {q0, q1}, [r1]!
            vld1.32 {q2, q3}, [r1]
            sub r1, r1, #16
            subs r10, r10, #1
            vmla.f32 q8, q12, q0
            vmla.f32 q9, q12, q1
            vmla.f32 q10, q12, q2
            vmla.f32 q11, q12, q3

            bne L4LoopW
        subs lr, lr, #1
        add r1, r1, r8
        bne L4LoopH

    vmax.f32 q8, q8, q4
    vmax.f32 q9, q9, q4
    vmax.f32 q10, q10, q4
    vmax.f32 q11, q11, q4
    vmin.f32 q8, q8, q6
    vmin.f32 q9, q9, q6
    vmin.f32 q10, q10, q6
    vmin.f32 q11, q11, q6
    sub r3, r3, #4
    vst1.32 {q8, q9}, [r0]!
    mov r1, r12
    mov r2, r4
    vst1.32 {q10, q11}, [r0]!
    add r1, r1, #64
    cmp r3, #4
    bge L4Loop

L1:
cmp r3, #0
beq End
L1Loop:
    vmov.f32 q0, q5
    mov lr, r6
    mov r11, r1
    mov r12, r2
    L1LoopH:
        mov r10, r5
        L1LoopW:
            vld1.32 {q1}, [r1]!
            vld1.32 {q2}, [r2]!
            vmla.f32 q0, q1, q2
            subs r10, r10, #1
            bne L1LoopW
        subs lr, lr, #1
        add r1, r1, r8
        bne L1LoopH

    vmax.f32 q0, q0, q4
    vmin.f32 q0, q0, q6
    subs r3, r3, #1
    vst1.32 {q0}, [r0]!
    mov r2, r12
    add r1, r11, #16
    bne L1Loop


End:

pop {r0, r1, r3, r10, r11, lr}
add r0, r0, r11
subs lr, lr, #1
add r1, r1, r10
bne LoopDY

vpop {q4-q7}
pop {r4-r8, r10, r11, pc}


#endif
#endif
