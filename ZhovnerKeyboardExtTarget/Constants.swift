//
//  Constants.swift
//  ZhovnerKeyboardExtTarget
//
//  Created by Максим Павлов on 21.08.2025.
//

import Foundation
import UIKit

enum Constants {
    static let key123Width: CGFloat = 45
    static let keyGlobeWidth: CGFloat = 40
    static let keyShiftWidth: CGFloat = 45
    static let keyBackspaceWidth: CGFloat = 45
    static let keyReturnWidth: CGFloat = 55
    static let keyLeftSpecialSymbolWidth: CGFloat = 28
    static let keyRightSpecialSymbolWidth: CGFloat = 28
    
    static let keyEnglishLetterWidth: CGFloat = 32
    static let keyRussianLetterWidth: CGFloat = 28
    
    static let russianKeyboardLayout: [[String]] = [
        ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"],
        ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
        ["shift", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "backspace"],
        ["123", "globe", "specialSymbolLeft", "space", "specialSymbolRight", "return"]
    ]
    
    static let englishKeyboardLayout: [[String]] = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["shift", "z", "x", "c", "v", "b", "n", "m", "backspace"],
        ["123", "globe", "specialSymbolLeft", "space", "specialSymbolRight", "return"]
    ]
    
    static let numbersKeyboardLayout: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "₽", "&", "@", "\""],
        ["#+=", ".", ",", "?", "!", "'", "«", "»", "backspace"],
        ["ABC", "globe", "specialSymbolLeft", "space", "specialSymbolRight", "return"]
    ]
    
    static let symbolsKeyboardLayout: [[String]] = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "$", "€", "£", "•"],
        ["123", ".", ",", "?", "!", "'", "«", "»", "backspace"],
        ["ABC", "globe", "specialSymbolLeft", "space", "specialSymbolRight", "return"]
    ]
    
    static let englishPopUpKeyboardLayout: [String: ([String], UIPopoverArrowDirection)] = [:]
    
    static let russianPopUpKeyboardLayout: [String: ([String], UIPopoverArrowDirection)] = [
        "ь": (["ь", "ъ"], .down),
        "е": (["е", "ё"], .up),
    ]
    
    static let numbersPopUpKeyboardLayout: [String: ([String], UIPopoverArrowDirection)] = [
        "-": (["–", "—", "•"], .up),
        "/": (["/", "\\"], .up),
        "₽": (["¥", "£", "€", "$", "₽"], .up),
        "&": (["&", "§"], .up),
        "\"": (["„", "“", "”", "\""], .up),
        ".": ([".", "…"], .down),
        "?": (["?", "¿"], .down),
        "!": (["!", "¡"], .down),
        "'": (["`", "‘", "’", "’"], .down)
    ]
    
    static let symbolsPopUpKeyboardLayout: [String: ([String], UIPopoverArrowDirection)] = [
        "#": (["#", "№"], .up),
        "%": (["%", "‰"], .up),
        "=": (["≈", "≠", "="], .up),
        ".": ([".", "…"], .down),
        "?": (["?", "¿"], .down),
        "!": (["!", "¡"], .down),
        "'": (["`", "‘", "’", "’"], .down)
        ]
}
