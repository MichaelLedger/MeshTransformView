//
//  MLMeshPyramidRenderer.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/30.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import "MLMeshPyramidRenderer.h"
#import "MLShaderTypes.h"
#import <GLKit/GLKit.h>
/*
 On iOS, GLKit requires an OpenGL ES 2.0 context. In macOS, GLKit requires an OpenGL context that supports the OpenGL 3.2 Core Profile.
*/

@interface MLMeshPyramidRenderer ()

@property (nonatomic, strong) MTKView *mtkView;// 渲染视图
@property (nonatomic, assign) vector_uint2 viewportSize;// 视口
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;// 渲染管道
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;// 命令队列
//@property (nonatomic, strong) id<MTLTexture> texture;// 纹理
@property (nonatomic, strong) id<MTLBuffer> vertices;// 顶点缓存区
@property (nonatomic, strong) id<MTLBuffer> indexs;// 索引缓存区
@property (nonatomic, assign) NSUInteger indexCount;// 索引个数

@end

@implementation MLMeshPyramidRenderer

{
    id<MTLDevice> _device;// 用来渲染的设备(又名GPU)
    
    // 渲染管道有顶点着色器和片元着色器，存储在shader.metal文件中
    id<MTLRenderPipelineState> _pipelineState;

    // 从命令缓存区获取命令队列
    id<MTLCommandQueue> _commandQueue;

    // 当前视图大小，在渲染通道时会使用这个视图
    vector_uint2 _viewportSize;
    
    // 顶点个数
    NSInteger _numVertices;
    
    // 顶点缓存区
    id<MTLBuffer> _vertexBuffer;
}

// 初始化
- (instancetype)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _mtkView = mtkView;
        // 1.初始GPU设备
        _device = mtkView.device;
        // 2.加载Metal文件(设置管道)
        [self loadMetal:mtkView];
        // 3.设置顶点数据
        [self setupVertex];
        // 4.设置纹理
        [self setupTexture];
    }
    return self;
}

// 加载Metal文件
- (void)loadMetal:(MTKView *)mtkView
{
    // 1.设置绘制纹理的像素格式
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    
    // 2.从项目中加载所有的.metal着色器文件
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    // 从库中加载顶点函数
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    // 从库中加载片元函数
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
    
    // 3.配置用于创建管道状态的管道
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    // 管道名称
    pipelineStateDescriptor.label = @"Simple Pipeline";
    // 可编程函数，用于处理渲染过程中的各个顶点
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    // 可编程函数，用于处理渲染过程总的各个片段/片元
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    // 设置管道中存储颜色数据的组件格式
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    
    // 4.同步创建并返回渲染管线对象
    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                             error:&error];
    // 判断是否创建成功
    if (!_pipelineState)
    {
        NSLog(@"创建渲染管线对象失败，错误信息为：%@", error);
    }
    
    // 5.获取顶点数据
//    NSData *vertexData = [MLMeshLargeDataRenderer generateVertexData];
    
    // 6.创建一个顶点缓冲区，可以由GPU来读取
//    _vertexBuffer = [_device newBufferWithLength:vertexData.length
//                                         options:MTLResourceStorageModeShared];
//
    // 7.复制顶点数据到顶点缓冲区，通过缓存区的内容属性访问指针
    // contents:目的地 bytes:源内容 length:长度
//    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    
    // 8.计算顶点个数 = 顶点数据长度 / 单个顶点大小
//    _numVertices = vertexData.length / sizeof(Vertex);
    
    // 9.创建命令队列
    _commandQueue = [_device newCommandQueue];
}

- (void)setupVertex
{
    // 1.金字塔的顶点坐标、顶点颜色、纹理坐标数据
    static const PyramidVertex quadVertices[] =
    {  // 顶点坐标                          顶点颜色                    纹理坐标
        {{-0.5f, 0.5f, 0.0f, 1.0f},      {0.0f, 0.0f, 0.5f},       {0.0f, 1.0f}},//左上
        {{0.5f, 0.5f, 0.0f, 1.0f},       {0.0f, 0.5f, 0.0f},       {1.0f, 1.0f}},//右上
        {{-0.5f, -0.5f, 0.0f, 1.0f},     {0.5f, 0.0f, 1.0f},       {0.0f, 0.0f}},//左下
        {{0.5f, -0.5f, 0.0f, 1.0f},      {0.0f, 0.0f, 0.5f},       {1.0f, 0.0f}},//右下
        {{0.0f, 0.0f, 1.0f, 1.0f},       {1.0f, 1.0f, 1.0f},       {0.5f, 0.5f}},//顶点
    };
    
    // 2.创建顶点数组缓存区
    self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                     length:sizeof(quadVertices)
                                            options:MTLResourceStorageModeShared];
   
    // 3.索引数组
    static int indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    // 4.创建索引数组缓存区
    self.indexs = [self.mtkView.device newBufferWithBytes:indices
                                                   length:sizeof(indices)
                                            options:MTLResourceStorageModeShared];
    
    // 5.计算索引个数
    self.indexCount = sizeof(indices) / sizeof(int);
}

- (void)setupTexture
{
    // 1.获取图片
    UIImage *image = [UIImage imageNamed:@"strawberry.jpeg"];
    
    // 2.创建纹理描述符
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    // 表示每个像素有蓝色、绿色、红色和alpha通道
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    // 设置纹理的像素尺寸
    textureDescriptor.width = image.size.width;
    textureDescriptor.height = image.size.height;
    
    // 3.使用描述符从设备中创建纹理
    _texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
    
    // 4.创建MTLRegion结构体用来设置纹理填充的范围
    MTLRegion region = {{ 0, 0, 0 }, {image.size.width, image.size.height, 1}};
    
    // 5.获取图片数据
    Byte *imageBytes = [self loadImage:image];
    
    // 6.UIImage的数据需要转成二进制才能上传，且不用jpg、png的NSData
    if (imageBytes)
    {
        [_texture replaceRegion:region
                    mipmapLevel:0
                      withBytes:imageBytes
                    bytesPerRow:4 * image.size.width];
        free(imageBytes);
        imageBytes = NULL;
    }
}

// 从UIImage中读取Byte数据返回
- (Byte *)loadImage:(UIImage *)image
{
    // 1.获取图片的CGImageRef
    CGImageRef spriteImage = image.CGImage;
    
    // 2.读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    // 3.计算图片大小.rgba共4个byte
    Byte * spriteData = (Byte *) calloc(width * height * 4, sizeof(Byte));
    
    // 4.创建画布
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 5.在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    // 6.图片翻转过来
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    // 7.释放spriteContext
    CGContextRelease(spriteContext);
    
    return spriteData;
}

#pragma mark - MTKViewDelegate

// 每当视图改变方向或调整大小时调用
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // 保存可绘制的大小。当我们绘制时将把这些值传递给顶点着色器
    self.viewportSize = (vector_uint2){size.width, size.height};
}

// 每当视图需要渲染帧时调用
- (void)drawInMTKView:(nonnull MTKView *)view
{
    // 1.为当前渲染的每个渲染传递创建一个新的命令缓存区
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    // 2.获取视图的渲染描述符
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    // 判断是否获取成功
    if(renderPassDescriptor != nil)
    {
        // 3.通过渲染描述符修改背景颜色
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.6, 0.2, 0.5, 1.0f);

        // 4.设置颜色附着点加载方式为写入指定附件中的每个像素
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        
        // 5.根据渲染描述信息创建渲染编码器
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        // 6.设置视口
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }];
        
        // 7.设置渲染管道
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        // 8.设置投影矩阵/渲染矩阵
        [self setupMatrixWithEncoder:renderEncoder];
        
        // 9.将顶点数据传递到Metal文件的顶点函数
        [renderEncoder setVertexBuffer:self.vertices
                                offset:0
                               atIndex:PyramidVertexInputIndexVertices];
        // 10.设置正背面剔除
        // 设置逆时钟三角形为正面，其为默认值所以可省略此步骤
        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        // 设置为背面剔除
        [renderEncoder setCullMode:MTLCullModeBack];
        
        // （补）给片元着色器传递纹理
        [renderEncoder setFragmentTexture:self.texture atIndex:PyramidFragmentInputIndexTexture];
        
        // 11.开始绘制(索引绘图)
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                  indexCount:self.indexCount
                                   indexType:MTLIndexTypeUInt32
                                 indexBuffer:self.indexs
                           indexBufferOffset:0];
        
        // 结束编码
        [renderEncoder endEncoding];
        
        // 展示视图
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    // 完成渲染并将命令缓冲区推送到GPU
    [commandBuffer commit];
}

#pragma mark - Matrix Encoder
// 设置投影矩阵/模型视图矩阵
- (void)setupMatrixWithEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    CGSize size = self.mtkView.bounds.size;
    float aspect = fabs(size.width / size.height);// 纵横比
    static float x = 0.0, y = 0.0, z = M_PI;// x=0,y=0,z=180
    
    //test
    x = arc4random_uniform(100) / 100.0;
    y = arc4random_uniform(100) / 100.0;
    z = M_PI_2;
    
    // 1.投影矩阵
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f);
    
    // 2.模型视图矩阵
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);

    // 3.判断X/Y/Z的开关状态，修改旋转的角度
//    if (self.rotationX.on)
//    {
//        x += self.slider.value;
//    }
//    if (self.rotationY.on)
//    {
//        y += self.slider.value;
//    }
//    if (self.rotationZ.on)
//    {
//        z += self.slider.value;
//    }
    x = self.rotationX;
    y = self.rotationY;
    z = self.rotationZ;
    
    // 4.将模型视图矩阵围绕(x,y,z)轴渲染相应的角度
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, x, 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, y, 0, 1, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, z, 0, 0, 1);
    
    // 5.将GLKit Matrix 转化为 MetalKit Matrix
    matrix_float4x4 pm = [self getMetalMatrixFromGLKMatrix:projectionMatrix];
    matrix_float4x4 mm = [self getMetalMatrixFromGLKMatrix:modelViewMatrix];
    
    // 6.将投影矩阵和模型视图矩阵加载到矩阵结构体
    PyramidMatrix matrix = {pm,mm};
    
    // 7.将矩阵结构体里的数据通过渲染编码器传递到顶点/片元函数中使用
    [renderEncoder setVertexBytes:&matrix
                           length:sizeof(matrix)
                          atIndex:PyramidVertexInputIndexMatrix];
}

// 将GLKit Matrix 转化为 MetalKit Matrix
- (matrix_float4x4)getMetalMatrixFromGLKMatrix:(GLKMatrix4)matrix
{
    matrix_float4x4 ret = (matrix_float4x4)
    {
        simd_make_float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
        simd_make_float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
        simd_make_float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
        simd_make_float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33),
    };
    return ret;
}

@end
