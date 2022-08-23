//
//  MLMeshTransformView.m
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

//#import <GLKit/GLKit.h>
//#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES2/glext.h>

#import "MLMeshTransformView.h"
#import "MLMeshContentView.h"

#import "MLMeshBuffer.h"
#import "MLMeshTexture.h"

#import "MLMeshTransformAnimation.h"

#import "MLMutableMeshTransform+Convenience.h"

#import "MLMeshMetalRender.h"

@interface MLMeshTransformView()

@property (nonatomic, strong) MLMeshBuffer *buffer;
@property (nonatomic, strong) MLMeshTexture *texture;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) MLMeshTransformAnimation *animation;

@property (nonatomic, copy) MLMeshTransform *presentationMeshTransform;

@property (nonatomic, strong) UIView *dummyAnimationView;

@property (nonatomic) BOOL pendingContentRendering;

// Use Metal (MTKView) instead of OpenGL (mtkView).
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) MLMeshMetalRender *render;

@end


@implementation MLMeshTransformView

/*
+ (EAGLContext *)renderingContext
{
    static EAGLContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    });
    
    return context;
}
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.opaque = NO;

    _diffuseLightFactor = 1.0f;
    _lightDirection = MLPoint3DMake(0.0, 0.0, 1.0);
    
    _supplementaryTransform = CATransform3DIdentity;
    
    UIView *contentViewWrapperView = [[UIView alloc] initWithFrame:self.bounds];//test
    contentViewWrapperView.clipsToBounds = YES;
    [super addSubview:contentViewWrapperView];
    
    __weak typeof(self) welf = self; // thank you John Siracusa!
    _contentView = [[MLMeshContentView alloc] initWithFrame:self.bounds
                                                changeBlock:^{
                                                    [welf setNeedsContentRendering];
                                                } tickBlock:^(CADisplayLink *displayLink) {
//                                                    [welf displayLinkTick:displayLink];
                                                }];
    _contentView.backgroundColor = [UIColor orangeColor];
    [contentViewWrapperView addSubview:_contentView];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:_contentView selector:@selector(displayLinkTick:)];
    _displayLink.paused = YES;
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    // a dummy view that's used for fetching the parameters
    // of a current animation block and getting animated
    self.dummyAnimationView = [UIView new];
    [contentViewWrapperView addSubview:self.dummyAnimationView];
    
    _buffer = [MLMeshBuffer new];
    _texture = [MLMeshTexture new];
    
    [self setupGL];
    
    //一个MTLDevice 对象就代表这着一个GPU,通常我们可以调用方法MTLCreateSystemDefaultDevice()来获取代表默认的GPU单个对象.
    id <MTLDevice> device = MTLCreateSystemDefaultDevice();
    _mtkView = [[MTKView alloc] initWithFrame:self.bounds device:device];
    //判断是否设置成功
    NSAssert(_mtkView.device, @"Metal is not supported on this device");
    _render = [[MLMeshMetalRender alloc] initWithMetalKitView:_mtkView];
    _mtkView.delegate = _render;
    //视图可以根据视图属性上设置帧速率(指定时间来调用drawInMTKView方法--视图需要渲染时调用)
    _mtkView.preferredFramesPerSecond = 60;
    [super addSubview:_mtkView];
    
    self.meshTransform = [MLMutableMeshTransform identityMeshTransformWithNumberOfRows:1 numberOfColumns:1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mtkView.frame = self.bounds;
    self.contentView.bounds = self.bounds;
}

#pragma mark - Setters

- (void)setMeshTransform:(MLMeshTransform *)meshTransform
{
    // If we're inside an animation block, then we change properties of
    // a dummy animation layer so that it gets the same animation context.
    // We're changing the values twice, since no animation will be added
    // if the from and to values are equal. This also ensures that the completion
    // block of the calling animation gets executed when animation is finished.
    
    [self.dummyAnimationView.layer removeAllAnimations];
    self.dummyAnimationView.layer.opacity = 1.0;
    self.dummyAnimationView.layer.opacity = 0.0;
    CAAnimation *animation = [self.dummyAnimationView.layer animationForKey:@"opacity"];
    
    if ([animation isKindOfClass:[CABasicAnimation class]]) {
        [self setAnimation:[[MLMeshTransformAnimation alloc] initWithAnimation:animation
                                                              currentTransform:self.presentationMeshTransform
                                                          destinationTransform:meshTransform]];
    } else {
        self.animation = nil;
        [self setPresentationMeshTransform:meshTransform];
    }
    
    _meshTransform = [meshTransform copy];
}

- (void)setPresentationMeshTransform:(MLMeshTransform *)presentationMeshTransform
{
    _presentationMeshTransform = [presentationMeshTransform copy];
    
    [self.buffer fillWithMeshTransform:presentationMeshTransform
                         positionScale:[self positionScaleWithDepthNormalization:self.presentationMeshTransform.depthNormalization]];
    [self.mtkView setNeedsDisplay];
}

- (void)setLightDirection:(MLPoint3D)lightDirection
{
    _lightDirection = lightDirection;
    [self.mtkView setNeedsDisplay];
}

- (void)setDiffuseLightFactor:(float)diffuseLightFactor
{
    _diffuseLightFactor = diffuseLightFactor;
    [self.mtkView setNeedsDisplay];
}

- (void)setSupplementaryTransform:(CATransform3D)supplementaryTransform
{
    _supplementaryTransform = supplementaryTransform;
    [self.mtkView setNeedsDisplay];
}

- (void)setAnimation:(MLMeshTransformAnimation *)animation
{
    if (animation) {
        self.displayLink.paused = NO;
    }
    _animation = animation;
}

- (void)setNeedsContentRendering
{
    if (self.pendingContentRendering == NO) {
        // next run loop tick
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0)), dispatch_get_main_queue(), ^{
            id<MTLTexture> mt_texture = [self.texture renderView:self.contentView];
            self.render.texture = mt_texture;
            [self.mtkView setNeedsDisplay];
            
            self.pendingContentRendering = NO;
        });
        
        self.pendingContentRendering = YES;
    }
}

#pragma mark - Hit Testing

// We're cheating on the view hierarchy, telling it that contentView is not clipped by wrapper view
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.contentView hitTest:point withEvent:event];
}


#pragma mark - Animation Handling

//- (void)displayLinkTick:(CADisplayLink *)displayLink
//{
//    [self.animation tick:displayLink.duration];
//
//    if (self.animation) {
//        self.presentationMeshTransform = self.animation.currentMeshTransform;
//
//        if (self.animation.isCompleted) {
//            self.animation = nil;
//            self.displayLink.paused = YES;
//        }
//    } else {
//        self.displayLink.paused = YES;
//    }
//}

- (void)setupGL
{
//    [EAGLContext setCurrentContext:[MLMeshTransformView renderingContext]];
    
//    [self.shader loadProgram];
    [self.buffer setupOpenGL];
    [self.texture setupOpenGL];
    
    // force initial texture rendering
    id<MTLTexture> mt_texture = [self.texture renderView:self.contentView];
    self.render.texture = mt_texture;
    
//    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
//    glEnable(GL_DEPTH_TEST);
}

#pragma mark - Geometry


/*
- (simd_float4x4)transformMatrix
{
    float xScale = self.bounds.size.width;
    float yScale = self.bounds.size.height;
    float zScale = 0.5*[self zScaleForDepthNormalization:[self.presentationMeshTransform depthNormalization]];
    
    float invXScale = xScale == 0.0f ? 1.0f : 1.0f/xScale;
    float invYScale = yScale == 0.0f ? 1.0f : 1.0f/yScale;
    float invZScale = zScale == 0.0f ? 1.0f : 1.0f/zScale;
    
    
    CATransform3D m = self.supplementaryTransform;
    GLKMatrix4 matrix = GLKMatrix4Identity;
    
    matrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-0.5f, -0.5f, 0.0f), matrix);
    matrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(xScale, yScale, zScale), matrix);
    
    // at this point we're in a "point-sized" world,
    // the translations and projections will behave correctly
    
    matrix = GLKMatrix4Multiply(GLKMatrix4Make(m.m11, m.m12, m.m13, m.m14,
                                               m.m21, m.m22, m.m23, m.m24,
                                               m.m31, m.m32, m.m33, m.m34,
                                               m.m41, m.m42, m.m43, m.m44), matrix);
    
    matrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(invXScale, invYScale, invZScale), matrix);
    matrix = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0, -2.0, 1.0), matrix);
    
    return matrix;
}
 */

- (simd_float3)positionScaleWithDepthNormalization:(NSString *)depthNormalization
{
    float xScale = self.bounds.size.width;
    float yScale = self.bounds.size.height;
    float zScale = [self zScaleForDepthNormalization:depthNormalization];
    
    return simd_float3_make(xScale, yScale, zScale);
}


- (float)zScaleForDepthNormalization:(NSString *)depthNormalization
{
    static NSDictionary *dictionary;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = @{
                       kMLDepthNormalizationWidth   : ^float(CGSize size) { return size.width; },
                       kMLDepthNormalizationHeight  : ^float(CGSize size) { return size.height; },
                       kMLDepthNormalizationMin     : ^float(CGSize size) { return MIN(size.width, size.height); },
                       kMLDepthNormalizationMax     : ^float(CGSize size) { return MAX(size.width, size.height); },
                       kMLDepthNormalizationAverage : ^float(CGSize size) { return 0.5 * (size.width + size.height); },
                       };
    });
    
    float (^block)(CGSize size) = dictionary[depthNormalization];
    
    if (block) {
        return block(self.bounds.size);
    }
    
    return 0.0;
}

#pragma mark - Warning Methods

// A simple warning for convenience's sake

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    NSLog(@"Warning: do not add a subview directly to MLMeshTransformView. Add it to contentView instead.");
}

@end
