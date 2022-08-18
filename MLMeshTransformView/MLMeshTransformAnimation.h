//
//  MLMeshTransformAnimation.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLMeshTransform;
@interface MLMeshTransformAnimation : NSObject

@property (nonatomic, strong, readonly) MLMeshTransform *currentMeshTransform;
@property (nonatomic, readonly, getter=isCompleted) BOOL completed;

- (instancetype)initWithAnimation:(CAAnimation *)animation
                 currentTransform:(MLMeshTransform *)currentTransform
             destinationTransform:(MLMeshTransform *)destinationTransform;

- (void)tick:(NSTimeInterval)dt;


@end
