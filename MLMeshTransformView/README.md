#  How to convert OpenGL to Metal

[Convert](https://stackoverflow.com/questions/70817609/how-do-i-convert-an-opengl-glkview-to-a-mtlkit-metal-based-view)

[simd_float3x3](https://developer.apple.com/documentation/accelerate/simd_float3x3?language=objc)

[use-vdsp-simd-multiply-matrix](http://seanchense.github.io/2019/05/26/use-vdsp-simd-multiply-matrix/)

[ARKit9 - 3D/AR simd](https://juejin.cn/post/6844903623202177031)

GLKVector2 -> simd_float2
GLKVector3 -> simd_float3

GLKVector2Make -> simd_make_float2
GLKVector3Make -> simd_make_float3

 **gltypes.h -> mtktypes.h**
GLsizei -> MTsizei
...

 **GLKVector3.h -> MTKVector3.h**
GLKVector3CrossProduct(GLKVector3 vectorLeft, GLKVector3 vectorRight) -> simd_float3_cross_product(simd_float3 vectorLeft, simd_float3 vectorRight)
...
