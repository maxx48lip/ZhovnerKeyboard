//
//  ButtonBuilder.swift
//  ZhovnerKeyboard
//
//  Created by Максим Павлов on 26.08.2025.
//

import UIKit

final class ButtonBuilder {
    
    var shiftButtonState: ShiftButtonState = .shift
    
    private var backspaceTimer: Timer?
    private var insertText: ((String) -> Void) = { _ in }
    private var deleteBackward: (() -> Void) = {}
    
    private var returnPressed: (() -> Void) = {}
    private var handleGlobeButton: (() -> Void) = {}
    private var shiftPressed: ((ShiftButtonState) -> Void) = { _ in }
    private var switchToNumbers: (() -> Void) = {}
    private var switchToSymbols: (() -> Void) = {}
    private var switchToLetters: (() -> Void) = {}
    
    func configure(
        insertText: @escaping (String) -> Void,
        deleteBackward: @escaping () -> Void,
        returnPressed: @escaping (() -> Void),
        handleGlobeButton: @escaping (() -> Void),
        shiftPressed: @escaping ((ShiftButtonState) -> Void),
        switchToNumbers: @escaping (() -> Void),
        switchToSymbols: @escaping () -> Void,
        switchToLetters: @escaping (() -> Void) = {}
        
    ) {
        self.insertText = insertText
        self.deleteBackward = deleteBackward
        self.returnPressed = returnPressed
        self.handleGlobeButton = handleGlobeButton
        self.shiftPressed = shiftPressed
        self.switchToNumbers = switchToNumbers
        self.switchToSymbols = switchToSymbols
        self.switchToLetters = switchToLetters
    }
    
    func makeKeyboardLayout(for state: KeyboardState) -> [[String]] {
        switch state {
        case .englishLetters:
            return Constants.englishKeyboardLayout
        case .russianLetters:
            return Constants.russianKeyboardLayout
        case .numbers:
            return Constants.numbersKeyboardLayout
        case .symbols:
            return Constants.symbolsKeyboardLayout
        }
    }

    func createLeftPunctuationMenuItems() -> PopUpButton.MenuItemsModel {
        let punctuationPairs = [
            (".", ".", "circle.fill"),
            (";", ";", "semicolon"),
            (":", ":", "coloncurrencysign.circle.fill"),
            
        ]
        
        let items: [PopUpButton.MenuItemModel] = punctuationPairs.map { (symbol, title, systemImage) in
            PopUpButton.MenuItemModel(
                title: symbol,
                action: { [weak self] in
                    self?.insertText(symbol)
                }
            )
        }
        return PopUpButton.MenuItemsModel(items: items)
    }
    
    func createRightPunctuationMenuItems() -> PopUpButton.MenuItemsModel {
        let punctuationPairs = [
            ("(", "(", "parenleft"),
            (")", ")", "parenright"),
            ("!", "!", "exclamationmark.circle.fill"),
            
        ]
        
        let items: [PopUpButton.MenuItemModel] = punctuationPairs.map { (symbol, title, systemImage) in
            PopUpButton.MenuItemModel(
                title: symbol,
                action: { [weak self] in
                    self?.insertText(symbol)
                }
            )
        }
        return PopUpButton.MenuItemsModel(items: items)
    }
    
    func configureLetterButton(_ button: PopUpButton, keyboardState: KeyboardState, key: String) {
        button.setTitleColor(.titleButtonColor, for: .normal)
        let changeCaseAction: (String?) -> Void = { [weak self] key in
            guard let self = self else { return }
            switch shiftButtonState {
            case .normal:
                button.setTitle(key?.lowercased(), for: .normal)
            case .shift, .caps:
                button.setTitle(key?.uppercased(), for: .normal)
            }
        }
        
        switch keyboardState {
        case .englishLetters, .numbers, .symbols:
            button.widthAnchor.constraint(equalToConstant: Constants.keyEnglishLetterWidth).isActive = true
        case .russianLetters:
            button.widthAnchor.constraint(equalToConstant: Constants.keyRussianLetterWidth).isActive = true
        }
        
        let menuItems = createMenuItems(for: key, keyboardState: keyboardState)
        
        // Обработка нажатия
        button.configure(
            backgroundColor: .commonButtonColor,
            primaryTitle: key,
            primaryAction: { [weak self] in
                guard let self = self else { return }
                switch shiftButtonState {
                case .normal:
                    insertText(key.lowercased())
                case .shift:
                    insertText(key.uppercased())
                    shiftButtonState = .normal
                    shiftPressed(.normal)
                case .caps:
                    insertText(key.uppercased())
                }
            },
            menuItems: menuItems,
            shiftAction: changeCaseAction
        )
        changeCaseAction(key)
    }
    
    func configureShiftButton(_ button: PopUpButton, keyboardState: KeyboardState) {
        button.setImage(UIImage(systemName: "shift"), for: .normal)
        button.tintColor = .shiftButtonTintColor
        switch keyboardState {
        case .englishLetters, .numbers, .symbols:
            button.widthAnchor.constraint(equalToConstant: Constants.keyShiftWidth).isActive = true
        case .russianLetters:
            button.widthAnchor.constraint(equalToConstant: Constants.keyRussianLetterWidth).isActive = true
        }
        let changeCaseAction: (String?) -> Void = { [weak self] _ in
            guard let self = self else { return }
            switch shiftButtonState {
            case .normal:
                button.setImage(UIImage(systemName: "shift"), for: .normal)
            case .shift:
                button.setImage(UIImage(systemName: "shift.fill"), for: .normal)
            case .caps:
                button.setImage(UIImage(systemName: "capslock.fill"), for: .normal)
                button.tintColor = .white
            }
        }
        button.configure(
            backgroundColor: .shiftButtonColor,
            primaryTitle: nil,
            primaryAction: { [weak self] in
                guard let self else { return }
                triggerShift()
            },
            menuItems: nil,
            shiftAction: changeCaseAction
        )
        changeCaseAction("")
    }
    
    func configureBackspaceButton(_ button: PopUpButton, keyboardState: KeyboardState) {
        button.setImage(UIImage(systemName: "delete.left"), for: .normal)
        button.tintColor = .titleButtonColor
        button.backgroundColor = .specialButtonColor
        
        switch keyboardState {
        case .englishLetters, .numbers, .symbols:
            button.widthAnchor.constraint(equalToConstant: Constants.keyBackspaceWidth).isActive = true
        case .russianLetters:
            button.widthAnchor.constraint(equalToConstant: Constants.keyRussianLetterWidth).isActive = true
        }
        
        button.configure(
            backgroundColor: .specialButtonColor,
            primaryTitle: nil,
            primaryAction: { [weak self] in
                self?.deleteBackward()
            },
            menuItems: nil,
            alternativeLongPressAction: { [weak self] gesture in
                self?.handlDeleteButtonPressed(gesture: gesture)
            }
        )
    }
    
    func configureLettersSwitchButton(_ button: PopUpButton, title: String) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.widthAnchor.constraint(equalToConstant: Constants.key123Width).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.configure(
            backgroundColor: .specialButtonColor,
            primaryTitle: title,
            primaryAction: { [weak self] in
                self?.switchToLetters()
            },
            menuItems: nil
        )
    }
    
    func configureNumberSwitchButton(_ button: PopUpButton, title: String) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.widthAnchor.constraint(equalToConstant: Constants.key123Width).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.configure(
            backgroundColor: .specialButtonColor,
            primaryTitle: title,
            primaryAction: { [weak self] in
                self?.switchToNumbers()
            },
            menuItems: nil
        )
    }
    
    func configureSymbolsSwitchButton(_ button: PopUpButton) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.widthAnchor.constraint(equalToConstant: Constants.keyShiftWidth).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.configure(
            backgroundColor: .specialButtonColor,
            primaryTitle: "#+=",
            primaryAction: { [weak self] in
                self?.switchToSymbols()
            },
            menuItems: nil
        )
    }
    
    func configureGlobeButton(_ button: PopUpButton) {
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.tintColor = .titleButtonColor
        button.widthAnchor.constraint(equalToConstant: Constants.keyGlobeWidth).isActive = true
        button.configure(
            backgroundColor: .specialButtonColor,
            primaryTitle: nil,
            primaryAction: { [weak self] in
                self?.handleGlobeButton()
            },
            menuItems: nil
        )
    }
    
    func configureLeftSpecialSymbolButton(_ button: PopUpButton) {
        button.setTitle(",", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.widthAnchor.constraint(equalToConstant: Constants.keyLeftSpecialSymbolWidth).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.configure(
            backgroundColor: .commonButtonColor,
            primaryTitle: ",",
            primaryAction: { [weak self] in
                self?.insertText(",")
            },
            menuItems: createLeftPunctuationMenuItems()
        )
    }
    
    func configureRightSpecialSymbolButton(_ button: PopUpButton) {
        button.setTitle("?", for: .normal)
        button.widthAnchor.constraint(equalToConstant: Constants.keyRightSpecialSymbolWidth).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.configure(
            backgroundColor: .commonButtonColor,
            primaryTitle: "?",
            primaryAction: { [weak self] in
                self?.insertText("?")
            },
            menuItems: createRightPunctuationMenuItems(),
            preselectedIndex: 2
        )
    }
    
    func configureSpaceButton(_ button: PopUpButton, rowIndex: Int) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.titleButtonColor, for: .normal)
            
//      Критически важные настройки для растягивания
        let spaceWidth = UIScreen.main.bounds.width - Constants.key123Width - Constants.keyGlobeWidth
        - Constants.keyLeftSpecialSymbolWidth - Constants.keyRightSpecialSymbolWidth - Constants.keyReturnWidth - (5 * 6)
        button.widthAnchor.constraint(equalToConstant: spaceWidth).isActive = true
        
        button.configure(
            backgroundColor: .commonButtonColor,
            primaryTitle: "space",
            primaryAction: { [weak self] in
                self?.insertText(" ")
            },
            menuItems: nil
        )
    }
    
    func configureReturnButton(_ button: PopUpButton) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.widthAnchor.constraint(equalToConstant: Constants.keyReturnWidth).isActive = true
        button.setImage(UIImage(systemName: "return"), for: .normal)
        button.tintColor = .titleButtonColor
        button.configure(
            backgroundColor: .specialButtonColor,
            primaryTitle: nil,
            primaryAction: { [weak self] in
                self?.returnPressed()
            },
            menuItems: nil
        )
    }
    
    func updateShiftButtonAppearance(_ button: UIButton, shiftState: ShiftButtonState) {
        switch shiftState {
        case .normal:
            button.setImage(UIImage(systemName: "shift"), for: .normal)
        case .shift:
            button.setImage(UIImage(systemName: "shift.fill"), for: .normal)
        case .caps:
            button.setImage(UIImage(systemName: "capslock.fill"), for: .normal)
            button.tintColor = .white
        }
    }
    
    func triggerShift() {
        let newShiftState: ShiftButtonState = shiftButtonState == .normal ? .shift : .normal
        shiftButtonState = newShiftState
        shiftPressed(shiftButtonState)
    }
    
    private func handlDeleteButtonPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                self.deleteBackward()
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            backspaceTimer?.invalidate()
            backspaceTimer = nil
        }
    }
    
    private func createMenuItems(
        for key: String,
        keyboardState: KeyboardState
    ) -> PopUpButton.MenuItemsModel? {
        var layout: [String: ([String], UIPopoverArrowDirection)]
        
        switch keyboardState {
        case .englishLetters:
            layout = Constants.englishPopUpKeyboardLayout
        case .russianLetters:
            layout = Constants.russianPopUpKeyboardLayout
        case .numbers:
            layout = Constants.numbersPopUpKeyboardLayout
        case .symbols:
            layout = Constants.symbolsPopUpKeyboardLayout
        }
        
        guard let menuItems = layout[key] else { return nil }

        let items: [PopUpButton.MenuItemModel] = menuItems.0.map { symbol in
            PopUpButton.MenuItemModel(
                title: symbol,
                action: { [weak self] in
                    guard let self = self else { return }
                    switch shiftButtonState {
                    case .normal:
                        insertText(symbol.lowercased())
                    case .shift:
                        insertText(symbol.uppercased())
                        shiftButtonState = .normal
                        shiftPressed(.normal)
                    case .caps:
                        insertText(symbol.uppercased())
                    }
                }
            )
        }
        return PopUpButton.MenuItemsModel(items: items, adjustPopOverArrowDirection: menuItems.1)
    }
}
