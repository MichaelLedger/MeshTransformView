//
//  MLMutableMeshTransform+DemoTransforms.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "MLMeshTransform.h"

@interface MLMeshTransform (DemoTransforms)

+ (instancetype)splitSkewTransromAtPoint:(CGPoint)point
                              boundsSize:(CGSize)boundsSize;

+ (instancetype)curtainMeshTransformAtPoint:(CGPoint)point
                                 boundsSize:(CGSize)boundsSize;

+ (instancetype)buldgeMeshTransformAtPoint:(CGPoint)point
                                withRadius:(CGFloat)radius
                                boundsSize:(CGSize)size;

+ (instancetype)shiverTransformWithPhase:(CGFloat)phase magnitude:(CGFloat)magnitude;

+ (instancetype)ellipseMeshTransform;

+ (instancetype)rippleMeshTransform;

@end
