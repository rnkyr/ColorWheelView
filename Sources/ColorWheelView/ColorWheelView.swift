//
//  ColorWheelView.swift
//
//  Created by Roma Kyrylenko on 30.03.2023.
//

import UIKit

public final class ColorWheelView: UIView {
    
    private let contentLayer = CALayer()
    private let currentColorView = CurrentColorView()
    private let backgroundView = BackgroundView()
    private let dimensions = Dimensions()
    
    public var didChangeColor: ((ColorWheelColor) -> Void)?
    public var currentColor: ColorWheelColor { currentColorView.currentSegment!.color }
    
    override public var intrinsicContentSize: CGSize { CGSize(width: bounds.width, height: bounds.width / 2) }
    
    private var gestureDirection: UIPanGestureRecognizer.Direction?
    private var segments: [Segment] = []
    private lazy var dynamicAnimator = UIDynamicAnimator(referenceView: self)
    private lazy var decelerationItem = DynamicItem()
    private var animationInterpolator: Interpolator?
    private var isDecelerating: Bool = false
    private var dynamicAnimatorObservation: Any?
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.require(toFail: panGestureRecognizer)
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
        clipsToBounds = true
        dynamicAnimator.delegate = self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if currentColorView.superview == nil {
            addSubview(backgroundView)
            layer.addSublayer(contentLayer)
            addSubview(currentColorView)
        }
        if segments.isEmpty {
            assignSegments()
        }
        if dimensions.update(bounds: bounds) {
            contentLayer.frame = bounds
            currentColorView.frame = dimensions.currentColorViewFrame
            backgroundView.frame = bounds
            backgroundView.update(with: dimensions)
            updateSegments()
            checkCurrentColor()
        }
    }
    
    // MARK: - Public
    
    public func select(color: ColorWheelColor) {
        var nearestSegment: Segment = segments.first!
        var minDiff: CGFloat = color.diff(from: nearestSegment.color)
        segments.dropFirst(1).forEach { segment in
            let diff = color.diff(from: segment.color)
            if diff < minDiff {
                minDiff = diff
                nearestSegment = segment
            }
        }
        select(segment: nearestSegment)
    }
    
    // MARK: - Drawing
    
    private func assignSegments() {
        for j in 0..<dimensions.circlesCount {
            for i in 0..<dimensions.segmentsCount {
                let segment = Segment(
                    segmentIndex: i,
                    circleIndex: j,
                    color: Colors.default[i][j],
                    dimensions: dimensions
                )
                segments.append(segment)
                contentLayer.addSublayer(segment.shapeLayer)
            }
        }
    }
    
    private func updateSegments() {
        segments.forEach {
            $0.updatePath(dimensions)
        }
        backgroundView.update(with: dimensions)
    }
    
    // MARK: - Internals
    
    private func checkCurrentColor(_ segment: Segment? = nil) {
        let selectedSegment: Segment
        if let segment = segment {
            selectedSegment = segment
        } else {
            guard let segment = self.segment(at: currentColorView.center, onCircle: false) else {
                return
            }
            
            selectedSegment = segment
        }
        
        if currentColorView.setSegment(selectedSegment) {
            backgroundView.setColor(color: selectedSegment.color)
            didChangeColor?(selectedSegment.color)
        }
    }
    
    private func segment(at point: CGPoint, onCircle: Bool) -> Segment? {
        return segments.first(where: { segment in
            if currentColorView.currentSegment == nil || !onCircle {
                return segment.path.contains(point)
            }
            
            return segment.circleIndex == currentColorView.currentSegment?.circleIndex && segment.path.contains(point)
        })
    }
    
    private func select(segment: Segment) {
        let translation = dimensions.center(on: segment)
        if translation.x == nil && translation.y == nil {
            return
        }
        animationInterpolator = .init(
            fromValue: dimensions.translation,
            toValue: translation,
            duration: 0.3,
            timingFunction: .easeInOut,
            onApply: { [weak self] translation in
                if self?.dimensions.update(translation: translation) == true {
                    self?.updateSegments()
                    self?.checkCurrentColor()
                }
            }
        )
        animationInterpolator?.start()
    }
    
    // MARK: - Interactions
    
    @objc
    private func handleTapGesture(_ tapGestureRecognizer: UITapGestureRecognizer) {
        switch tapGestureRecognizer.state {
        case .ended: break
        default: return
        }
        
        if let segment = self.segment(at: tapGestureRecognizer.location(in: self), onCircle: true) {
            select(segment: segment)
        }
    }
    
    @objc
    private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .possible:
            return
            
        case .began:
            isDecelerating = false
            dynamicAnimator.removeAllBehaviors()
            gestureDirection = gestureRecognizer.direction
            
        case .ended, .cancelled, .failed:
            switch gestureDirection {
            case .horizontal: decelerate(gestureRecognizer.velocity(in: self))
            case .vertical: didEndScrolling()
            default: break
            }
            
        case .changed:
            let translation = gestureRecognizer.translation(in: self)
            gestureRecognizer.setTranslation(.zero, in: self)
            let hasChanges: Bool
            switch gestureDirection {
            case .horizontal: hasChanges = dimensions.increment(translation: .init(x: translation.x, y: 0))
            case .vertical: hasChanges = dimensions.increment(translation: .init(x: 0, y: translation.y))
            case .none: return
            }
            
            if hasChanges {
                updateSegments()
                checkCurrentColor()
            }
            
        @unknown default:
            return
        }
    }
    
    private func decelerate(_ velocity: CGPoint) {
        if abs(velocity.x) < 50 {
            didEndScrolling()
            return
        }
        isDecelerating = true
        let removeVerticalVelocity = CGPoint(x: velocity.x, y: 0)
        decelerationItem.center = dimensions.translation
        let decelerationBehavior = UIDynamicItemBehavior(items: [decelerationItem])
        decelerationBehavior.resistance = 4
        decelerationBehavior.addLinearVelocity(removeVerticalVelocity, for: decelerationItem)
        decelerationBehavior.action = { [weak self] in
            guard let self = self else {
                return
            }
           
            if self.dimensions.update(translation: self.decelerationItem.center) {
                self.updateSegments()
                self.checkCurrentColor()
            }
        }
        dynamicAnimator.addBehavior(decelerationBehavior)
    }
    
    private func didEndScrolling() {
        if let segment = currentColorView.currentSegment {
            select(segment: segment)
        }
    }
}

extension ColorWheelView: UIDynamicAnimatorDelegate {
    
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if isDecelerating && !animator.isRunning {
            isDecelerating = false
            didEndScrolling()
        }
    }
}

fileprivate extension UIPanGestureRecognizer {
    
    enum Direction: String {
        
        case vertical, horizontal
    }
    
    var direction: Direction {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        return isVertical ? .vertical : .horizontal
    }
}

private final class DynamicItem: NSObject, UIDynamicItem {
    
    var center = CGPoint.zero
    let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
    var transform = CGAffineTransform.identity
}
