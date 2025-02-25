//
//#import "TriangleIn2D.h"
//#import "Metal/Metal.h"
//#import "simd/simd.h"
//
//@implementation TriangleIn2D {
//    
//   // id<MTLDevice> _device;
//    CAMetalLayer *_metalLayer;
//}
//
//typedef struct {
//    vector_float4 position;
//    vector_float4 color;
//} MBEVertex;
//
//- (void)makeDevice {
//    
//    _device = MTLCreateSystemDefaultDevice();
//    self.metalLayer.device = _device;
//    self.metalLayer.pixelFormat = MTLPixelFormatRGBA8Unorm;
//}
//
//- (void) makeBuffers {
//    static const  MBEVertex vertices[] = {
//        { .position = {0.0, 0.5, 0, 1}, .color = {1, 0, 0, 1}},
//        { .position = {-0.5, -0.5, 0, 1}, .color = {0, 1, 0, 1}},
//        { .position = {0.5, -0.5, 0, 1}, .color = {0, 0, 1, 1}}
//    };
//    
//    self.vertexBuffer = [ _device newBufferWithBytes: vertices length:sizeof(vertices) options: MTLResourceCPUCacheModeDefaultCache];
//    
//    
//}
//
//- (void) makePipeline {
//    id<MTLLibrary> library = [self.device newDefaultLibrary];
//    
//    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
//    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];
//    
//    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
//    pipelineDescriptor.vertexFunction = vertexFunc;
//    pipelineDescriptor.fragmentFunction = fragmentFunc;
//    pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;
//    
//    self.pipeline = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:NULL];
//}
//
//- (void)redraw {
//    
//    // Ensure the Metal device and layer are properly set up
//    if (!_device) {
//        NSLog(@"Cannot redraw: Metal device is not available.");
//        return;
//    }
//    NSLog(@"Redrawing the Metal view...");
//    
//    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
//    id<MTLTexture> frameBufferTexure = drawable.texture;
//    
//    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
//    passDescriptor.colorAttachments[0].texture = frameBufferTexure;
//    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
//    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
//    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1);
//    
//    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
//    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
//    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
//    
//    [commandEncoder setRenderPipelineState:self.pipeline];
//    [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
//    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
//    [commandEncoder endEncoding]; //finished encoding
//    
//    [commandBuffer presentDrawable:drawable]; //drawable is ready
//    [commandBuffer commit]; //command buffer is complete ready to go to command queue for execution in the gpu
//    
//}
//
//
//+ (id)layerClass
//{
//    return [CAMetalLayer class];
//}
//
//id <MTLDevice> device;
//
////overloading base calayer by cametallayer
//- (CAMetalLayer *)metalLayer {
//    return (CAMetalLayer *)self.layer;
//}
//
////init for storyboard
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    
//    if((self = [super initWithCoder:aDecoder])) {
//        [self makeDevice];
//        [self makeBuffers];
//        [self makePipeline];
//    }
//    
//    return self;
//}
//
//- (void)displayLinkDidFire: (CADisplayLink *)displayLink {
//    [self redraw];
//}
//
////calls redraw repeatedly
//- (void)didMoveToSuperview {
//    [super didMoveToSuperview]; // Always call the superclass implementation
//    
//    if (self.superview) {
//        
//        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
//        [self.displayLink addToRunLoop: [NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//    } else {
//        // The view has been removed from the window
//        NSLog(@"View removed from superView");
//        [self.displayLink invalidate];
//        self.displayLink = nil;
//    }
//}
//
//@end
