/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for the renderer class that performs Metal setup and per-frame rendering.
*/

#import <MetalKit/MetalKit.h>

/// Platform-independent renderer class.
@interface AAPLMetalRenderer : NSObject<MTKViewDelegate>

// device
@property (nonatomic, strong, nonnull) id<MTLDevice>                  device;
// Metal objects you use to render the temple mesh.
@property (nonatomic, strong, nonnull) id<MTLRenderPipelineState>     templeRenderPipeline;
@property (nonatomic, strong, nonnull) id<MTLBuffer>                  templeVertexPositions;
@property (nonatomic, strong, nonnull) id<MTLBuffer>                  templeVertexGenerics;
// 纹理
@property (nonatomic, strong, nonnull) id<MTLTexture>                 texture;

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end
