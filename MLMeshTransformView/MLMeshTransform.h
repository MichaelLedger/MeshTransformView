//
//  MLMeshTransform.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct MLPoint3D {
    CGFloat x;
    CGFloat y;
    CGFloat z;
} MLPoint3D;

static inline MLPoint3D MLPoint3DMake(CGFloat x, CGFloat y, CGFloat z)
{
    return (MLPoint3D){x,y,z};
}


typedef struct MLMeshFace {
    unsigned int indices[4];
} MLMeshFace;

typedef struct MLMeshVertex {
    CGPoint from;
    MLPoint3D to;
} MLMeshVertex;


extern NSString * const kMLDepthNormalizationNone;
extern NSString * const kMLDepthNormalizationWidth;
extern NSString * const kMLDepthNormalizationHeight;
extern NSString * const kMLDepthNormalizationMin;
extern NSString * const kMLDepthNormalizationMax;
extern NSString * const kMLDepthNormalizationAverage;

@interface MLMeshTransform : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy, readonly) NSString *depthNormalization; // defaults to kMLDepthNormalizationNone

@property (nonatomic, readonly) NSUInteger faceCount;
@property (nonatomic, readonly) NSUInteger vertexCount;

+ (instancetype)meshTransformWithVertexCount:(NSUInteger)vertexCount
                                    vertices:(MLMeshVertex *)vertices
                                   faceCount:(NSUInteger)faceCount
                                       faces:(MLMeshFace *)faces
                          depthNormalization:(NSString *)depthNormalization;


- (instancetype)initWithVertexCount:(NSUInteger)vertexCount
                           vertices:(MLMeshVertex *)vertices
                          faceCount:(NSUInteger)faceCount
                              faces:(MLMeshFace *)faces
                 depthNormalization:(NSString *)depthNormalization;


- (MLMeshFace)faceAtIndex:(NSUInteger)faceIndex;
- (MLMeshVertex)vertexAtIndex:(NSUInteger)vertexIndex;

@end


@interface MLMutableMeshTransform : MLMeshTransform

@property (nonatomic, copy, readwrite) NSString *depthNormalization;

+ (instancetype)meshTransform;

//- (void)setDepthNormalization:(NSString *)depthNormalization;

- (void)addFace:(MLMeshFace)face;
- (void)removeFaceAtIndex:(NSUInteger)faceIndex;
- (void)replaceFaceAtIndex:(NSUInteger)faceIndex withFace:(MLMeshFace)face;

- (void)addVertex:(MLMeshVertex)vertex;
- (void)removeVertexAtIndex:(NSUInteger)vertexIndex;
- (void)replaceVertexAtIndex:(NSUInteger)vertexIndex withVertex:(MLMeshVertex)vertex;

@end

