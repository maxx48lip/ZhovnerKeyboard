//
//  Constants.swift
//  ZhovnerKeyboardExtTarget
//
//  Created by Максим Павлов on 21.08.2025.
//

import UIKit

private var proxy : UITextDocumentProxy!

final class KeyboardViewController: UIInputViewController {

    private var shiftButton = UIButton()
    
    private var keys: [UIButton] = []
    private var paddingViews: [UIButton] = []
    private var backspaceTimer: Timer?
    
    private var keyboardState: KeyboardState = .letters
    private var shiftButtonState: ShiftButtonState = .shift
    
    private var mainStackView: UIStackView!
    private var keyRows: [UIStackView] = []
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proxy = textDocumentProxy as UITextDocumentProxy
        setupKeyboard()
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
    
    private func setupKeyboard() {
            createMainStackView()
            createKeyboardRows()
        }
    
    private func createMainStackView() {
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
    
    private func createKeyboardRows() {
        let keyboardLayout = [
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
            ["shift", "z", "x", "c", "v", "b", "n", "m", "backspace"],
            ["123", "globe", "specialSymbolLeft","space", "specialSymbolRight", "return"]
        ]
        
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
        }
        
        return rowStack
    }

    private func createLeftPunctuationMenuItems() -> [UIAction] {
        let punctuationPairs = [
            (".", ".", "circle.fill"),
            (";", ";", "semicolon"),
            (":", ":", "coloncurrencysign.circle.fill"),
            
        ]
        
        return punctuationPairs.map { (symbol, title, systemImage) in
            UIAction(
                title: title,
                image: UIImage(systemName: systemImage),
                handler: { [weak self] _ in
                    self?.insertText(symbol)
                }
            )
        }
    }
    
    private func createRightPunctuationMenuItems() -> [UIAction] {
        let punctuationPairs = [
            ("(", "(", "parenleft"),
            (")", ")", "parenright"),
            ("!", "!", "exclamationmark.circle.fill"),
            
        ]
        
        return punctuationPairs.map { (symbol, title, systemImage) in
            UIAction(
                title: title,
                image: UIImage(systemName: systemImage),
                handler: { [weak self] _ in
                    self?.insertText(symbol)
                }
            )
        }
    }
    
    func loadKeys(){
        keys.forEach{$0.removeFromSuperview()}
        paddingViews.forEach{$0.removeFromSuperview()}
            
        //let buttonWidth = (UIScreen.main.bounds.width - 6) / CGFloat(Constants.letterKeys[0].count)
        let buttonWidth: CGFloat = 32
            
        var keyboard: [[String]]
            
            //start padding
        switch keyboardState {
        case .letters:
            keyboard = Constants.letterKeys
        case .numbers:
            keyboard = Constants.numberKeys
        case .symbols:
            keyboard = Constants.symbolKeys
        }
            
        let numRows = keyboard.count

        for row in 0...numRows - 1 {
            for col in 0...keyboard[row].count - 1 {
                let button = PopUpButton(type: .custom)
                let key = keyboard[row][col]
                let capsKey = keyboard[row][col].capitalized
                let keyToDisplay = shiftButtonState == .normal ? key : capsKey
                button.layer.setValue(key, forKey: "original")
                button.layer.setValue(keyToDisplay, forKey: "keyToDisplay")
                button.layer.setValue(false, forKey: "isSpecial")
                button.setTitle(keyToDisplay, for: .normal)
                button.addTarget(self, action: #selector(keyPressedTouchUp), for: .touchUpInside)
                button.addTarget(self, action: #selector(keyTouchDown), for: .touchDown)
                button.addTarget(self, action: #selector(keyUntouched), for: .touchDragExit)
                button.addTarget(self, action: #selector(keyMultiPress(_:event:)), for: .touchDownRepeat)

                if key == "⌫"{
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(keyLongPressed(_:)))
                    button.addGestureRecognizer(longPressRecognizer)
                }
                
                keys.append(button)
                
                //top row is longest row so it should decide button width
//                print("button width: ", buttonWidth)
                if key == "⌫" || key == "↩" || key == "#+=" || key == "ABC" || key == "123" || key == "⬆️" || key == "🌐"{
                    button.widthAnchor.constraint(equalToConstant: buttonWidth + buttonWidth/2).isActive = true
                    button.layer.setValue(true, forKey: "isSpecial")
                    button.backgroundColor = Constants.specialKeyNormalColour
                    if key == "⬆️" {
                        if shiftButtonState != .normal{
                            button.backgroundColor = Constants.keyPressedColour
                        }
                        if shiftButtonState == .caps{
                            button.setTitle("⏫", for: .normal)
                        }
                    }
                } else if (keyboardState == .numbers || keyboardState == .symbols) && row == 2 {
                    button.widthAnchor.constraint(equalToConstant: buttonWidth * 1.4).isActive = true
                } else if key != "space" {
                    button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
                } else {
                    button.layer.setValue(key, forKey: "original")
                    button.setTitle(key, for: .normal)
                }
                button.heightAnchor.constraint(equalToConstant: 42).isActive = true
            }
        }
    }
}

extension KeyboardViewController {
    func changeKeyboardToNumberKeys(){
        keyboardState = .numbers
        shiftButtonState = .normal
        loadKeys()
    }
    
    func changeKeyboardToLetterKeys(){
        keyboardState = .letters
        loadKeys()
    }
    func changeKeyboardToSymbolKeys(){
        keyboardState = .symbols
        loadKeys()
    }
    @objc func handlDeleteButtonPressed(){
        proxy.deleteBackward()
    }
    
    private func insertText(_ text: String) {
            textDocumentProxy.insertText(text)
        }
    
    @objc func keyPressedTouchUp(_ sender: UIButton) {
            guard let originalKey = sender.layer.value(forKey: "original") as? String, let keyToDisplay = sender.layer.value(forKey: "keyToDisplay") as? String else {return}
            
            guard let isSpecial = sender.layer.value(forKey: "isSpecial") as? Bool else {return}
            sender.backgroundColor = isSpecial ? Constants.specialKeyNormalColour : Constants.keyNormalColour

            switch originalKey {
            case "⌫":
                if shiftButtonState == .shift {
                    shiftButtonState = .normal
                    loadKeys()
                }
                handlDeleteButtonPressed()
            case "space":
                proxy.insertText(" ")
            case "🌐":
                break
            case "↩":
                proxy.insertText("\n")
            case "123":
                changeKeyboardToNumberKeys()
            case "ABC":
                changeKeyboardToLetterKeys()
            case "#+=":
                changeKeyboardToSymbolKeys()
            case "⬆️":
                shiftButtonState = shiftButtonState == .normal ? .shift : .normal
                loadKeys()
            default:
                if shiftButtonState == .shift {
                    shiftButtonState = .normal
                    loadKeys()
                }
                proxy.insertText(keyToDisplay)
            }
        }
        
        @objc func keyMultiPress(_ sender: UIButton, event: UIEvent){
            guard let originalKey = sender.layer.value(forKey: "original") as? String else {return}

            let touch: UITouch = event.allTouches!.first!
            if (touch.tapCount == 2 && originalKey == "⬆️") {
                shiftButtonState = .caps
                loadKeys()
            }
        }
        
        @objc func keyLongPressed(_ gesture: UIGestureRecognizer){
            if gesture.state == .began {
                backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                    self.handlDeleteButtonPressed()
                }
            } else if gesture.state == .ended || gesture.state == .cancelled {
                backspaceTimer?.invalidate()
                backspaceTimer = nil
                (gesture.view as! UIButton).backgroundColor = Constants.specialKeyNormalColour
            }
        }
        
        @objc func keyUntouched(_ sender: UIButton){
            guard let isSpecial = sender.layer.value(forKey: "isSpecial") as? Bool else {return}
            sender.backgroundColor = isSpecial ? Constants.specialKeyNormalColour : Constants.keyNormalColour
        }
        
        @objc func keyTouchDown(_ sender: UIButton){
            sender.backgroundColor = Constants.keyPressedColour
        }
}

// MARK: - Создание кнопок
extension KeyboardViewController {
    private func createKeyButton(for key: String, rowIndex: Int) -> UIButton {
        let button = PopUpButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Базовая настройка
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.layer.cornerRadius = 5
        
        // Настройка в зависимости от типа кнопки
        switch key {
        case "shift":
            shiftButton = button
            configureShiftButton(button)
            updateShiftButtonAppearance(button, shiftState: shiftButtonState)
        case "backspace":
            configureBackspaceButton(button)
        case "123":
            configureNumberSwitchButton(button)
        case "globe":
            configureGlobeButton(button)
        case "specialSymbolLeft":
            configureLeftSpecialSymbolButton(button)
        case "specialSymbolRight":
            configureRightSpecialSymbolButton(button)
        case "space":
            configureSpaceButton(button, rowIndex: rowIndex)
        case "return":
            configureReturnButton(button)
        default:
            configureLetterButton(button, key: key.uppercased())
        }
        
        // Constraints для единообразия
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        return button
    }
    
    private func configureLetterButton(_ button: UIButton, key: String) {
        button.backgroundColor = .commonButtonColor
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.setTitle(key.uppercased(), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        // Обработка нажатия
        button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
    }
    
    private func configureShiftButton(_ button: UIButton) {
        button.setImage(UIImage(systemName: "shift"), for: .normal)
        button.backgroundColor = .shiftButtonColor
        button.tintColor = .shiftButtonTintColor
        button.widthAnchor.constraint(equalToConstant: Constants.keyShiftWidth).isActive = true
        button.addTarget(self, action: #selector(shiftPressed), for: .touchUpInside)
    }
    
    private func configureBackspaceButton(_ button: UIButton) {
        button.setImage(UIImage(systemName: "delete.left"), for: .normal)
        button.tintColor = .titleButtonColor
        button.widthAnchor.constraint(equalToConstant: Constants.keyBackspaceWidth).isActive = true
        button.backgroundColor = .specialButtonColor
        
        button.addTarget(self, action: #selector (handlDeleteButtonPressed), for: .touchUpInside)
        
        // Долгое нажатие для непрерывного удаления
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleBackspaceLongPress))
        button.addGestureRecognizer(longPress)
    }
    
    private func configureNumberSwitchButton(_ button: UIButton) {
        button.setTitle("123", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.widthAnchor.constraint(equalToConstant: Constants.key123Width).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.backgroundColor = .specialButtonColor
        button.addTarget(self, action: #selector(switchToNumbers), for: .touchUpInside)
    }
    
    private func configureGlobeButton(_ button: UIButton) {
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.tintColor = .titleButtonColor
        button.backgroundColor = .specialButtonColor
        button.widthAnchor.constraint(equalToConstant: Constants.keyGlobeWidth).isActive = true
        button.addTarget(self, action: #selector(handleGlobeButton), for: .touchUpInside)
    }
    
    private func configureLeftSpecialSymbolButton(_ button: PopUpButton) {
        button.setTitle(",", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.widthAnchor.constraint(equalToConstant: Constants.keyLeftSpecialSymbolWidth).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.backgroundColor = .commonButtonColor
        button.configure(
            primaryTitle: ",",
            primaryAction: { [weak self] in
                self?.insertText(",")
            },
            menuItems: createLeftPunctuationMenuItems()
        )
//        button.addTarget(self, action: #selector(switchToNumbers), for: .touchUpInside)
    }
    
    private func configureRightSpecialSymbolButton(_ button: PopUpButton) {
        button.setTitle("?", for: .normal)
        button.widthAnchor.constraint(equalToConstant: Constants.keyRightSpecialSymbolWidth).isActive = true
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.backgroundColor = .commonButtonColor
        button.configure(
            primaryTitle: "?",
            primaryAction: { [weak self] in
                self?.insertText("?")
            },
            menuItems: createRightPunctuationMenuItems()
        )
//        button.addTarget(self, action: #selector(switchToNumbers), for: .touchUpInside)
    }
    
    private func configureSpaceButton(_ button: UIButton, rowIndex: Int) {
        button.setTitle("space", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.backgroundColor = .commonButtonColor
            
//      Критически важные настройки для растягивания
        let spaceWidth = UIScreen.main.bounds.width - Constants.key123Width - Constants.keyGlobeWidth
        - Constants.keyLeftSpecialSymbolWidth - Constants.keyRightSpecialSymbolWidth - Constants.keyReturnWidth - (5 * 6)
        button.widthAnchor.constraint(equalToConstant: spaceWidth).isActive = true
    }
    
    private func configureReturnButton(_ button: UIButton) {
        button.setTitle("return", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .specialButtonColor
        button.setTitleColor(.titleButtonColor, for: .normal)
        button.widthAnchor.constraint(equalToConstant: Constants.keyReturnWidth).isActive = true
        button.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
    }
    
    private func updateShiftButtonAppearance(_ button: UIButton, shiftState: ShiftButtonState) {
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
}

// MARK: - Обработка нажатий
extension KeyboardViewController {
    @objc private func keyPressed(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text?.uppercased() else { return }
        
        // Тактильная обратная связь
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Вставка текста
        textDocumentProxy.insertText(key)
    }
    
    @objc private func shiftPressed(_ sender: UIButton) {
        // Переключение между регистрами
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        toggleShift()
    }
    
    @objc private func handleBackspaceLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startContinuousBackspace()
        case .ended, .cancelled:
            stopContinuousBackspace()
        default:
            break
        }
    }
    
    @objc private func switchToNumbers(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // Логика переключения на цифровую клавиатуру
    }
    
    @objc private func handleGlobeButton(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        advanceToNextInputMode()
    }
    
    @objc private func returnPressed(_ sender: UIButton) {
        textDocumentProxy.insertText("\n")
    }
    
    private func startContinuousBackspace() {
        backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            self.handlDeleteButtonPressed()
        }
    }
    
    private func stopContinuousBackspace() {
        backspaceTimer?.invalidate()
        backspaceTimer = nil
    }
    
    private func toggleShift() {
        shiftButtonState = shiftButtonState == .normal ? .shift : .normal
        updateShiftButtonAppearance(shiftButton, shiftState: shiftButtonState)
    }
}
