//
//  ImmediatePanGestureRecogniser.swift
//  StickerMasking
//
//  Created by BCL Device 5 on 9/4/25.
//
import UIKit

class ImmediatePanGestureRecogniser : UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
}
