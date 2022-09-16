//
//  MLMeshBuffer.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/17.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMeshTransform.h"
#import "mtktypes.h"
#import "MTKVector3.h"
#import "AAPLMetalRenderer.h"
@import MetalKit;

typedef struct MLVertex {
    simd_float3 position;
    simd_float3 normal;
    simd_float2 uv;
} MLVertex;

NS_ASSUME_NONNULL_BEGIN

@interface MLVertextModel : NSObject

@property (nonatomic, assign) simd_float3 position;
@property (nonatomic, assign) simd_float3 normal;
@property (nonatomic, assign) simd_float2 uv;

@end

@interface MLMeshBuffer : NSObject

@property (nonatomic, readonly) MTuint VAO;
@property (nonatomic, readonly) MTsizei indiciesCount;

@property (nonatomic, readonly) simd_float3 positionScale;
@property (nonatomic, strong, readonly) MLMeshTransform *transform;

- (void)setupOpenGL;

- (void)fillWithMeshTransform:(MLMeshTransform *)transform
                positionScale:(simd_float3)positionScale;

- (void)fillWithMeshTransform:(MLMeshTransform *)transform
                positionScale:(simd_float3)positionScale
                       render:(AAPLMetalRenderer *)render;

@end

NS_ASSUME_NONNULL_END
