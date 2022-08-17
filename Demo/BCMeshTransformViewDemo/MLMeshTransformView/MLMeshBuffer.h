//
//  MLMeshBuffer.h
//  BCMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/17.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BCMeshTransform;
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MLMeshBuffer : NSObject

- (void)fillWithMeshTransform:(BCMeshTransform *)transform
                positionScale:(simd_float3)positionScale;

@end

NS_ASSUME_NONNULL_END
