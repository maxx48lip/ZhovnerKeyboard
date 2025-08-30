//
//  Constants.swift
//  ZhovnerKeyboardExtTarget
//
//  Created by Максим Павлов on 21.08.2025.
//

import UIKit

final class KeyboardViewController: UIInputViewController {
    
    private var keysButtons: [PopUpButton] = []
    private var keyboardState: KeyboardState = .englishLetters
    private var lettersKeyboard: KeyboardState = .englishLetters

    private var mainStackView: UIStackView = UIStackView()
    private var keyRows: [UIStackView] = []
    private let buttonsBuilder = ButtonBuilder()
    
    private var lastPressedKey: String?
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonsBuilder()
        setupKeyboard(for: keyboardState)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let heightConstraint = NSLayoutConstraint(
            item: view!,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1.0,
            constant: 220
        )
        view.addConstraint(heightConstraint)
    }
    
    private func setupButtonsBuilder() {
        buttonsBuilder.configure(
            insertText: { [weak self] text in
                guard let self = self else { return }
                if lastPressedKey == "." && text == " " {
                    self.buttonsBuilder.triggerShift()
                }
                self.lastPressedKey = text
                self.textDocumentProxy.insertText(text)
            },
            deleteBackward: { [weak self] in
                self?.lastPressedKey = nil
                self?.textDocumentProxy.deleteBackward()
            },
            returnPressed: { [weak self] in
                self?.textDocumentProxy.insertText("\n")
                self?.buttonsBuilder.triggerShift()
            },
            handleGlobeButton: { [weak self] in
                guard let self = self else { return }
                self.keyboardState = keyboardState == .englishLetters ? .russianLetters : .englishLetters
                self.lettersKeyboard = keyboardState
                setupKeyboard(for: keyboardState)
            },
            shiftPressed: { [weak self] shiftState in
                self?.keysButtons.forEach { $0.shiftStateChangeCalled() }
            },
            switchToNumbers: { [weak self] in
                guard let self = self else { return }
                keyboardState = .numbers
                setupKeyboard(for: keyboardState)
            },
            switchToSymbols: { [weak self] in
                guard let self = self else { return }
                keyboardState = keyboardState == .numbers ? .symbols : .numbers
                setupKeyboard(for: keyboardState)
            },
            switchToLetters: { [weak self] in
                guard let self = self else { return }
                keyboardState = lettersKeyboard
                setupKeyboard(for: keyboardState)
            }
        )
    }

    private func setupKeyboard(for keyboardState: KeyboardState) {
        reCreateMainStackView()
        createKeyboardRows(for: keyboardState)
    }
    
    private func reCreateMainStackView() {
        mainStackView.removeFromSuperview()
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .center
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }
    
    private func createKeyboardRows(for keyboardState: KeyboardState) {
        keyRows = []
        let keyboardLayout = buttonsBuilder.makeKeyboardLayout(for: keyboardState)
        
        for (index, rowKeys) in keyboardLayout.enumerated() {
            let rowStack = createKeyboardRow(for: rowKeys, rowIndex: index)
            mainStackView.addArrangedSubview(rowStack)
            keyRows.append(rowStack)
        }
    }
    
    private func createKeyboardRow(for keys: [String], rowIndex: Int) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.distribution = .fill
        rowStack.alignment = .center
        rowStack.spacing = 6
        
        for key in keys {
            let button = createKeyButton(for: key, rowIndex: rowIndex)
            rowStack.addArrangedSubview(button)
            keysButtons.append(button)
        }
        
        return rowStack
    }
}

extension KeyboardViewController {
    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
}

// MARK: - Создание кнопок
extension KeyboardViewController {
    private func createKeyButton(for key: String, rowIndex: Int) -> PopUpButton {
        let button = PopUpButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Базовая настройка
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.layer.cornerRadius = 5
        
        // Настройка в зависимости от типа кнопки
        switch key {
        case "shift":
            buttonsBuilder.configureShiftButton(button, keyboardState: keyboardState)
        case "backspace":
            buttonsBuilder.configureBackspaceButton(button, keyboardState: keyboardState)
        case "123":
            buttonsBuilder.configureNumberSwitchButton(button, title: key)
        case "ABC", "АБВ":
            buttonsBuilder.configureLettersSwitchButton(button, title: key)
        case "#+=":
            buttonsBuilder.configureSymbolsSwitchButton(button)
        case "globe":
            buttonsBuilder.configureGlobeButton(button)
        case "specialSymbolLeft":
            buttonsBuilder.configureLeftSpecialSymbolButton(button)
        case "specialSymbolRight":
            buttonsBuilder.configureRightSpecialSymbolButton(button)
        case "space":
            buttonsBuilder.configureSpaceButton(button, rowIndex: rowIndex)
        case "return":
            buttonsBuilder.configureReturnButton(button)
        default:
            buttonsBuilder.configureLetterButton(button, keyboardState: keyboardState, key: key)
        }
        
        // Constraints для единообразия
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        return button
    }
}
