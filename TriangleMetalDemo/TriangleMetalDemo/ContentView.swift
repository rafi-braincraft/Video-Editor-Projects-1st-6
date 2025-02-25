//
//  ContentView.swift
//  TriangleMetalDemo
//
//  Created by Mohammad Noor on 13/11/24.
//

import SwiftUI
import MetalKit

struct ContentView: UIViewRepresentable {

    //a control structure which run render
    func makeCoordinator() -> Renderer {  and updatestaffs
        Renderer(self) //instances of the view
    }
    
    //func to create ui view
    func makeUIView(context: UIViewControllerRepresentableContext<ContentView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<View>) {
        <#code#>
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
