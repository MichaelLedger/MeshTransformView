//
//  MLMeshMultiFaceRenderer.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/9/8.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import "MLMeshMultiFaceRenderer.h"
#import "MLMeshTransformViewDemo-Swift.h"
#import "MLShaderTypes.h"
#import <GLKit/GLKit.h>

//颜色结构体
typedef struct {
    float red, green, blue, alpha;
} Color;

static dispatch_semaphore_t _frameBoundarySemaphore;

@interface MLMeshMultiFaceRenderer ()

@property (nonatomic, strong) MTKView *mtkView;// 渲染视图
@property (nonatomic, assign) vector_uint2 viewportSize;// 视口
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;// 渲染管道
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;// 命令队列
//@property (nonatomic, strong) id<MTLTexture> texture;// 纹理
@property (nonatomic, strong) id<MTLBuffer> vertices;// 顶点缓存区
@property (nonatomic, strong) id<MTLBuffer> indexs;// 索引缓存区
@property (nonatomic, assign) NSUInteger indexCount;// 索引个数

@end

@implementation MLMeshMultiFaceRenderer
{
//    id<MTLDevice> _device;
//    id<MTLCommandQueue> _commandQueue;
    NSArray *_dynamicDataBuffers;
    NSInteger kMaxInflightBuffers;

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

#pragma mark - Pyramid
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
//        [self setupTexture];
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
    {  // 顶点坐标 xyzw                       顶点颜色 rgb                   纹理坐标 xy
        {{-0.5f, 0.5f, 0.0f, 1.0f},      {0.0f, 0.0f, 0.5f},       {0.0f, 1.0f}},//左上
        {{0.5f, 0.5f, 0.0f, 1.0f},       {0.0f, 0.5f, 0.0f},       {1.0f, 1.0f}},//右上
        {{-0.5f, -0.5f, 0.0f, 1.0f},     {0.5f, 0.0f, 1.0f},       {0.0f, 0.0f}},//左下
        {{0.5f, -0.5f, 0.0f, 1.0f},      {0.0f, 0.0f, 0.5f},       {1.0f, 0.0f}},//右下
        {{0.0f, 0.0f, 1.0f, 1.0f},       {1.0f, 1.0f, 1.0f},       {0.5f, 0.5f}},//顶点 
//        {{0.0f, 0.3f, 1.0f, 1.0f},       {0.5f, 0.5f, 0.0f},       {0.5f, 1.0f}},//中上
//        {{0.0f, -0.3f, 1.0f, 1.0f},      {0.5f, 0.5f, 0.0f},       {0.5f, 0.0f}},//中下
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
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.6, 0.2, 0.5, 1.0f);
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1.0f);

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
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle//test
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
    x = arc4random_uniform(100) / 100.0 * M_PI;
    y = arc4random_uniform(100) / 100.0 * M_PI;
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


#pragma mark - Mesh Transform
//初始化
- (id)initWithMetalKitView:(MTKView *)mtkView
                meshBuffer:(nonnull MLMeshBuffer *)meshBuffer
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        kMaxInflightBuffers = 1;
        _meshBuffer = meshBuffer;
        
        //所有应用程序需要与GPU交互的第一个对象是一个对象。MTLCommandQueue.
        //你使用MTLCommandQueue 去创建对象,并且加入MTLCommandBuffer 对象中.确保它们能够按照正确顺序发送到GPU.对于每一帧,一个新的MTLCommandBuffer 对象创建并且填满了由GPU执行的命令.
        _commandQueue = [_device newCommandQueue];
        
        // Create a semaphore that gets signaled at each frame boundary.
        // The GPU signals the semaphore once it completes a frame's work, allowing the CPU to work on a new frame
        _frameBoundarySemaphore = dispatch_semaphore_create(1);
        [self makeResources];
    }
    
    return self;
}

- (void)makeResources
{
    // Create a FIFO queue of three dynamic data buffers
    // This ensures that the CPU and GPU are never accessing the same buffer simultaneously
    NSMutableArray *mutableDynamicDataBuffers = [NSMutableArray arrayWithCapacity:kMaxInflightBuffers];
    for(int i = 0; i < kMaxInflightBuffers; i++)
    {
        //test
        [mutableDynamicDataBuffers addObject:[self randomMatrix4x4Buffer]];
//        [mutableDynamicDataBuffers addObject:[self customMTKMesh]];
        
        /*==== MTKMesh Begin ====*/
        /*
        MLVertex vertex;
        vertex.position = simd_make_float3(0, 0, 0);
        vertex.uv = simd_make_float2(1, 1);
        vertex.normal = simd_make_float3(0.0f, 0.0f, 0.0f);

        MLVertextModel *vertexModel = [MLVertextModel new];
        vertexModel.position = vertex.position;
        vertexModel.uv = vertex.uv;
        vertexModel.normal = vertex.normal;
        
        // Encoding of 'struct MLVertex' type is incomplete because 'simd_float2' (vector of 2 'float' values) component has unknown encoding
        //    NSValue *structValue = [NSValue valueWithBytes:&vertex objCType:@encode(struct MLVertex)];
        NSValue *structValue = [NSValue valueWithBytes:&vertexModel objCType:@encode(MLVertextModel)];
        NSArray<NSValue *> *vertices = [NSArray arrayWithObjects:structValue, nil];
        
        // The UInt16 value type represents unsigned integers with values ranging from 0 to 65535. Important. The UInt16 type is not CLS-compliant. The CLS-compliant alternative type is Int32. Int16 can be used instead to replace a UInt16 value that ranges from zero to Int16.
        NSNumber *indice = [NSNumber numberWithUnsignedInteger:1];
        NSArray<NSNumber *> *indices = [NSArray arrayWithObjects:indice, nil];
        MTKMesh *mtkMesh = [MLMeshMetalRenderer createMTKMeshWithVertices:vertices indices:indices];
        [mutableDynamicDataBuffers addObject:mtkMesh];
        */
        /*==== MTKMesh End ====*/

    }
    //TODO: Thread 1: EXC_BAD_ACCESS (code=EXC_I386_GPFLT)
    _dynamicDataBuffers = [mutableDynamicDataBuffers copy];
}

- (id <MTLBuffer>)randomMatrix4x4Buffer {
//    matrix_float4x4 projectionMatrix = matrix_identity_float4x4;
    
    
    float randomValue1 = arc4random_uniform(100) / 100.0;
    float randomValue2 = arc4random_uniform(100) / 100.0;
    float randomValue3 = arc4random_uniform(100) / 100.0;
    
//    simd_float4 col0 = simd_make_float4(1, 0, 0, randomValue1);
//    simd_float4 col1 = simd_make_float4(0, 1, 0, randomValue2);
//    simd_float4 col2 = simd_make_float4(0, 0, 1, randomValue3);
//    simd_float4 col3 = simd_make_float4(0, 0, 0, 1);
    
    simd_float4 col0 = simd_make_float4(randomValue1, 0, 0, randomValue1);
    simd_float4 col1 = simd_make_float4(0, randomValue1, 0, randomValue2);
    simd_float4 col2 = simd_make_float4(0, 0, randomValue1, randomValue3);
    simd_float4 col3 = simd_make_float4(0, 0, 0, randomValue1);
//    matrix_float4x4 projectionMatrix = simd_matrix(col0, col1, col2, col3);
    matrix_float4x4 projectionMatrix = {col0, col1, col2, col3};
    
    //test
    [self printMatrixFloat4x4:projectionMatrix];
    
    MTLResourceOptions bufferOptions = MTLResourceCPUCacheModeDefaultCache;
    // Create a new buffer with enough capacity to store one instance of the dynamic buffer data
//        id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithLength:sizeof(projectionMatrix) options:bufferOptions];
    id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithBytes:&projectionMatrix length:sizeof(projectionMatrix) options:bufferOptions];
    return dynamicDataBuffer;
}


#pragma mark - Print Matrix 4x4
- (void)printMatrixFloat4x4:(matrix_float4x4)matrix {
    simd_float4 col0 = matrix.columns[0];
    simd_float4 col1 = matrix.columns[1];
    simd_float4 col2 = matrix.columns[2];
    simd_float4 col3 = matrix.columns[3];
    
    NSLog(@"%s\n%f,%f,%f,%f\n%f,%f,%f,%f\n%f,%f,%f,%f\n%f,%f,%f,%f", __func__, col0[0], col0[1], col0[2], col0[3], col1[0], col1[1], col1[2], col1[3], col2[0], col2[1], col2[2], col2[3], col3[0], col3[1], col3[2], col3[3]);
}

- (MTKMesh *)customMTKMesh {
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:_device];
    MDLMesh *mdlMesh = [[MDLMesh alloc] initSphereWithExtent:simd_make_float3(0.75, 0.75, 0.75) segments:(vector_uint2){100, 100} inwardNormals:NO geometryType:MDLGeometryTypeTriangles allocator:allocator];
    NSError *error = nil;
    MTKMesh *mtkMesh =[[MTKMesh alloc] initWithMesh:mdlMesh device:_device error:&error];
    return mtkMesh;
}

#pragma mark - WARNING: Abandoned OC, please use Swift - MLMeshMetalRenderer
- (MTKMesh *)customMTKMesh2 {
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:_device];
    NSInteger vertexCount = _meshBuffer.transform.vertexCount == 0 ? 1 : _meshBuffer.transform.vertexCount;
    id<MDLMeshBuffer> vertexBuffer = [allocator newBuffer:vertexCount type:MDLMeshBufferTypeVertex];
//    MDLMeshBufferMap *map = [mdlMeshBuffer map];
//    [map bytes];
    
    id<MDLMeshBuffer> indexBuffer = [allocator newBuffer:1 type:MDLMeshBufferTypeIndex];//test
     
    MDLSubmesh *subMesh = [[MDLSubmesh alloc] initWithIndexBuffer:indexBuffer indexCount:vertexCount indexType:MDLIndexBitDepthUInt16 geometryType:MDLGeometryTypeTriangles material:nil];
    
    MDLVertexDescriptor *vertexDesc =[MDLVertexDescriptor new];
    vertexDesc.attributes[0] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition format:MDLVertexFormatFloat2 offset:0 bufferIndex:0];
    
    MDLMesh *mdlMesh = [[MDLMesh alloc] initWithVertexBuffer:vertexBuffer vertexCount:vertexCount descriptor:vertexDesc submeshes:@[subMesh]];
    NSError *error = nil;
    MTKMesh *mtkMesh =[[MTKMesh alloc] initWithMesh:mdlMesh device:_device error:&error];
    return mtkMesh;
}

//设置颜色
- (Color)makeFancyColor
{
    //1. 增加颜色/减小颜色的 标记
    static BOOL       growing = YES;
    //2.颜色通道值(0~3)
    static NSUInteger primaryChannel = 0;
    //3.颜色通道数组colorChannels(颜色值)
    static float      colorChannels[] = {1.0, 0.0, 0.0, 1.0};
    //4.颜色调整步长
    const float DynamicColorRate = 0.015;
    
    //5.判断
    if(growing)
    {
        //动态信道索引 (1,2,3,0)通道间切换
        NSUInteger dynamicChannelIndex = (primaryChannel+1)%3;
        
        //修改对应通道的颜色值 调整0.015
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        
        //当颜色通道对应的颜色值 = 1.0
        if(colorChannels[dynamicChannelIndex] >= 1.0)
        {
            //设置为NO
            growing = NO;
            
            //将颜色通道修改为动态颜色通道
            primaryChannel = dynamicChannelIndex;
        }
    }
    else
    {
        //获取动态颜色通道
        NSUInteger dynamicChannelIndex = (primaryChannel+2)%3;
        
        //将当前颜色的值 减去0.015
        colorChannels[dynamicChannelIndex] -= DynamicColorRate;
        
        //当颜色值小于等于0.0
        if(colorChannels[dynamicChannelIndex] <= 0.0)
        {
            //又调整为颜色增加
            growing = YES;
        }
    }
    
    //创建颜色
    Color color;
    
    //修改颜色的RGBA的值
    color.red   = colorChannels[0];
    color.green = colorChannels[1];
    color.blue  = colorChannels[2];
    color.alpha = colorChannels[3];
    
    //返回颜色
    return color;
}

- (void)update {
    /* Perform updates */
    
    // simd_equal(_meshBuffer.positionScale, simd_make_float3(0, 0, 0))
    if (!_meshBuffer.transform) {
        return;
    }
    
    /*
    // Create a FIFO queue of three dynamic data buffers
    // This ensures that the CPU and GPU are never accessing the same buffer simultaneously
//    MTLResourceOptions bufferOptions = MTLResourceCPUCacheModeDefaultCache;
    NSMutableArray *mutableDynamicDataBuffers = [NSMutableArray arrayWithCapacity:_meshBuffer.transform.faceCount];
    for(int i = 0; i < _meshBuffer.transform.faceCount; i++)
    {
//        MLMeshVertex meshVertex = [_meshBuffer.transform vertexAtIndex:i];
        MLMeshFace meshFace = [_meshBuffer.transform faceAtIndex:i];
        
//        size_t vertex_size = sizeof(meshVertex);
        size_t indices_size = sizeof(meshFace.indices);

        id<MTLBuffer> indices_buf = [_device newBufferWithLength:indices_size options:MTLResourceCPUCacheModeDefaultCache];
        memcpy(indices_buf.contents, &meshFace.indices, indices_size);
//        id<MTLBuffer> vertices_buf = [_device newBufferWithLength:vertex_size options:MTLResourceCPUCacheModeDefaultCache];
//        memcpy(vertices_buf.contents, &meshVertex, vertex_size);
        
        //test
//        matrix_float4x4 projectionMatrix = matrix_identity_float4x4;
        
//        simd_float4 col0 = simd_make_float4(1, 0, 0, 0.5);
//        simd_float4 col1 = simd_make_float4(0, 1, 0, 0);
//        simd_float4 col2 = simd_make_float4(0, 0, 1, 0);
//        simd_float4 col3 = simd_make_float4(0, 0, 0, 1);
//        matrix_float4x4 projectionMatrix = simd_matrix(col0, col1, col2, col3);
        
        // Create a new buffer with enough capacity to store one instance of the dynamic buffer data
//        id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithLength:sizeof(projectionMatrix) options:bufferOptions];
//        id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithBytes:&projectionMatrix length:sizeof(projectionMatrix) options:bufferOptions];
        
        
        [mutableDynamicDataBuffers addObject:indices_buf];
//        [mutableDynamicDataBuffers addObject:vertices_buf];
    }
     */
    
//    MTKMesh *mtkMesh = [MLMeshMetalRender customMTKMesh2];
//    _dynamicDataBuffers = @[mtkMesh];
    
    MLVertex vertex;
    vertex.position = simd_make_float3(0, 0, 0);
    vertex.uv = simd_make_float2(1, 1);
    vertex.normal = simd_make_float3(0.0f, 0.0f, 0.0f);

    MLVertextModel *vertexModel = [MLVertextModel new];
    vertexModel.position = vertex.position;
    vertexModel.uv = vertex.uv;
    vertexModel.normal = vertex.normal;
    /*
     Encoding of 'struct MLVertex' type is incomplete because 'simd_float2' (vector of 2 'float' values) component has unknown encoding
     */
//    NSValue *structValue = [NSValue valueWithBytes:&vertex objCType:@encode(struct MLVertex)];
    NSValue *structValue = [NSValue valueWithBytes:&vertexModel objCType:@encode(MLVertextModel)];
    NSArray<NSValue *> *vertices = [NSArray arrayWithObjects:structValue, nil];
    
    /*
     The UInt16 value type represents unsigned integers with values ranging from 0 to 65535. Important. The UInt16 type is not CLS-compliant. The CLS-compliant alternative type is Int32. Int16 can be used instead to replace a UInt16 value that ranges from zero to Int16.
     */
    NSNumber *indice = [NSNumber numberWithUnsignedInteger:1];
    NSArray<NSNumber *> *indices = [NSArray arrayWithObjects:indice, nil];
    MTKMesh *mtkMesh = [MLMeshMetalRenderer createMTKMeshWithVertices:vertices indices:indices];
    _dynamicDataBuffers = @[mtkMesh];
    
    /*
     TODO: Thread 1: EXC_BAD_ACCESS (code=1, address=0x25)
     */
}

- (void)render:(nonnull MTKView *)view {
    @autoreleasepool {
        // Wait until the inflight command buffer has completed its work
        dispatch_semaphore_wait(_frameBoundarySemaphore, DISPATCH_TIME_FOREVER);
        
        // Update the per-frame dynamic buffer data
//        [self update];//test
        
        //1. 获取颜色值
//        Color color = [self makeFancyColor];
        //2. 设置view的clearColor
//        view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);
        
    //    view.clearColor = MTLClearColorMake(0, 0, 0, 0);//alpha clear
        view.clearColor = MTLClearColorMake(1, 1, 1, 1);//white
        
        //3. Create a new command buffer for each render pass to the current drawable
        //使用MTLCommandQueue 创建对象并且加入到MTCommandBuffer对象中去.
        //为当前渲染的每个渲染传递创建一个新的命令缓冲区
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"MyCommand";
        
        //4.从视图绘制中,获得渲染描述符
        MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
        
        //5.判断renderPassDescriptor 渲染描述符是否创建成功,否则则跳过任何渲染.
        if(renderPassDescriptor != nil)
        {
            //6.通过渲染描述符renderPassDescriptor创建MTLRenderCommandEncoder 对象
            // Create a command buffer and render command encoder
            id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            renderEncoder.label = @"MyRenderEncoder";
            
            /* Additional encoding */
            [self drawWithAdditionalRenderCommands:nil texture:_texture inBuffer:commandBuffer using:renderEncoder fence:nil];
            
            //7.我们可以使用MTLRenderCommandEncoder 来绘制对象,但是这个demo我们仅仅创建编码器就可以了,我们并没有让Metal去执行我们绘制的东西,这个时候表示我们的任务已经完成.
            //即可结束MTLRenderCommandEncoder 工作
            [renderEncoder endEncoding];
            
            /*
             当编码器结束之后,命令缓存区就会接受到2个命令.
             1) present
             2) commit
             因为GPU是不会直接绘制到屏幕上,因此你不给出去指令.是不会有任何内容渲染到屏幕上.
            */
            //8.添加一个最后的命令来显示清除的可绘制的屏幕
            // // Schedule a drawable presentation to occur after the GPU completes its work
            [commandBuffer presentDrawable:view.currentDrawable];
            
            __weak dispatch_semaphore_t semaphore = _frameBoundarySemaphore;
            [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull commandBuffer) {
                // GPU work is complete
                // Signal the semaphore to start the CPU work
                dispatch_semaphore_signal(semaphore);
            }];
        }
        
        //9.在这里完成渲染并将命令缓冲区提交给GPU
        // CPU work is complete
        // Commit the command buffer and start the GPU work
        [commandBuffer commit];
    }
}

#pragma mark - MTKViewDelegate methods

//每当视图需要渲染时调用
//- (void)drawInMTKView:(nonnull MTKView *)view
//{
//    [self render:view];
//}
//
////当MTKView视图发生大小改变时调用
//- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
//{
//
//}

//MARK: Draw

/// Draw a texture
///
/// - Note: This method should be called on main thread only.
///
/// - Parameters:
///   - texture: texture to draw
///   - additionalRenderCommands: render commands to execute after texture draw.
///   - commandBuffer: command buffer to put the work in.
///   - fence: metal fence.
- (void)drawWithAdditionalRenderCommands:(void(^)(_Nullable id<MTLRenderCommandEncoder>))additionalRenderCommands
                                 texture:(id<MTLTexture>)texture
                                inBuffer:(id<MTLCommandBuffer>)commandBuffer
                                   using:(id<MTLRenderCommandEncoder>)renderEncoder
                                   fence:(_Nullable id<MTLFence>)fence
{
    if (fence) {
        [renderEncoder waitForFence:fence beforeStages:MTLRenderStageFragment];
    }
    
    [renderEncoder setCullMode:MTLCullModeNone];
    id<MTLRenderPipelineState> pipelineState = [self renderPipelineStateWithPixelFormat:MTLPixelFormatBGRA8Unorm];
    
    NSAssert(pipelineState, @"failed assertion `Draw Errors Validation` - renderPipelineState must be set.");
    [renderEncoder setRenderPipelineState:pipelineState];
    
    /*
     The setVertexBytes:length:atIndex: method is the best option for binding a very small amount (less than 4 KB) of dynamic buffer data to a vertex function, as shown in Listing 5-1. This method avoids the overhead of creating an intermediary MTLBuffer object. Instead, Metal manages a transient buffer for you.
     
     Listing 5-1Binding a very small amount (less than 4 KB) of dynamic buffer data
     
     float _verySmallData = 1.0;
     [renderEncoder setVertexBytes:&_verySmallData length:sizeof(float) atIndex:0];
     */
    matrix_float4x4 projectionMatrix = matrix_identity_float4x4;
//    [renderEncoder setVertexBytes:&projectionMatrix length:sizeof(projectionMatrix) atIndex:0];
    
    /*
     If your data size is larger than 4 KB, create a MTLBuffer object once and update its contents as needed. Call the setVertexBuffer:offset:atIndex: method to bind the buffer to a vertex function; if your buffer contains data used in multiple draw calls, call the setVertexBufferOffset:atIndex: method afterward to update the buffer offset so it points to the location of the corresponding draw call data, as shown in Listing 5-2. You do not need to rebind the currently bound buffer if you are only updating its offset.
     
     Listing 5-2Updating the offset of a bound buffer
     
     // Bind the vertex buffer once
     [renderEncoder setVertexBuffer:_vertexBuffer[_frameIndex] offset:0 atIndex:0];
     for(int i=0; i<_drawCalls; i++)
     {
         //  Update the vertex buffer offset for each draw call
         [renderEncoder setVertexBufferOffset:i*_sizeOfVertices atIndex:0];
      
         // Draw the vertices
         [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexCount];
     }
     */
    
//    MTKMesh *mtkMesh = _dynamicDataBuffers[0];
//    [renderEncoder setVertexBuffer:mtkMesh.vertexBuffers[0].buffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_dynamicDataBuffers[0] offset:0 atIndex:0];//test
    
//    MTKSubmesh *submesh = mtkMesh.submeshes.firstObject;
//    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:submesh.indexCount indexType:submesh.indexType indexBuffer:submesh.indexBuffer.buffer indexBufferOffset:0];//test
    
    for(int i=0; i<kMaxInflightBuffers; i++)
    {
        //  Update the vertex buffer offset for each draw call
        [renderEncoder setVertexBufferOffset:i*sizeof(projectionMatrix) atIndex:0];
        
//        [renderEncoder setFragmentBuffer:[self randomMatrix4x4Buffer]  offset:0 atIndex:0];//test
        [renderEncoder setFragmentTexture:texture atIndex:0];

        // Draw the vertices
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    }
    
    if (additionalRenderCommands) {
        additionalRenderCommands(renderEncoder);
    }
}

#pragma mark VertexFunction 顶点函数
//@"textureViewVertex" @"vertex_main" @"vertexShader"
static NSString *const kVertexFunctionName = @"textureViewVertex";

#pragma mark FragmentFunction 片元函数
// @"textureViewFragment" @"fragment_main" @"fragmentShader"
static NSString *const kfragmentFunctionName = @"textureViewFragment";
- (nullable id<MTLRenderPipelineState>)renderPipelineStateWithPixelFormat:(MTLPixelFormat)pixelFormat {
    if (_device) {
        NSError *err;
        //Note: The default library is only included in your app when you have at least one .metal file in your app target's Compile Sources build phase.
        id<MTLLibrary> library = [_device newDefaultLibraryWithBundle:[self libraryBundle] error:&err];
        if (!err) {
            MTLRenderPipelineDescriptor *pipelineDes = [MTLRenderPipelineDescriptor new];
            pipelineDes.label = @"Texture View";
            pipelineDes.vertexFunction = [library newFunctionWithName:kVertexFunctionName];
            pipelineDes.fragmentFunction = [library newFunctionWithName:kfragmentFunctionName];
            pipelineDes.colorAttachments[0].pixelFormat = pixelFormat;
            pipelineDes.colorAttachments[0].blendingEnabled = NO;
//            MTKMesh *mtkMesh = _dynamicDataBuffers[0];
//            pipelineDes.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mtkMesh.vertexDescriptor);//test
            id<MTLRenderPipelineState> pipelineState = [[library device] newRenderPipelineStateWithDescriptor:pipelineDes error:&err];
            //Error Domain=CompilerError Code=1 "Vertex function has input attributes but no vertex descriptor was set."
            if (!err) {
                return pipelineState;
            } else {
                NSLog(@"%@", err.localizedDescription);
            }
        } else {
            NSLog(@"%@", err.localizedDescription);
        }
    }
    return nil;
}

- (NSBundle *)libraryBundle {
    NSString *bundleName = NSStringFromClass([self class]);
    NSArray<NSURL *> *candidates = @[[NSBundle mainBundle].resourceURL, [NSBundle bundleForClass:[self class]].resourceURL, [NSBundle mainBundle].bundleURL];
    for (NSURL *candidate in candidates) {
//        NSURL *bundlePath = [candidate URLByAppendingPathComponent:@".bundle"];
        NSBundle *bundle = [[NSBundle alloc] initWithURL:candidate];
        if (bundle) {
            return bundle;
        }
    }
    NSAssert(NO, @"unable to find bundle named:%@", bundleName);
    return nil;
}

@end
