//
//  MLMeshContentView.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLMeshContentView : UIView

@property (nonatomic, copy) void (^changeBlock)(void);
@property (nonatomic, copy) void (^tickBlock)(CADisplayLink *);

- (instancetype)initWithFrame:(CGRect)frame
                  changeBlock:(void (^)(void))changeBlock
                    tickBlock:(void (^)(CADisplayLink *))tickBlock;
- (void)displayLinkTick:(CADisplayLink *)displayLink;

@end
