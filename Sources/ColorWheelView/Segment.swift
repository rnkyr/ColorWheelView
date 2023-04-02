//
//  Segment.swift
//
//  Created by Roma Kyrylenko on 30.03.2023.
//

import UIKit

final class Segment {

    let segmentIndex: Int
    let circleIndex: Int
    let color: ColorWheelColor
    let shapeLayer: CAShapeLayer

    private(set) var path: UIBezierPath!
    private(set) var angle: CGFloat = 0
    private(set) var outerRadius: CGFloat = 0
    private(set) var innerRadius: CGFloat = 0
    
    init(
        segmentIndex: Int,
        circleIndex: Int,
        color: ColorWheelColor,
        dimensions: Dimensions
    ) {
        self.segmentIndex = segmentIndex
        self.circleIndex = circleIndex
        self.color = color
        
        self.shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = color.uiColor.cgColor
        updatePath(dimensions)
    }
    
    // MARK: - Path
    
    func updatePath(_ dimensions: Dimensions) {
        let segmentAngle = dimensions.singleSegmentAngle
        angle = dimensions.initialHorizontalOffset + dimensions.horizontalOffset + segmentAngle * CGFloat(segmentIndex)
        
        var segmentOuterRadius = dimensions.verticalOffset + dimensions.outerRadius - CGFloat(circleIndex) * dimensions.singleCircleHeight
        segmentOuterRadius = max(dimensions.focusInnerRadius, min(segmentOuterRadius, dimensions.focusOuterRadius))
        var segmentInnerRadius = segmentOuterRadius - dimensions.singleCircleHeight
        segmentInnerRadius = min(dimensions.focusOuterRadius, max(segmentInnerRadius, dimensions.focusInnerRadius))
        if circleIndex == dimensions.circlesCount - 1 {
            dimensions.lastCircleInnerRadius = segmentInnerRadius
        }
        outerRadius = segmentOuterRadius
        innerRadius = segmentInnerRadius
        
        let segmentPath = UIBezierPath()
        segmentPath.addArc(
            withCenter: dimensions.wheelCenter,
            radius: segmentOuterRadius,
            startAngle: angle,
            endAngle: angle + segmentAngle,
            clockwise: true
        )
        segmentPath.addArc(
            withCenter: dimensions.wheelCenter,
            radius: segmentInnerRadius,
            startAngle: angle + segmentAngle,
            endAngle: angle,
            clockwise: false
        )
        segmentPath.close()
        shapeLayer.path = segmentPath.cgPath
        path = segmentPath
    }
}
