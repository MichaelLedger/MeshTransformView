//
//  MLMeshTexture.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLMeshTexture : NSObject

@property (nonatomic, readonly) GLuint texture;

- (void)setupOpenGL;
- (void)renderView:(UIView *)view;

@end
