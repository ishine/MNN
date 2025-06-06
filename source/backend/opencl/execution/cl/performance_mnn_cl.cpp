#include "opencl_source_map.hpp" 
namespace MNN { 
const char* performance = 
"#define MAD_V4(x, y) "" x = mad(y, x, y); "" y = mad(x, y, x); "" x = mad(y, x, y); "" y=mad(x,y,x);\n"
"#define MAD_V16(x, y) "" MAD_V4(x, y); "" MAD_V4(x, y); "" MAD_V4(x, y); "" MAD_V4(x,y);\n"
"#define MAD_V64(x, y) "" MAD_V16(x, y); "" MAD_V16(x, y); "" MAD_V16(x, y); "" MAD_V16(x,y);\n"
"#define MAD_V128(x, y) "" MAD_V64(x, y); "" MAD_V64(x, y); "" MAD_V64(x, y); "" MAD_V64(x,y);\n"
"#define MAD_V256(x, y) "" MAD_V128(x, y); "" MAD_V128(x, y); "" MAD_V128(x, y); "" MAD_V128(x,y);\n"
"#ifdef MNN_SUPPORT_FP16\n"
"#pragma OPENCL EXTENSION cl_khr_fp16 : enable\n"
"#endif\n"
"__kernel void float_precision(__global float* output_ptr,float mul_value) {\n"
" float mul_x=mul_value;\n"
" float mul_y=(float)get_local_id(0);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" output_ptr[get_global_id(0)]=mul_y;\n"
"}\n"
"__kernel void half4_precision(__global half* output_ptr,float mul_value) {\n"
" half mul=(half)mul_value;\n"
" half4 mul_x=(half4)(mul);\n"
" half4 mul_y=(half4)get_local_id(0);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" MAD_V256(mul_x,mul_y);\n"
" output_ptr[get_global_id(0)]=(mul_y.S0)+(mul_y.S1)+(mul_y.S2)+(mul_y.S3);\n"
"}\n"
;
}
