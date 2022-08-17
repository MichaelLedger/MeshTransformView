https://stackoverflow.com/questions/70817609/how-do-i-convert-an-opengl-glkview-to-a-mtlkit-metal-based-view

https://developer.apple.com/documentation/accelerate/simd_float3x3?language=objc

http://seanchense.github.io/2019/05/26/use-vdsp-simd-multiply-matrix/

https://juejin.cn/post/6844903623202177031

GLKVector2 -> simd_float2
GLKVector3 -> simd_float3

GLKVector2Make -> simd_make_float2
GLKVector3Make -> simd_make_float3

GLKVector3Multiply(GLKVector3, GLKVector3) -> simd_make_float3(simd_float3.x * simd_float3.x, simd_float3.y * simd_float3.y, simd_float3.z * simd_float3.z)
GLKVector3Subtract(GLKVector3, GLKVector3) -> simd_make_float3(simd_float3.x - simd_float3.x, simd_float3.y - simd_float3.y, simd_float3.z - simd_float3.z)
