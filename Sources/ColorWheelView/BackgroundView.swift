//
//  BackgroundView.swift
//
//  Created by Roma Kyrylenko on 01.04.2023.
//

import UIKit

final class BackgroundView: UIView {
    
    private let backgroundLayer = CALayer()
    private let backgroundMaskLayer = CAShapeLayer()
    private let backgroundImageLayer = CALayer()
    
    private var cachedInnerRadius: CGFloat = 0
    private var cachedCenter: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    func setColor(color: ColorWheelColor) {
        backgroundLayer.backgroundColor = color.cgColor
    }

    func update(with dimensions: Dimensions) {
        let wheelCenter = dimensions.wheelCenter
        let lastCircleInnerRadius = dimensions.lastCircleInnerRadius + 1
        if wheelCenter == cachedCenter && lastCircleInnerRadius == cachedInnerRadius {
            return
        }
        cachedCenter = wheelCenter
        cachedInnerRadius = lastCircleInnerRadius
        let maskPath = UIBezierPath(
            arcCenter: wheelCenter,
            radius: lastCircleInnerRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        backgroundMaskLayer.path = maskPath.cgPath
        let size = CGSize(width: dimensions.focusInnerRadius, height: dimensions.focusInnerRadius * 90 / 126)
        backgroundImageLayer.frame = CGRect(
            origin: CGPoint(x: wheelCenter.x - dimensions.focusInnerRadius / 2, y: wheelCenter.y - size.height),
            size: size
        )
        backgroundLayer.frame = bounds
    }
    
    private func initialize() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(backgroundImageLayer)
        layer.mask = backgroundMaskLayer
        
        backgroundImageLayer.contents = UIImage(named: "cloudsBackground", in: Bundle(for: ColorWheelView.self), with: nil)?.cgImage
        backgroundImageLayer.contentsGravity = .resizeAspect
        backgroundLayer.opacity = 0.7
    }
}
