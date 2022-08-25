# Mesh Transforms
[Mesh Transforms](https://ciechanow.ski/mesh-transforms/)

[BCMeshTransformView](https://github.com/Ciechan/BCMeshTransformView)

#  How to convert OpenGL to Metal

[Metal](https://developer.apple.com/metal/)

[Metal feature set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf)

[MetalKit Namespace](https://docs.microsoft.com/zh-cn/dotnet/api/metalkit?view=xamarin-ios-sdk-12)

[OpenGL Transformation](http://www.songho.ca/opengl/gl_transform.html)

[Metal Best Practices Guide - Buffer Bindings](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/BufferBindings.html)

[Metal by Tutorials](https://www.raywenderlich.com/books/metal-by-tutorials/v3.0/chapters/4-the-vertex-function)

[WWDC- Metal](https://developer.apple.com/videos/wwdc2014/?q=metal)

[Convert](https://stackoverflow.com/questions/70817609/how-do-i-convert-an-opengl-glkview-to-a-mtlkit-metal-based-view)

[Moving from OpenGL to Metal](https://www.raywenderlich.com/9211-moving-from-opengl-to-metal)

[Working with Metal—Overview](https://devstreaming-cdn.apple.com/videos/wwdc/2014/603xx33n8igr5n1/603/603_working_with_metal_overview.pdf?dl=1)

[MetalDeferredLightingTutorial](https://github.com/sevanspowell/MetalDeferredLightingTutorial)

[MetalDeferredLighting](https://github.com/Necktwi/MetalDeferredLighting)

[From OpenGL to Metal – The Projection Matrix Problem](https://metashapes.com/blog/opengl-metal-projection-matrix-problem/)

[simd_float3x3](https://developer.apple.com/documentation/accelerate/simd_float3x3?language=objc)

[use-vdsp-simd-multiply-matrix](http://seanchense.github.io/2019/05/26/use-vdsp-simd-multiply-matrix/)

[ARKit9 - 3D/AR simd](https://juejin.cn/post/6844903623202177031)

[Switching to MetalKit](https://www.raywenderlich.com/976-ios-metal-tutorial-with-swift-part-5-switching-to-metalkit)

[iOS - 将 UIImage 转为 OpenGL texture](https://www.jianshu.com/p/091228374f44)

[MTKTextureLoader saturates image](https://stackoverflow.com/questions/49564889/mtktextureloader-saturates-image)

[Introduction to Metal Compute: Textures & Dispatching](https://eugenebokhan.io/introduction-to-metal-compute-part-four)

[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

/*
    Personal access tokens can only be used for HTTPS Git operations. If your repository uses an SSH remote URL, you will need to switch the remote from SSH to HTTPS.
    Github -> Settings -> Developer settings -> Personal access tokens
*/
[Creating a personal access token](https://docs.github.com/cn/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

[Swift - flatMap(_:)](https://developer.apple.com/documentation/swift/sequence/flatmap(_:)-jo2y)

[OC - flatMap](https://betterprogramming.pub/higher-order-functions-in-objective-c-850f6c90de30)

[Sample Code - Creating and Sampling Textures](https://developer.apple.com/documentation/metal/textures/creating_and_sampling_textures?language=objc)

[issues in Apple Metal API "setVertexBuffer:offset:atIndex:"](https://stackoverflow.com/questions/58767565/issues-in-apple-metal-api-setvertexbufferoffsetatindex)

[Basic Example for Metal](https://radeon-pro.github.io/RadeonProRenderDocs/en/rr/example_metal.html)

[AMD Radeon™️ ProRender SDK](https://github.com/GPUOpen-LibrariesAndSDKs/RadeonProRenderSDK)

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
