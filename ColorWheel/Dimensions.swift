//
//  Dimensions.swift
//
//  Created by Roma Kyrylenko on 31.03.2023.
//

import Foundation

final class Dimensions {
    
    let circlesCount: Int = 7
    let segmentsCount: Int = 33
    
    private let verticalMovementCoefficient: CGFloat = 30 * CGFloat.pi
    private let horizontalMovementCoefficient: CGFloat = 3 * CGFloat.pi
    
    var outerRadius: CGFloat { bounds.width * 0.65 }
    var innerRadius: CGFloat { outerRadius * 0.2 }
    var singleCircleHeight: CGFloat { (outerRadius - innerRadius) / CGFloat(circlesCount) }
    var contentHeight: CGFloat { 2 * singleCircleHeight }
    var wheelCenter: CGPoint { CGPoint(x: bounds.midX, y: bounds.maxY) }
    var currentColorViewFrame: CGRect {
        let size = CGSize(width: min(contentHeight * 0.75, 33), height: min(contentHeight * 0.75, 33))
        
        return CGRect(
            origin: .init(
                x: wheelCenter.x - size.width / 2,
                y: wheelCenter.y - (innerRadius + (outerRadius + innerRadius) / 2) + size.height
            ),
            size: size
        )
    }
    var focusOuterRadius: CGFloat { innerRadius + (outerRadius - innerRadius) / 2 + contentHeight / 2 }
    var focusInnerRadius: CGFloat { innerRadius + (outerRadius - innerRadius) / 2 - contentHeight / 2 }
    
    lazy var singleSegmentAngle: CGFloat = 2 * CGFloat.pi / CGFloat(segmentsCount)
    lazy var initialHorizontalOffset: CGFloat = -CGFloat.pi / 2 - singleSegmentAngle / 2
    
    var lastCircleInnerRadius: CGFloat = 0
    
    private(set) var horizontalOffset: CGFloat = 0 // in radians
    private(set) var verticalOffset: CGFloat = 0 // in pixels
    private(set) var translation: CGPoint = .zero
    private var bounds: CGRect = .zero
    
    func update(bounds: CGRect) -> Bool {
        if self.bounds == bounds {
            return false
        }
        self.bounds = bounds
        updateVerticalOffset(translation.y)
        updateHorizontalOffset()
        
        return true
    }
    
    func increment(translation: CGPoint) -> Bool {
        if translation.x != 0 {
            self.translation.x += translation.x
            updateHorizontalOffset()
            
            return true
        } else if translation.y != 0 {
            if let newOffset = updateVerticalOffset(translation.y + self.translation.y) {
                self.translation.y = newOffset
                
                return true
            }
            
            return false
        }
        
        return false
    }
    
    func update(translation: Translation) -> Bool {
        var xUpdated = false
        var yUpdated = false
        if let x = translation.x {
            self.translation.x = x
            updateHorizontalOffset()
            xUpdated = true
        }
        if let y = translation.y, let newTranslationY = updateVerticalOffset(y) {
            self.translation.y = newTranslationY
            yUpdated = true
        }
        
        return xUpdated || yUpdated
    }
    
    func update(translation: CGPoint) -> Bool {
        if translation.x != 0 {
            self.translation.x = translation.x
            updateHorizontalOffset()
            
            return true
        } else if translation.y != 0 {
            if let newTranslationY = updateVerticalOffset(translation.y) {
                self.translation.y = newTranslationY
                
                return true
            }
            
            return false
        }
        
        return false
    }
    
    func center(on segment: Segment) -> Translation {
        var horizotanllyUpdated = false
        var verticallyUpdated = false
        var translation: CGPoint = .zero
        
        var horizontalOffset: CGFloat
        if segment.angle > 0 {
            horizontalOffset = 2 * CGFloat.pi - singleSegmentAngle * CGFloat(segment.segmentIndex)
        } else {
            horizontalOffset = -singleSegmentAngle * CGFloat(segment.segmentIndex)
        }
        let loops: CGFloat = CGFloat(Int(segment.angle / (CGFloat.pi * 2))) * CGFloat.pi * 2
        horizontalOffset += loops
        let newTranslationX = translationX(for: horizontalOffset)
        if newTranslationX != self.translation.x {
            horizotanllyUpdated = true
            translation.x = newTranslationX
            updateHorizontalOffset()
        }
        
        let verticalOffset = focusOuterRadius - segment.outerRadius - (segment.outerRadius - segment.innerRadius) / 2 + verticalOffset
        let newTranslationY = translationY(for: verticalOffset)
        if let newOffset = updateVerticalOffset(newTranslationY) {
            verticallyUpdated = true
            translation.y = newOffset
        }
        
        return Translation(
            x: horizotanllyUpdated ? translation.x : nil,
            y: verticallyUpdated ? translation.y : nil
        )
    }
    
    @discardableResult
    private func updateVerticalOffset(_ translationY: CGFloat) -> CGFloat? {
        let newVerticalOffset = verticalOffset(for: translationY)
        let lowerBound = focusOuterRadius - outerRadius - contentHeight / 4
        let upperBound = focusInnerRadius - innerRadius + contentHeight / 4
        let verticalOffset = max(lowerBound, min(upperBound, newVerticalOffset))
        if self.verticalOffset == verticalOffset {
            return nil
        }
        self.verticalOffset = verticalOffset
        
        return translationY
    }
    
    private func updateHorizontalOffset() {
        horizontalOffset = horizontalOffset(for: translation.x)
    }
    
    private func verticalOffset(for translationY: CGFloat) -> CGFloat {
        return -translationY / bounds.height * verticalMovementCoefficient
    }
    
    private func translationY(for verticalOffset: CGFloat) -> CGFloat {
        return -verticalOffset * bounds.height / verticalMovementCoefficient
    }
    
    private func horizontalOffset(for translationX: CGFloat) -> CGFloat {
        return translationX / bounds.width * horizontalMovementCoefficient
    }
    
    private func translationX(for horizontalOffset: CGFloat) -> CGFloat {
        return horizontalOffset * bounds.width / horizontalMovementCoefficient
    }
}

struct Translation {
    
    let x: CGFloat?
    let y: CGFloat?
}
