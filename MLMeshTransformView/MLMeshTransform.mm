//
//  MLMeshTransform.m
//  MLMeshTransformView
//
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLMeshTransform.h"

#import <vector>

NSString * const kMLDepthNormalizationNone = @"none";
NSString * const kMLDepthNormalizationWidth = @"width";
NSString * const kMLDepthNormalizationHeight = @"height";
NSString * const kMLDepthNormalizationMin = @"min";
NSString * const kMLDepthNormalizationMax = @"max";
NSString * const kMLDepthNormalizationAverage = @"average";


@interface MLMeshTransform()
{
    @protected
    // Performance really matters here, CAMeshTransform makes use of vectors as well
    std::vector<MLMeshFace> _faces;
    std::vector<MLMeshVertex> _vertices;
}
@property (nonatomic, copy, readwrite) NSString *depthNormalization;

@end


@implementation MLMeshTransform
@synthesize depthNormalization = _depthNormalization;

+ (instancetype)meshTransformWithVertexCount:(NSUInteger)vertexCount
                                    vertices:(MLMeshVertex *)vertices
                                   faceCount:(NSUInteger)faceCount
                                       faces:(MLMeshFace *)faces
                          depthNormalization:(NSString *)depthNormalization
{
    return [[self alloc] initWithVertexCount:vertexCount
                                    vertices:vertices
                                   faceCount:faceCount
                                       faces:faces
                          depthNormalization:depthNormalization];
}

- (instancetype)init
{
    return [self initWithVertexCount:0
                            vertices:NULL
                           faceCount:0
                               faces:NULL
                  depthNormalization:kMLDepthNormalizationNone];
}

- (instancetype)initWithVertexCount:(NSUInteger)vertexCount
                           vertices:(MLMeshVertex *)vertices
                          faceCount:(NSUInteger)faceCount
                              faces:(MLMeshFace *)faces
                 depthNormalization:(NSString *)depthNormalization
{
    self = [super init];
    if (self) {
        
        _vertices = std::vector<MLMeshVertex>();
        _vertices.reserve(vertexCount);
        
        _faces = std::vector<MLMeshFace>();
        _faces.reserve(faceCount);
        
        for (int i = 0; i < vertexCount; i++) {
            _vertices.push_back(vertices[i]);
        }

        for (int i = 0; i < faceCount; i++) {
            _faces.push_back(faces[i]);
        }
        
        self.depthNormalization = depthNormalization;
    }
    return self;
}

- (id)copyWithClass:(Class)cls
{
    MLMeshTransform *copy = [cls new];
    copy->_depthNormalization = _depthNormalization;
    copy->_vertices = std::vector<MLMeshVertex>(_vertices);
    copy->_faces = std::vector<MLMeshFace>(_faces);
    
    return copy;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self copyWithClass:[MLMeshTransform class]];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithClass:[MLMutableMeshTransform class]];
}


- (NSUInteger)faceCount
{
    return _faces.size();
}

- (NSUInteger)vertexCount
{
    return _vertices.size();
}

- (MLMeshFace)faceAtIndex:(NSUInteger)faceIndex
{
    NSAssert(faceIndex < _faces.size(), @"Requested faceIndex (%lu) is larger or equal to number of faces (%lu)", (unsigned long)faceIndex, _faces.size());
    
    return _faces[faceIndex];
}

- (MLMeshVertex)vertexAtIndex:(NSUInteger)vertexIndex
{
    NSAssert(vertexIndex < _vertices.size(), @"Requested vertexIndex (%lu) is larger or equal to number of vertices (%lu)", (unsigned long)vertexIndex, _vertices.size());
    
    return _vertices[vertexIndex];
}

@end

@implementation MLMutableMeshTransform

@dynamic depthNormalization;

+ (instancetype)meshTransform
{
    return [[self alloc] init];
}

- (void)addFace:(MLMeshFace)face
{
    _faces.push_back(face);
}

- (void)removeFaceAtIndex:(NSUInteger)faceIndex
{
    _faces.erase(_faces.begin() + faceIndex);
}

- (void)replaceFaceAtIndex:(NSUInteger)faceIndex withFace:(MLMeshFace)face
{
    _faces[faceIndex] = face;
}


- (void)addVertex:(MLMeshVertex)vertex
{
    _vertices.push_back(vertex);
}

- (void)removeVertexAtIndex:(NSUInteger)vertexIndex
{
    _vertices.erase(_vertices.begin() + vertexIndex);
}

- (void)replaceVertexAtIndex:(NSUInteger)vertexIndex withVertex:(MLMeshVertex)vertex
{
    _vertices[vertexIndex] = vertex;
}


@end



