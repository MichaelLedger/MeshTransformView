//
//  MLMeshMetalRenderer.swift
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/29.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

import Foundation
import MetalKit

//struct Vertex {
//    var positon: SIMD2<Float> = simd_make_float2(0, 0)
//}

@objcMembers class MLMeshMetalRenderer : NSObject {
    @objc class func createMTKMesh(vertices: Array<NSValue>, indices: Array<NSNumber>) -> MTKMesh?  {
        let device = MTLCreateSystemDefaultDevice()!
        let allocator = MTKMeshBufferAllocator(device: device)
        
        let vertexBuffer = allocator.newBuffer(MemoryLayout<MLVertex>.stride * vertices.count, type: .vertex)
        let vertexMap = vertexBuffer.map()
        
        let vertexArr = NSMutableArray(capacity: vertices.count)
        for i in vertices {
//            var v: MLVertex?
//            i.getValue(&v)
            
            var vm: MLVertextModel?
            i.getValue(&vm)
            
            if (vm != nil) {
                let v: MLVertex = MLVertex(position: vm!.position, normal: vm!.normal, uv: vm!.uv)
                vertexArr.add(v)
            }
        }
        vertexMap.bytes.assumingMemoryBound(to: MLVertex.self).assign(from: vertexArr as! Array<MLVertex>, count: vertices.count)

        let indexBuffer = allocator.newBuffer(MemoryLayout<UInt16>.stride * indices.count, type: .index)
        let indexMap = indexBuffer.map()
        let indexIntArr = NSMutableArray(capacity: indices.count)
        for i in indices { indexIntArr.add(i.uint16Value) }
        indexMap.bytes.assumingMemoryBound(to: UInt16.self).assign(from: indexIntArr as! Array<UInt16>, count: indices.count)

        let submesh = MDLSubmesh(indexBuffer: indexBuffer,
                                 indexCount: indices.count,
                                 indexType: .uInt16,
                                 geometryType: .triangles,
                                 material: nil)

        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float2,
                                                            offset: 0,
                                                            bufferIndex: 0)
        let mdlMesh = MDLMesh(vertexBuffer: vertexBuffer,
                              vertexCount: vertices.count,
                              descriptor: vertexDescriptor,
                              submeshes: [submesh])

        let mesh = try? MTKMesh(mesh: mdlMesh, device: device)
        return mesh
    }
}
