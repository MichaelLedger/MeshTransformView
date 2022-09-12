//
//  MLMeshMultiFaceRenderer.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/9/8.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMeshBuffer.h"
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MLMeshMultiFaceRenderer : NSObject<MTKViewDelegate>

@property (nonatomic, assign) float rotationX;
@property (nonatomic, assign) float rotationY;
@property (nonatomic, assign) float rotationZ;

@property (nonatomic, strong, nullable) id<MTLTexture> texture;

@property (nonatomic, strong) MLMeshBuffer *meshBuffer;

- (id)initWithMetalKitView:(MTKView *)mtkView;

-(id)initWithMetalKitView:(MTKView *)mtkView
               meshBuffer:(MLMeshBuffer *)meshBuffer;

@end

NS_ASSUME_NONNULL_END
