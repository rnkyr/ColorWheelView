//
//  CurrentColorView.swift
//
//  Created by Roma Kyrylenko on 30.03.2023.
//

import UIKit

final class CurrentColorView: UIView {
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private(set) var currentSegment: Segment?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
    }
    
    private func setup() {
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    func setSegment(_ segment: Segment) -> Bool {
        if segment.color == currentSegment?.color {
            return false
        }
        currentSegment = segment
        feedbackGenerator.impactOccurred()
        backgroundColor = segment.color.uiColor
        
        return true
    }
}
