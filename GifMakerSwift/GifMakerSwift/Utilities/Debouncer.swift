//
//  Debouncer.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 11/2/25.
//

import UIKit

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func schedule(_ task: @escaping () -> Void) {
        workItem?.cancel()
        let workItem = DispatchWorkItem(block: task)
        self.workItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
