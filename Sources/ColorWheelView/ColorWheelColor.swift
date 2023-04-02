//
//  ColorWheelColor.swift
//
//  Created by Roma Kyrylenko on 31.03.2023.
//

import UIKit

public final class ColorWheelColor: Equatable {
    
    public static func == (lhs: ColorWheelColor, rhs: ColorWheelColor) -> Bool {
        return lhs.uint32 == rhs.uint32
    }
    
    public let uiColor: UIColor
    let cgColor: CGColor
    private let uint32: UInt32
    
    public init(_ uiColor: UIColor) {
        self.uiColor = uiColor
        cgColor = uiColor.cgColor
        uint32 = uiColor.int32Value()
    }
    
    public convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
    
    func diff(from color: ColorWheelColor) -> CGFloat {
        if self == color {
            return 0
        }
        
        let currentComponents = cgColor.components()
        let diffColorComponents = color.cgColor.components()
        
        return currentComponents.diff(with: diffColorComponents)
    }
}

private struct ColorComponents {
    
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    func diff(with components: ColorComponents) -> CGFloat {
        let rDiff = abs(red - components.red)
        let gDiff = abs(green - components.green)
        let bDiff = abs(blue - components.blue)
        
        return (rDiff + gDiff + bDiff) / 3
    }
}

private extension CGColor {
    
    func components() -> ColorComponents {
        guard let components = components else {
            return .init(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if numberOfComponents == 2 {
            return .init(red: components[0], green: components[0], blue: components[0], alpha: components[1])
        }
        
        return .init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

private extension UIColor {
    
    func int32Value() -> UInt32 {
        let model = cgColor.colorSpace?.model
        var r, g, b, a: UInt8
        
        if model == .monochrome {
            var white: CGFloat = 0
            var alpha: CGFloat = 0
            self.getWhite(&white, alpha: &alpha)
            r = UInt8(white * 255)
            g = UInt8(white * 255)
            b = UInt8(white * 255)
            a = UInt8(alpha * 255)
        } else if model == .rgb {
            var rr: CGFloat = 0
            var gg: CGFloat = 0
            var bb: CGFloat = 0
            var aa: CGFloat = 0
            self.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
            r = UInt8(rr * 255)
            g = UInt8(gg * 255)
            b = UInt8(bb * 255)
            a = UInt8(aa * 255)
        } else {
            r = 0
            g = 0
            b = 0
            a = 0
        }
        
        var total = (UInt32(a) << 24)
        total += (UInt32(r) << 16)
        total += (UInt32(g) << 8)
        total += UInt32(b)
        
        return total
    }
}
