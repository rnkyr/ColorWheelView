//
//  ViewController.swift
//  Example
//
//  Created by Roma Kyrylenko on 02.04.2023.
//

import UIKit
//import ColorWheelView

class ViewController: UIViewController {
    
//    private var colorWheelView: ColorWheelView!
//    private var selectColorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width: CGFloat = UIScreen.main.bounds.width - 50
        let height: CGFloat = width / 2
        let frame = CGRect(
            x: (UIScreen.main.bounds.width - width) / 2,
            y: (UIScreen.main.bounds.height - height) / 2,
            width: width,
            height: height
        )
        
//        colorWheelView = ColorWheelView(frame: frame)
//        colorWheelView.layer.borderWidth = 1
//        view.addSubview(colorWheelView)
//
//        selectColorButton = UIButton(type: .system)
//        selectColorButton.setTitle("Select random color", for: [])
//        selectColorButton.frame = CGRect(
//            x: frame.midX - 100,
//            y: frame.minY - 200,
//            width: 200,
//            height: 44
//        )
//        selectColorButton.addTarget(self, action: #selector(selectRandomColor), for: .primaryActionTriggered)
//        view.addSubview(selectColorButton)
    }
    
    @objc
    private func selectRandomColor() {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
        let brightness: CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
        let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        
//        colorWheelView.select(color: .init(color))
//        selectColorButton.backgroundColor = color
    }
}
