//
//  MBEMetalView.h
//  ObjCDemo1
//
//  Created by Mohammad Noor on 24/12/24.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>


NS_ASSUME_NONNULL_BEGIN

@interface MBEMetalView : UIView

@property (readonly) CAMetalLayer *metalLayer;
@property (readonly) id<MTLDevice> device;

@property (nonatomic, nullable) id<MTLBuffer> vertexBuffer;
@property (nonatomic, nullable) id<MTLBuffer> indexBuffer;
@property (nonatomic, nullable) id<MTLRenderPipelineState> pipeline;
@property (nonatomic, nullable) CADisplayLink *displayLink;


@end

NS_ASSUME_NONNULL_END
