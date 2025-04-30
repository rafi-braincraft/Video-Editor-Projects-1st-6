import UIKit
import Metal
import MetalKit
import simd

// MARK: - MetalMaskingView
class MetalMaskingView: UIView {
    enum Mode {
        case erase
        case restore
    }
    
    // MARK: - Properties
    private var metalDevice: MTLDevice!
    private var metalCommandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var metalLayer: CAMetalLayer!
    private var backgroundTexture: MTLTexture?
    private var maskTexture: MTLTexture?
    private var renderPassDescriptor: MTLRenderPassDescriptor!
    private var vertexBuffer: MTLBuffer!
    private var previousTouchLocation: CGPoint?
    private var strokePoints: [CGPoint] = []
    private var shouldRedraw = false
    private var isFirstTime = true
    
    // Image scaling properties
    private var imageAspectRatio: CGFloat = 1.0
    private var imageTransform = simd_float4x4(1.0)
    
    var eraserWidth: Float = 20.0
    var currentMode: Mode = .erase
    var backgroundImage: UIImage? {
        didSet {
            if let image = backgroundImage {
                // Calculate aspect ratio for proper scaling
                imageAspectRatio = image.size.width / image.size.height
                updateImageTransform()
                
                createTextureFromImage(image, completion: { texture in
                    self.backgroundTexture = texture
                    self.setNeedsDisplay()
                })
            }
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMetal()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMetal()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFirstTime {
            isFirstTime = false
            metalLayer.frame = bounds
            updateDrawableSize()
            createInitialMaskTexture()
        } else {
            updateImageTransform()
            metalLayer.frame = bounds
            updateDrawableSize()
        }
    }
    
    // MARK: - Setup
    private func setupMetal() {
        // Make view background clear to allow transparency to show through
        backgroundColor = .clear
        isOpaque = false
        
        // Get default device
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        metalDevice = device
        
        // Create command queue
        guard let queue = metalDevice.makeCommandQueue() else {
            fatalError("Could not create command queue")
        }
        metalCommandQueue = queue
        
        // Setup Metal layer
        metalLayer = CAMetalLayer()
        metalLayer.device = metalDevice
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = bounds
        metalLayer.isOpaque = false // Allow transparency
        layer.addSublayer(metalLayer)
        
        // Create shader functions
        setupShaders()
        
        // Create render pass descriptor
        renderPassDescriptor = MTLRenderPassDescriptor()
        
        // Create vertex buffer for a quad
        createVertexBuffer()
    }
    
    private func setupShaders() {
        // Load shader library from default bundle
        guard let library = metalDevice.makeDefaultLibrary() else {
            fatalError("Could not create default Metal library")
        }
        
        // Get vertex and fragment functions
        guard let vertexFunction = library.makeFunction(name: "maskingVertexShader"),
              let fragmentFunction = library.makeFunction(name: "maskingFragmentShader") else {
            fatalError("Could not create shader functions")
        }
        
        // Create render pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        
        // Enable alpha blending for transparency
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Create pipeline state
        do {
            pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error.localizedDescription)")
        }
    }
    
    private func createVertexBuffer() {
        // Quad vertices for normalized device coordinates
        let vertices: [Float] = [
            -1.0, -1.0, 0.0, 1.0,  // bottom-left
             1.0, -1.0, 0.0, 1.0,  // bottom-right
            -1.0,  1.0, 0.0, 1.0,  // top-left
             1.0,  1.0, 0.0, 1.0   // top-right
        ]
        
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Float>.stride,
                                             options: .storageModeShared)
    }
    
    private func updateImageTransform() {
        // Calculate aspect fit scaling
        let viewAspectRatio = bounds.width / bounds.height
        
        var scaleX: Float = 1.0
        var scaleY: Float = 1.0
        
        if imageAspectRatio > viewAspectRatio {
            // Image is wider than view - constrain by width
            scaleX = 1.0
            scaleY = Float(viewAspectRatio / imageAspectRatio)
        } else {
            // Image is taller than view - constrain by height
            scaleX = Float(imageAspectRatio / viewAspectRatio)
            scaleY = 1.0
        }
        
        // Create scale matrix
        var transform = simd_float4x4(1.0)
        transform.columns.0.x = scaleX
        transform.columns.1.y = scaleY
        
        imageTransform = transform
    }
    
    private func updateDrawableSize() {
        let scale = window?.screen.nativeScale ?? UIScreen.main.scale
        let layerSize = bounds.size
        
        metalLayer.drawableSize = CGSize(width: layerSize.width * scale,
                                         height: layerSize.height * scale)
    }
    
    private func createInitialMaskTexture() {
        let width = Int(metalLayer.drawableSize.width)
        let height = Int(metalLayer.drawableSize.height)
        
        // Create a texture for the mask
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let texture = metalDevice.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Failed to create mask texture")
        }
        
        // Fill with white (fully opaque) color for initial state (255, 255, 255, 255)
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                               size: MTLSize(width: width, height: height, depth: 1))
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let length = bytesPerRow * height
        
        var whiteBuffer = [UInt8](repeating: 255, count: length)
        
        texture.replace(region: region,
                       mipmapLevel: 0,
                       withBytes: whiteBuffer,
                       bytesPerRow: bytesPerRow)
        
        maskTexture = texture
    }
    
    // MARK: - Texture Creation
    private func createTextureFromImage(_ image: UIImage, completion: @escaping (MTLTexture?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let cgImage = image.cgImage else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let width = cgImage.width
            let height = cgImage.height
            
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: width,
                height: height,
                mipmapped: false
            )
            textureDescriptor.usage = [.shaderRead]
            
            guard let texture = self.metalDevice.makeTexture(descriptor: textureDescriptor) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            
            guard let context = CGContext(data: nil,
                                         width: width,
                                         height: height,
                                         bitsPerComponent: 8,
                                         bytesPerRow: bytesPerRow,
                                         space: colorSpace,
                                         bitmapInfo: bitmapInfo) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Flip coordinate system
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            
            // Draw image
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                                  size: MTLSize(width: width, height: height, depth: 1))
            
            if let data = context.data {
                texture.replace(region: region,
                              mipmapLevel: 0,
                              withBytes: data,
                              bytesPerRow: bytesPerRow)
            }
            
            DispatchQueue.main.async {
                completion(texture)
            }
        }
    }
    
    // MARK: - Drawing
    func render() {
        guard let currentDrawable = metalLayer.nextDrawable(),
              let backgroundTexture = backgroundTexture,
              let maskTexture = maskTexture else {
            return
        }
        
        // Setup render pass descriptor with clear color for transparency
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Create command buffer
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else { return }
        
        // Create render command encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Set render pipeline state
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Set vertex buffer
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Set image transform for aspect fit
        var transform = imageTransform
        renderEncoder.setVertexBytes(&transform, length: MemoryLayout<simd_float4x4>.stride, index: 1)
        
        // Set textures for the fragment shader
        renderEncoder.setFragmentTexture(backgroundTexture, index: 0)
        renderEncoder.setFragmentTexture(maskTexture, index: 1)
        
        // Draw quad
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        // End encoding
        renderEncoder.endEncoding()
        
        // Present drawable
        commandBuffer.present(currentDrawable)
        
        // Commit
        commandBuffer.commit()
    }
    
    func drawStroke() {
        guard let maskTexture = maskTexture, strokePoints.count >= 2 else { return }
        
        // Create command buffer
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
        
        // Create a temporary texture for stroke rendering
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: maskTexture.width,
            height: maskTexture.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        textureDescriptor.storageMode = .private
        
        guard let strokeTexture = metalDevice.makeTexture(descriptor: textureDescriptor) else {
            blitEncoder.endEncoding()
            return
        }
        
        // Copy current mask to stroke texture to preserve existing content
        blitEncoder.copy(from: maskTexture,
                        sourceSlice: 0,
                        sourceLevel: 0,
                        sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                        sourceSize: MTLSize(width: maskTexture.width, height: maskTexture.height, depth: 1),
                        to: strokeTexture,
                        destinationSlice: 0,
                        destinationLevel: 0,
                        destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        
        // Create render pass descriptor for stroke texture
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = strokeTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Create a render command encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Create pipeline state for stroke rendering
        guard let library = metalDevice.makeDefaultLibrary() else {
            renderEncoder.endEncoding()
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Stroke Pipeline"
        
        // For stroke rendering we'll use a simple shader
        guard let vertexFunction = library.makeFunction(name: "basicVertexShader"),
              let fragmentFunction = library.makeFunction(name: "eraseFragmentShader") else {
            renderEncoder.endEncoding()
            return
        }
        
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = strokeTexture.pixelFormat
        
        // Set up blending for erasing/restoring
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        if currentMode == .erase {
            // Erasing: Use alpha blending to make transparent
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .subtract
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
        } else {
            // Restoring: Use alpha blending to make opaque
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
        }
        
        do {
            let pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
            renderEncoder.setRenderPipelineState(pipelineState)
            
            // Draw each segment of the stroke
            for i in 0..<(strokePoints.count - 1) {
                let startPoint = strokePoints[i]
                let endPoint = strokePoints[i + 1]
                
                // Calculate perpendicular vector to create line width
                let dx = endPoint.x - startPoint.x
                let dy = endPoint.y - startPoint.y
                let length = hypot(dx, dy)
                
                // Skip if points are too close
                if length < 0.001 { continue }
                
                // Normalize and perpendicular vector
                let nx = CGFloat(dy) / length
                let ny = CGFloat(-dx) / length
                
                // Line width
                let halfWidth = CGFloat(eraserWidth) / 2.0
                
                // Break down coordinate calculations for better compiler performance
                // First point
                let x1 = startPoint.x - nx * halfWidth
                let y1 = startPoint.y - ny * halfWidth
                let x1Norm = Float((x1 / bounds.width) * 2 - 1)
                let y1Norm = Float(((y1 / bounds.height) * 2 - 1) * -1)
                
                // Second point
                let x2 = startPoint.x + nx * halfWidth
                let y2 = startPoint.y + ny * halfWidth
                let x2Norm = Float((x2 / bounds.width) * 2 - 1)
                let y2Norm = Float(((y2 / bounds.height) * 2 - 1) * -1)
                
                // Third point
                let x3 = endPoint.x - nx * halfWidth
                let y3 = endPoint.y - ny * halfWidth
                let x3Norm = Float((x3 / bounds.width) * 2 - 1)
                let y3Norm = Float(((y3 / bounds.height) * 2 - 1) * -1)
                
                // Fourth point
                let x4 = endPoint.x + nx * halfWidth
                let y4 = endPoint.y + ny * halfWidth
                let x4Norm = Float((x4 / bounds.width) * 2 - 1)
                let y4Norm = Float(((y4 / bounds.height) * 2 - 1) * -1)
                
                // Assemble vertices for two triangles (quad)
                let vertices: [Float] = [
                    x1Norm, y1Norm, 0.0, 1.0,
                    x2Norm, y2Norm, 0.0, 1.0,
                    x3Norm, y3Norm, 0.0, 1.0,
                    
                    x2Norm, y2Norm, 0.0, 1.0,
                    x3Norm, y3Norm, 0.0, 1.0,
                    x4Norm, y4Norm, 0.0, 1.0
                ]
                
                // Create vertex buffer
                let vertexBuffer = metalDevice.makeBuffer(bytes: vertices,
                                                        length: vertices.count * MemoryLayout<Float>.stride,
                                                        options: .storageModeShared)
                
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                
                // Set color based on mode
                var color: [Float] = currentMode == .erase ? [0.0, 0.0, 0.0, 1.0] : [1.0, 1.0, 1.0, 1.0]
                renderEncoder.setFragmentBytes(&color, length: MemoryLayout<Float>.stride * 4, index: 0)
                
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            }
            
            renderEncoder.endEncoding()
            
            // Copy the result back to the mask texture
            guard let finalBlitEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
            finalBlitEncoder.copy(from: strokeTexture,
                                 sourceSlice: 0,
                                 sourceLevel: 0,
                                 sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                                 sourceSize: MTLSize(width: maskTexture.width, height: maskTexture.height, depth: 1),
                                 to: maskTexture,
                                 destinationSlice: 0,
                                 destinationLevel: 0,
                                 destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
            finalBlitEncoder.endEncoding()
            
            // Commit the command buffer
            commandBuffer.commit()
            
            // Clear the stroke points
            strokePoints.removeAll()
            
            // Render after completion
            commandBuffer.addCompletedHandler { _ in
                DispatchQueue.main.async {
                    self.render()
                }
            }
            
        } catch {
            print("Failed to create pipeline state: \(error)")
            renderEncoder.endEncoding()
        }
    }
    
    // MARK: - Public Methods
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            strokePoints = [location]
            previousTouchLocation = location
            
        case .changed:
            // Interpolate between previous point and current point
            if let previousLocation = previousTouchLocation {
                // Add intermediate points to ensure smooth stroke
                let distance = hypot(location.x - previousLocation.x, location.y - previousLocation.y)
                let numberOfPoints = max(1, Int(distance / 5)) // One point every 5 pixels
                
                if numberOfPoints > 1 {
                    for i in 1...numberOfPoints {
                        let ratio = CGFloat(i) / CGFloat(numberOfPoints)
                        let x = previousLocation.x + (location.x - previousLocation.x) * ratio
                        let y = previousLocation.y + (location.y - previousLocation.y) * ratio
                        strokePoints.append(CGPoint(x: x, y: y))
                    }
                } else {
                    strokePoints.append(location)
                }
            }
            
            previousTouchLocation = location
            
            // Only draw if we have enough points
            if strokePoints.count >= 2 {
                drawStroke()
            }
            
        case .ended, .cancelled:
            strokePoints.append(location)
            
            // Only draw if we have enough points
            if strokePoints.count >= 2 {
                drawStroke()
            }
            
            previousTouchLocation = nil
            
        default:
            break
        }
    }
    
    func resetMask() {
        createInitialMaskTexture()
        render()
    }
    
    func updateBackgroundImage(_ image: UIImage) {
        backgroundImage = image
    }
}
