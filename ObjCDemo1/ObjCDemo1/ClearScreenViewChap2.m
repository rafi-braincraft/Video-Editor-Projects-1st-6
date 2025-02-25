////
////  ClearScreenViewChap2.m
////  ObjCDemo1
////
////  Created by Mohammad Noor on 29/12/24.
////
//
//#import "ClearScreenViewChap2.h"
//#import "Metal/Metal.h"
//
//@implementation ClearScreenViewChap2 {
//    id<MTLDevice> _device;
//    CAMetalLayer *_metalLayer;
//}
//
//- (void)redraw {
//    // Ensure the Metal device and layer are properly set up
//    if (!_device) {
//        NSLog(@"Cannot redraw: Metal device is not available.");
//        return;
//    }
//    NSLog(@"Redrawing the Metal view...");
//    
//    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
//    id<MTLTexture> texture = drawable.texture;
//    
//    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
//    passDescriptor.colorAttachments[0].texture = texture;
//    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
//    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
//    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 0, 1);
//    
//    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
//    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
//    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
//    
//    [commandEncoder endEncoding]; //finished encoding
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
//        _metalLayer = (CAMetalLayer *)[self layer];
//        _device = MTLCreateSystemDefaultDevice();
//        if (!_device) {
//            NSLog(@"Metal is not supported on this device.");
//            return nil;
//        }
//        
//        _metalLayer.device = _device;
//        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
//        
//    }
//    
//    return self;
//}
//
////calls redraw once
//- (void)didMoveToWindow {
//    [super didMoveToWindow]; // Always call the superclass implementation
//    
//    if (self.window) {
//        // The view has been added to a window
//        [self redraw];
//    } else {
//        // The view has been removed from the window
//        NSLog(@"View removed from window");
//    }
//}
//
//@end
