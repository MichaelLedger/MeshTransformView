//
//  MLMeshMetalRender.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/17.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

#import "MLMeshMetalRender.h"

//颜色结构体
typedef struct {
    float red, green, blue, alpha;
} Color;

static dispatch_semaphore_t _frameBoundarySemaphore;

@implementation MLMeshMetalRender
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    NSArray <id <MTLBuffer>> *_dynamicDataBuffers;
    NSInteger kMaxInflightBuffers;
}

//初始化
- (id)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        kMaxInflightBuffers = 1;
        
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
        [mutableDynamicDataBuffers addObject:[self randomMatrix4x4Buffer]];
    }
    _dynamicDataBuffers = [mutableDynamicDataBuffers copy];
}

- (id <MTLBuffer>)randomMatrix4x4Buffer {
    //matrix_float4x4 projectionMatrix = matrix_identity_float4x4;
    
    float randomValue1 = arc4random_uniform(100) / 100.0;
    float randomValue2 = arc4random_uniform(100) / 100.0;
    float randomValue3 = arc4random_uniform(100) / 100.0;
    
    simd_float4 col0 = simd_make_float4(1, 0, 0, randomValue1);
    simd_float4 col1 = simd_make_float4(0, 1, 0, randomValue2);
    simd_float4 col2 = simd_make_float4(0, 0, 1, randomValue3);
    simd_float4 col3 = simd_make_float4(0, 0, 0, 1);
    matrix_float4x4 projectionMatrix = simd_matrix(col0, col1, col2, col3);
    
    MTLResourceOptions bufferOptions = MTLResourceCPUCacheModeDefaultCache;
    // Create a new buffer with enough capacity to store one instance of the dynamic buffer data
//        id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithLength:sizeof(projectionMatrix) options:bufferOptions];
    id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithBytes:&projectionMatrix length:sizeof(projectionMatrix) options:bufferOptions];
    return dynamicDataBuffer;
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
    _dynamicDataBuffers = [mutableDynamicDataBuffers copy];
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
- (void)drawInMTKView:(nonnull MTKView *)view
{
    [self render:view];
}

//当MTKView视图发生大小改变时调用
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

// MARK: Draw

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
    
    [renderEncoder setVertexBuffer:_dynamicDataBuffers[0] offset:0 atIndex:0];
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

static NSString *const kVertexFunctionName = @"textureViewVertex";
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
            id<MTLRenderPipelineState> pipelineState = [[library device] newRenderPipelineStateWithDescriptor:pipelineDes error:&err];
            if (!err) {
                return pipelineState;
            }
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
