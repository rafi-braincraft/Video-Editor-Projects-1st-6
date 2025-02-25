//
//  MBEMetalView.m
//  ObjCDemo1
//
//  Created by Mohammad Noor on 24/12/24.
//

#import "MBEMetalView.h"
#import "Metal/Metal.h"
#import "simd/simd.h"

typedef uint16_t MBEIndex;
const MTLIndexType MBEIndexType = MTLIndexTypeUInt16;


// Function declaration
matrix_float4x4 matrix_float4x4_translation(vector_float3 translation);

// Function implementation
matrix_float4x4 matrix_float4x4_translation(vector_float3 translation) {
    // Start with an identity matrix
    matrix_float4x4 matrix = matrix_identity_float4x4;

    // Set the translation components
    matrix.columns[3].x = translation.x;
    matrix.columns[3].y = translation.y;
    matrix.columns[3].z = translation.z;
    matrix.columns[3].w = 1.0; // Ensure homogeneous coordinate

    return matrix;
}

vector_float3 cameraTranslation = {0,0,-5};
//matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

@implementation MBEMetalView {
    // id<MTLDevice> _device;
    CAMetalLayer *_metalLayer;
}

typedef struct {
    vector_float4 position;
    vector_float4 color;
} MBEVertex;

//- (matrix_float4x4) matrix_float4x4_translation: (vector_float3) translation {
//    matrix_float4x4 matrix = matrix_identity_float4x4;
//    
//    matrix.columns[3].x = translation.x;
//    matrix.columns[3].y = translation.y;
//    matrix.columns[3].z = translation.z;
//    matrix.columns[3].w = 1.0;
//    
//    return matrix;
//}

- (void)makeDevice {
    
    _device = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = _device;
    self.metalLayer.pixelFormat = MTLPixelFormatRGBA8Unorm;
}

- (void) makeBuffers {
    static const  MBEVertex vertices[] = {
        { .position = {-0.5, 0.5, 0.5, 1}, .color = {0, 1, 1, 1}},
        { .position = {-0.5, -0.5, 0.5, 1}, .color = {0, 0, 1, 1}},
        { .position = {0.5, -0.5, 0.5, 1}, .color = {1, 0, 1, 1}},
        { .position = {0.5, 0.5, 0.5, 1}, .color = {1, 1, 1, 1}},
        { .position = {-0.5, 0.5, -0.5, 1}, .color = {0, 1, 0, 1}},
        { .position = {-0.5, -0.5, -0.5, 1}, .color = {0, 0, 0, 1}},
        { .position = {0.5, -0.5, -0.5, 1}, .color = {1, 0, 0, 1}},
        { .position = {0.5, 0.5, -0.5, 1}, .color = {1, 1, 0, 1}}
    };
    
    self.vertexBuffer = [ _device newBufferWithBytes: vertices length:sizeof(vertices) options: MTLResourceCPUCacheModeDefaultCache];
    
    const MBEIndex indices[] =
    {
        3,2,6,6,7,3,
        4,5,1,1,0,4,
        4,0,3,3,7,4,
        1,5,6,6,2,1,
        0,1,2,2,3,0,
        7,6,5,5,4,7
        
    };
    
    self.indexBuffer = [device newBufferWithBytes:indices length:sizeof(indices) options:MTLResourceOptionCPUCacheModeDefault];
    
    
}

- (void) makePipeline {
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = vertexFunc;
    pipelineDescriptor.fragmentFunction = fragmentFunc;
    pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;
    
    self.pipeline = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:NULL];
}

- (void)redraw {
    
    // Ensure the Metal device and layer are properly set up
    if (!_device) {
        NSLog(@"Cannot redraw: Metal device is not available.");
        return;
    }
    NSLog(@"Redrawing the Metal view...");
    
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> frameBufferTexure = drawable.texture;
    
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = frameBufferTexure;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1);
    
    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    
    [commandEncoder setRenderPipelineState:self.pipeline];
    [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:8];
    [commandEncoder endEncoding]; //finished encoding
    
    [commandBuffer presentDrawable:drawable]; //drawable is ready
    [commandBuffer commit]; //command buffer is complete ready to go to command queue for execution in the gpu
    
}


+ (id)layerClass
{
    return [CAMetalLayer class];
}

id <MTLDevice> device;

//overloading base calayer by cametallayer
- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

//init for storyboard
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if((self = [super initWithCoder:aDecoder])) {
        [self makeDevice];
        [self makeBuffers];
        [self makePipeline];
    }
    
    return self;
}

- (void)displayLinkDidFire: (CADisplayLink *)displayLink {
    [self redraw];
}

//calls redraw repeatedly
- (void)didMoveToSuperview {
    [super didMoveToSuperview]; // Always call the superclass implementation
    
    if (self.superview) {
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop: [NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        // The view has been removed from the window
        NSLog(@"View removed from superView");
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

@end
