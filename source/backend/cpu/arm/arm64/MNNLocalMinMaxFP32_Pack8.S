//
//  MNNLocalMinMaxFP32_Pack8.S
//
//  Created by MNN on 2023/10/31.
//  Copyright © 2018, Alibaba Group Holding Limited
//

#ifdef __aarch64__

#include "MNNAsmGlobal.h"
.text
.align 5

.macro Max4 d0, d1, d2, d3, z0, z1, z2, z3
    fmax \d0\().4s, \d0\().4s, \z0\().4s
    fmax \d1\().4s, \d1\().4s, \z1\().4s
    fmax \d2\().4s, \d2\().4s, \z2\().4s
    fmax \d3\().4s, \d3\().4s, \z3\().4s
.endm

.macro Min4 d0, d1, d2, d3, z0, z1, z2, z3
    fmin \d0\().4s, \d0\().4s, \z0\().4s
    fmin \d1\().4s, \d1\().4s, \z1\().4s
    fmin \d2\().4s, \d2\().4s, \z2\().4s
    fmin \d3\().4s, \d3\().4s, \z3\().4s
.endm

.macro ReduceMax s0, s1, s2, s3, s4, s5, s6, s7, z0
    fmaxp \s0\().4s, \s0\().4s, \s1\().4s // 0 0 0 0
    fmaxp \s2\().4s, \s2\().4s, \s3\().4s // 1 1 1 1
    fmaxp \s4\().4s, \s4\().4s, \s5\().4s // 2 2 2 2
    fmaxp \s6\().4s, \s6\().4s, \s7\().4s // 3 3 3 3
    fmaxp \s0\().4s, \s0\().4s, \s2\().4s // 0 0 1 1
    fmaxp \s4\().4s, \s4\().4s, \s6\().4s // 2 2 3 3
    fmaxp \z0\().4s, \s0\().4s, \s4\().4s // 0 1 2 3
.endm

.macro ReduceMin s0, s1, s2, s3, s4, s5, s6, s7, z0
    fminp \s0\().4s, \s0\().4s, \s1\().4s // 0 0 0 0
    fminp \s2\().4s, \s2\().4s, \s3\().4s // 1 1 1 1
    fminp \s4\().4s, \s4\().4s, \s5\().4s // 2 2 2 2
    fminp \s6\().4s, \s6\().4s, \s7\().4s // 3 3 3 3
    fminp \s0\().4s, \s0\().4s, \s2\().4s // 0 0 1 1
    fminp \s4\().4s, \s4\().4s, \s6\().4s // 2 2 3 3
    fminp \z0\().4s, \s0\().4s, \s4\().4s // 0 1 2 3
.endm

.macro L4Copy s0, s1, s2, s3, z0, z1, z2, z3
    mov \s0\().16b, \z0\().16b
    mov \s1\().16b, \z1\().16b
    mov \s2\().16b, \z2\().16b
    mov \s3\().16b, \z3\().16b
.endm

//void MNNLocalMinMaxFP32_Pack8(float* dstMin, float* dstMax, const float* source, size_t blockNum, size_t blockLU, size_t EP, size_t LP, size_t loadDstBuffer)
asm_function MNNLocalMinMaxFP32_Pack8

// x0: dstMin, x1:dstMax, x2:source, x3:blockNum, x4: blockLU, x5: EP, x6: LP=4, x7: loadDstBuffer
stp d14, d15, [sp, #(-16 * 4)]!
stp d12, d13, [sp, #(16 * 1)]
stp d10, d11, [sp, #(16 * 2)]
stp d8,  d9,  [sp, #(16 * 3)]

lsl x6, x5, #5 // src_step = batch * LP * sizeof(float32_t) = batch << 5
mul x13, x5, x4       // blockLU * EP * LP * sizeof(float)
lsl x13, x13, #5
mov x9, x5
mov x10, x4


Loop_BlockNum:
sub x3, x3, #1 // blocknum--
mov x5, x9     // EP
mov x12, x2    // block's source

TILE_4:
cmp x5, #4
blt TILE_1
mov x4, x10  // blockLU
mov x11, x2  // src
sub x8, x6, #64 // src_step

ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x11], #64
ld1 {v4.4s, v5.4s, v6.4s, v7.4s}, [x11], x8
L4Copy v8, v9, v10, v11, v0, v1, v2, v3
L4Copy v12, v13, v14, v15, v4, v5, v6, v7
subs x4, x4, #1
beq Tile4End

LoopSz_4:
ld1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x11], #64
ld1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x11], x8

Max4 v0, v1, v2, v3, v16, v17, v18, v19
Max4 v4, v5, v6, v7, v20, v21, v22, v23
Min4 v8, v9, v10, v11, v16, v17, v18, v19
Min4 v12, v13, v14, v15, v20, v21, v22, v23

subs x4, x4, #1
bne LoopSz_4

Tile4End:
ReduceMax v0, v1, v2, v3, v4, v5, v6, v7, v16
ReduceMin v8, v9, v10, v11,v12, v13, v14, v15, v18
cbz x7, TILE_4_Store
ld1 {v4.4s}, [x0] // dstMin
ld1 {v6.4s}, [x1] // dstMax
fmax v16.4s, v16.4s, v6.4s
fmin v18.4s, v18.4s, v4.4s

TILE_4_Store:
st1 {v16.4s}, [x1], #16
st1 {v18.4s}, [x0], #16
sub x5, x5, #4
add x2, x2, #128 // src += 4 * 8 * 4
b TILE_4


TILE_1:
cbz x5, Loop_Block_End

mov x4, x10  // src_depth_quad
mov x11, x2  // src

ld1 {v0.4s, v1.4s}, [x11], x6
mov v8.16b, v0.16b
mov v9.16b, v1.16b

subs x4, x4, #1
beq Tile1End

LoopSz_1:
ld1 {v16.4s, v17.4s}, [x11], x6

fmax v0.4s, v0.4s, v16.4s
fmax v1.4s, v1.4s, v17.4s
fmin v8.4s, v8.4s, v16.4s
fmin v9.4s, v9.4s, v17.4s

subs x4, x4, #1
bne LoopSz_1

Tile1End:
// reduce max/min
fmaxp v2.4s, v0.4s, v1.4s
fminp v3.4s, v8.4s, v9.4s
fmaxp v2.4s, v2.4s, v2.4s
fminp v3.4s, v3.4s, v3.4s
fmaxp v2.4s, v2.4s, v2.4s
fminp v3.4s, v3.4s, v3.4s
cbz x7, TILE_1_Store
ld1 {v10.s}[0], [x1]
ld1 {v11.s}[0], [x0]
fmax v2.2s, v2.2s, v10.2s
fmin v3.2s, v3.2s, v11.2s

TILE_1_Store:
st1 {v2.s}[0], [x1], #4
st1 {v3.s}[0], [x0], #4
subs x5, x5, #1
add x2, x2, #32 // src += 1 * 8(pack) * 4(sizeof(float32_t))
bne TILE_1

Loop_Block_End:
add x2, x12, x13
cbnz x3, Loop_BlockNum


End:
ldp d8,  d9,  [sp, #(16 * 3)]
ldp d10, d11, [sp, #(16 * 2)]
ldp d12, d13, [sp, #(16 * 1)]
ldp d14, d15, [sp], #(16 * 4)
ret

#endif
