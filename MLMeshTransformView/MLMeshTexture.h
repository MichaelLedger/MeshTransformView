//
//  MLMeshTexture.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLMeshTexture : NSObject

@property (nonatomic, readonly) MTuint texture;

- (void)setupOpenGL;
- (id<MTLTexture>)renderView:(UIView *)view;

@end
