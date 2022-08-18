//
//  mtktypes.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/18.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

#ifndef mtktypes_h
#define mtktypes_h

#include <stdint.h>

typedef uint32_t MTbitfield;
typedef uint8_t  MTboolean;
typedef int8_t   MTbyte;
typedef float    MTclampf;
typedef uint32_t MTenum;
typedef float    MTfloat;
typedef int32_t  MTint;
typedef int16_t  MTshort;
typedef int32_t  MTsizei;
typedef uint8_t  MTubyte;
typedef uint32_t MTuint;
typedef uint16_t MTushort;
typedef void     MTvoid;

#if !defined(MT_ES_VERSION_2_0)
typedef char     MTchar;
#endif
typedef int32_t  MTclampx;
typedef int32_t  MTfixed;
#if !defined(MT_ES_VERSION_3_0)
typedef uint16_t MThalf;
#endif
#if !defined(MT_APPLE_sync) && !defined(MT_ES_VERSION_3_0)
typedef int64_t  MTint64;
typedef struct __MTsync *MTsync;
typedef uint64_t MTuint64;
#endif
typedef intptr_t MTintptr;
typedef intptr_t MTsizeiptr;


#endif /* mtktypes_h */
