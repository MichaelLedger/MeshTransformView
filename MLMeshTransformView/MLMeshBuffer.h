//
//  MLMeshBuffer.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/17.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MLMeshTransform;
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MLMeshBuffer : NSObject

@property (nonatomic, readonly) MTuint VAO;
@property (nonatomic, readonly) MTsizei indiciesCount;

- (void)setupOpenGL;

- (void)fillWithMeshTransform:(MLMeshTransform *)transform
                positionScale:(simd_float3)positionScale;

@end

NS_ASSUME_NONNULL_END
