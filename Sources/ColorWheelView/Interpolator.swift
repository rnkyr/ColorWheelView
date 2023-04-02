//
//  Interpolator.swift
//
//  Created by Roma Kyrylenko on 02.04.2023.
//

import Foundation
import QuartzCore

final class Interpolator {
    
    private let fromValue: CGPoint
    private let toValue: Translation
    private let duration: CGFloat
    private let onApply: (Translation) -> Void
    private let timingFunction: TimingFunction
    
    private var displayLink: CADisplayLink?
    private var progress: CGFloat = 0
    
    init(
        fromValue: CGPoint,
        toValue: Translation,
        duration: CGFloat,
        timingFunction: TimingFunction,
        onApply: @escaping (Translation) -> Void
    ) {
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = timingFunction
        self.onApply = onApply
    }
    
    deinit {
        stop()
    }
    
    func start() {
        stop()
        progress = 0
        triggerCallback()
        displayLink = CADisplayLink(target: self, selector: #selector(progressValues))
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    func stop() {
        displayLink?.invalidate()
    }
    
    @objc
    private func progressValues() {
        progress += 1 / (duration * 60)
        if progress >= 1 {
            progress = 1
            stop()
        }
        triggerCallback()
    }
    
    private func triggerCallback() {
        let progress = max(min(progress, 1), 0)
        var x: CGFloat?
        if let toX = toValue.x {
            x = fromValue.x + (toX - fromValue.x) * progress
        }
        var y: CGFloat?
        if let toY = toValue.y {
            y = fromValue.y + (toY - fromValue.y) * progress
        }
        onApply(Translation(x: x, y: y))
    }
}

enum TimingFunction {
    
    case linear, easeIn, easeOut, easeInOut
    
    func apply(_ progress: CGFloat) -> CGFloat {
        switch self {
        case .linear: return progress
        case .easeIn: return progress * progress * progress
        case .easeOut: return (progress - 1) * (progress - 1) * (progress - 1) + 1.0
        case .easeInOut:
            if progress < 0.5 {
                return 4.0 * progress * progress * progress
            } else {
                let adjustment = (2 * progress - 2)
                
                return 0.5 * adjustment * adjustment * adjustment + 1.0
            }
        }
    }
}
