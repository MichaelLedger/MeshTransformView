//
//  MLMeshLargeDataRenderer.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/30.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MLMeshLargeDataRenderer : NSObject<MTKViewDelegate>

@property (nonatomic, strong, nullable) id<MTLTexture> texture;

- (id)initWithMetalKitView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
