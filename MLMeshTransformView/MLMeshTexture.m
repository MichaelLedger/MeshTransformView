//
//  MLMeshTexture.m
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "MLMeshTexture.h"
@import MetalKit;

//#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES2/glext.h>

@implementation MLMeshTexture


- (void)setupOpenGL
{
    //test
    /*
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
     */
}

- (void)dealloc
{
    /*
    if (_texture) {
        glDeleteTextures(1, &_texture);
    }
     */
}



- (id<MTLTexture>)renderView:(UIView *)view
{
    const CGFloat Scale = [UIScreen mainScreen].scale;
    
    MTsizei width = view.layer.bounds.size.width * Scale;
    MTsizei height = view.layer.bounds.size.height * Scale;
    
    MTubyte *texturePixelBuffer = (MTubyte *)calloc(width * height * 4, sizeof(MTubyte));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(texturePixelBuffer,
                                                 width, height, 8, width * 4, colorSpace,
                                                 kCGImageAlphaPremultipliedLast |
                                                 kCGBitmapByteOrder32Big);
    CGContextScaleCTM(context, Scale, Scale);
    
    UIGraphicsPushContext(context);
    
    // View (0x7febb4e04840, MLMeshContentView) drawing with afterScreenUpdates:YES inside CoreAnimation commit is not supported.
    [view drawViewHierarchyInRect:view.layer.bounds afterScreenUpdates:NO];
    
    // Drawing a view (0x7fc663c287e0, MLMeshContentView) that has not been rendered at least once requires afterScreenUpdates:YES.
//    [view drawViewHierarchyInRect:view.layer.bounds afterScreenUpdates:YES];
    
    // iew (0x7febb4e04840, MLMeshContentView) drawing with afterScreenUpdates:YES inside CoreAnimation commit is not supported.
    
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.layer.bounds afterScreenUpdates:NO];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:MTLCreateSystemDefaultDevice()];
    NSError *error = nil;
    id<MTLTexture> texture = [textureLoader newTextureWithCGImage:snap.CGImage options:nil error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    /*
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texturePixelBuffer);
    glBindTexture(GL_TEXTURE_2D, 0);
     */

    free(texturePixelBuffer);
    return texture;
}

@end
