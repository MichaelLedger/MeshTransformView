//
//  MLMeshBuffer.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/17.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

#import "MLMeshBuffer.h"
#import "MLMeshTransform.h"
#import <simd/simd.h>

typedef struct MLVertex {
    simd_float3 position;
    simd_float3 normal;
    simd_float2 uv;
} MLVertex;

@implementation MLMeshBuffer
{
    MTuint _indexBuffer;
    MTuint _vertexBuffer;
    
    MTsizeiptr _indexBufferCapacity;
    MTsizeiptr _vertexBufferCapacity;
}

- (void)setupOpenGL
{
//    glGenVertexArraysOES(1, &_VAO);
//    glGenBuffers(1, &_indexBuffer);
//    glGenBuffers(1, &_vertexBuffer);
}

- (void)dealloc
{
//    glDeleteBuffers(1, &_vertexBuffer);
//    glDeleteBuffers(1, &_indexBuffer);
//    glDeleteVertexArraysOES(1, &_VAO);
}

- (void)rebindVAO
{
//    glBindVertexArrayOES(_VAO);
//
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//
//
//    glEnableVertexAttribArray(MLVertexAttribPosition);
//    glVertexAttribPointer(MLVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MLVertex), (void *)offsetof(MLVertex, position));
//
//    glEnableVertexAttribArray(MLVertexAttribNormal);
//    glVertexAttribPointer(MLVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MLVertex), (void *)offsetof(MLVertex, normal));
//
//    glEnableVertexAttribArray(MLVertexAttribTexCoord);
//    glVertexAttribPointer(MLVertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(MLVertex), (void *)offsetof(MLVertex, uv));
//
//    glBindVertexArrayOES(0);
}

#pragma mark - Buffers Filling


- (void)fillWithMeshTransform:(MLMeshTransform *)transform
                positionScale:(simd_float3)positionScale
{
    const int IndexesPerFace = 6;
    
    NSUInteger faceCount = transform.faceCount;
    NSUInteger vertexCount = transform.vertexCount;
    NSUInteger indexCount = faceCount * IndexesPerFace;
    
    [self resizeBuffersToVertexCount:vertexCount indexCount:indexCount];

    [self fillBuffersWithBlock:^(MLVertex *vertexData, MTuint *indexData) {
        for (int i = 0; i < vertexCount; i++) {
            MLMeshVertex meshVertex = [transform vertexAtIndex:i];
            CGPoint uv = meshVertex.from;

            MLVertex vertex;
            vertex.position = simd_make_float3(meshVertex.to.x, meshVertex.to.y, meshVertex.to.z);
            vertex.uv = simd_make_float2(uv.x, 1.0 - uv.y);
            vertex.normal = simd_make_float3(0.0f, 0.0f, 0.0f);
            vertexData[i] = vertex;
        }
        
        for (int i = 0; i < faceCount; i++) {
            MLMeshFace face = [transform faceAtIndex:i];
            simd_float3 weightedFaceNormal = simd_make_float3(0.0f, 0.0f, 0.0f);
            
            // CAMeshTransform seems to be using the following order
            const int Winding[2][3] = {
                {0, 1, 2},
                {2, 3, 0}
            };
            
            simd_float3 vertices[4];
            
            for (int j = 0; j < 4; j++) {
                unsigned int faceIndex = face.indices[j];
                if (faceIndex >= vertexCount) {
                    NSLog(@"Vertex index %u in face %d is out of bounds!", faceIndex, i);
                    return;
                }
                
                vertices[j] = simd_float3_multiply(vertexData[faceIndex].position, positionScale);
            }
            
            for (int triangle = 0; triangle < 2; triangle++) {
                
                int aIndex = face.indices[Winding[triangle][0]];
                int bIndex = face.indices[Winding[triangle][1]];
                int cIndex = face.indices[Winding[triangle][2]];
                
                indexData[IndexesPerFace * i + triangle * 3 + 0] = aIndex;
                indexData[IndexesPerFace * i + triangle * 3 + 1] = bIndex;
                indexData[IndexesPerFace * i + triangle * 3 + 2] = cIndex;
                
                simd_float3 a = vertices[Winding[triangle][0]];
                simd_float3 b = vertices[Winding[triangle][1]];
                simd_float3 c = vertices[Winding[triangle][2]];
                
                simd_float3 ab = simd_float3_subtract(a, b);
                simd_float3 cb = simd_float3_subtract(c, b);
                
                simd_float3 weightedNormal = simd_float3_cross_product(ab, cb);

                weightedFaceNormal = simd_float3_add(weightedFaceNormal, weightedNormal);
            }
            
            // accumulate weighted normal over all faces
            
            for (int i = 0; i < 4; i++) {
                int vertexIndex = face.indices[i];
                vertexData[vertexIndex].normal = simd_float3_add(vertexData[vertexIndex].normal, weightedFaceNormal);
            }
        }
        
        for (int i = 0; i < vertexCount; i++) {

            simd_float3 normal = vertexData[i].normal;
            float length = simd_float3_length(normal);

            if (length > 0.0) {
                vertexData[i].normal = simd_float3_multiply_scalar(normal, 1.0/length);
            }
        }
    }];
    
    
    _indiciesCount = (MTsizei)indexCount;
}

- (void)fillBuffersWithBlock:(void (^)(MLVertex *vertexData, MTuint *indexData))block
{
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    MLVertex *vertexData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
//
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    MTuint *indexData = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
//
//    block(vertexData, indexData);
//
//    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
//    glUnmapBufferOES(GL_ARRAY_BUFFER);
//
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

#pragma mark - Resizing

static inline MTsizeiptr nextPoTForSize(NSUInteger size)
{
    // using a builtin to Count Leading Zeros
    unsigned int bitCount = sizeof(unsigned int) * CHAR_BIT;
    unsigned int log2 = bitCount - __builtin_clz((unsigned int)size);
    MTsizeiptr nextPoT = 1u << log2;

    return nextPoT;
}

- (void)resizeBuffersToVertexCount:(NSUInteger)vertexCount indexCount:(NSUInteger)indexCount
{
    BOOL rebindVAO = NO;

    if (_vertexBufferCapacity < vertexCount) {
        _vertexBufferCapacity = nextPoTForSize(vertexCount);
        [self resizeVertexBufferToCapacity:_vertexBufferCapacity];
        rebindVAO = YES;
    }

    if (_indexBufferCapacity < indexCount) {
        _indexBufferCapacity = nextPoTForSize(indexCount);
        [self resizeIndexBufferToCapacity:_indexBufferCapacity];
        rebindVAO = YES;
    }

    if (rebindVAO) {
        [self rebindVAO];
    }
}


- (void)resizeVertexBufferToCapacity:(MTsizeiptr)capacity
{
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, capacity * sizeof(MLVertex), NULL, GL_DYNAMIC_DRAW);
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)resizeIndexBufferToCapacity:(MTsizeiptr)capacity
{
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, capacity * sizeof(MTuint), NULL, GL_DYNAMIC_DRAW);
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end
