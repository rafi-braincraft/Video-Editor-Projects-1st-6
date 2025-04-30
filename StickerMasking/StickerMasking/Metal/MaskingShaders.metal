#include <metal_stdlib>
using namespace metal;

// Structures
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Basic vertex shader for rendering a quad with transform
vertex VertexOut maskingVertexShader(uint vertexID [[vertex_id]],
                                   constant float4 *vertices [[buffer(0)]],
                                   constant float4x4 *transform [[buffer(1)]]) {
    VertexOut out;
    
    // Apply transform for aspect fit
    out.position = (*transform) * vertices[vertexID];
    
    // Map from clip space to texture coordinates
    out.texCoord = float2((vertices[vertexID].x + 1.0) * 0.5,
                         1.0 - (vertices[vertexID].y + 1.0) * 0.5);
    
    return out;
}

// Fragment shader for compositing the background with mask
fragment float4 maskingFragmentShader(VertexOut in [[stage_in]],
                                    texture2d<float> backgroundTexture [[texture(0)]],
                                    texture2d<float> maskTexture [[texture(1)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    // Sample background and mask
    float4 background = backgroundTexture.sample(textureSampler, in.texCoord);
    float4 mask = maskTexture.sample(textureSampler, in.texCoord);
    
    // Apply mask to background
    // - When mask alpha is 1.0, show background fully
    // - When mask alpha is 0.0, make fully transparent
    return float4(background.rgb, background.a * mask.a);
}

// Simple vertex shader for basic rendering
vertex VertexOut basicVertexShader(uint vertexID [[vertex_id]],
                                 constant float4 *vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = vertices[vertexID];
    out.texCoord = float2((vertices[vertexID].x + 1.0) * 0.5,
                         (vertices[vertexID].y + 1.0) * 0.5);
    return out;
}

// Fragment shader for erasing - outputs color with alpha for transparency
fragment float4 eraseFragmentShader(VertexOut in [[stage_in]],
                                  constant float4 *color [[buffer(0)]]) {
    return *color;
}

// Utility kernel function for copying alpha values
kernel void copyAlphaValues(texture2d<float, access::read> sourceTexture [[texture(0)]],
                           texture2d<float, access::write> destinationTexture [[texture(1)]],
                           uint2 gid [[thread_position_in_grid]]) {
    
    // Check bounds
    if (gid.x >= destinationTexture.get_width() || gid.y >= destinationTexture.get_height()) {
        return;
    }
    
    // Read source pixel
    float4 sourceColor = sourceTexture.read(gid);
    float4 destColor = float4(1.0, 1.0, 1.0, sourceColor.a);
    
    // Write to destination with just the alpha component
    destinationTexture.write(destColor, gid);
}
