//
//  UIColor+Extension.swift
//  ZhovnerKeyboard
//
//  Created by Максим Павлов on 26.08.2025.
//

import UIKit

extension UIColor {
    static var keyboardBackgroundColor: UIColor {
        let currentTheme = UITraitCollection.current.userInterfaceStyle
        switch currentTheme {
        case .unspecified:
            return UIColor.hexStringToUIColor(hex: "#caced4")
        case .light:
            return UIColor.hexStringToUIColor(hex: "#caced4")
        case .dark:
            return UIColor.hexStringToUIColor(hex: "#caced4")
        @unknown default:
            return UIColor.hexStringToUIColor(hex: "#caced4")
        }
    }
    
    static var specialButtonColor: UIColor {
        let currentTheme = UITraitCollection.current.userInterfaceStyle
        switch currentTheme {
        case .unspecified:
            return UIColor.hexStringToUIColor(hex: "#a0a6b1")
        case .light:
            return UIColor.hexStringToUIColor(hex: "#a0a6b1")
        case .dark:
            return UIColor.hexStringToUIColor(hex: "#464646")
        @unknown default:
            return UIColor.hexStringToUIColor(hex: "#a0a6b1")
        }
    }
    
    static var shiftButtonColor: UIColor {
        let currentTheme = UITraitCollection.current.userInterfaceStyle
        switch currentTheme {
        case .unspecified:
            return UIColor.white
        case .light:
            return UIColor.white
        case .dark:
            return UIColor.hexStringToUIColor(hex: "#d5d5d5")
        @unknown default:
            return UIColor.white
        }
    }
    
    static var shiftButtonTintColor: UIColor {
        let currentTheme = UITraitCollection.current.userInterfaceStyle
        switch currentTheme {
        case .unspecified:
            return UIColor.black
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.black
        @unknown default:
            return UIColor.black
        }
    }
    
    static var commonButtonColor: UIColor {
        let currentTheme = UITraitCollection.current.userInterfaceStyle
        switch currentTheme {
        case .unspecified:
            return UIColor.white
        case .light:
            return UIColor.white
        case .dark:
            return UIColor.hexStringToUIColor(hex: "#6a6a6a")
        @unknown default:
            return UIColor.white
        }
    }
    
    static var titleButtonColor: UIColor {
        let currentTheme = UITraitCollection.current.userInterfaceStyle
        switch currentTheme {
        case .unspecified:
            return UIColor.black
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        @unknown default:
            return UIColor.black
        }
    }
}

extension UIColor {
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
