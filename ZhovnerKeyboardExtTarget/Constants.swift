//
//  Constants.swift
//  ZhovnerKeyboardExtTarget
//
//  Created by Максим Павлов on 21.08.2025.
//

import Foundation
import UIKit

enum Constants {
    
    static let keyNormalColour: UIColor = .white
    static let keyPressedColour: UIColor = .lightText
    static let specialKeyNormalColour: UIColor = .gray

    static let letterKeys = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g","h", "j", "k", "l"],
        ["⬆", "z", "x", "c", "v", "b", "n", "m", "⌫"],
        ["123", "🌐", "space", "↩"]
    ]
    static let numberKeys = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",],
        ["-", "/", ":", ";", "(", ")" ,",", "$", "&", "@", "\""],
        ["#+=",".", ",", "?", "!", "\'", "⌫"],
        ["ABC", "🌐", "space", "↩"]
    ]
    
    static let symbolKeys = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "·"],
        ["123",".", ",", "?", "!", "\'", "⌫"],
        [SpecialKey.abc.rawValue, SpecialKey.globus.rawValue, SpecialKey.space.rawValue, SpecialKey.returnKey.rawValue]
        //["ABC", "🌐", "space", "↩"]
    ]
}

enum SpecialKey: String {
    case shift = "⬆"
    case backspace = "⌫"
    case oneTwoThree = "123"
    case abc = "ABC"
    case globus = "🌐"
    case space = "space"
    case returnKey = "↩"
}
