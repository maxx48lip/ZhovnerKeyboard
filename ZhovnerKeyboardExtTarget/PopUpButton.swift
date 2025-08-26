//
//  PopUpButton.swift
//  ZhovnerKeyboardExtTarget
//
//  Created by Максим Павлов on 21.08.2025.
//

import UIKit

final class PopUpButton: UIButton {
    private var primaryAction: (() -> Void)?
    private var menuItems: [UIAction] = []
    private var editMenuInteraction: UIEditMenuInteraction?
    private var preselectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        addKeyboardButtonAnimations()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        addKeyboardButtonAnimations()
        setupShadow()
    }
    
    // Обновляем shadowPath при изменении layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    private func setupButton() {
        // Настройка внешнего вида
        layer.cornerRadius = 5
        
        // Добавляем обработчики жестов
        addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        
        // Настройка UIEditMenuInteraction
        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        addInteraction(editMenuInteraction!)
        
        // Долгое нажатие для меню
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.3
        addGestureRecognizer(longPress)
    }
    
    func configure(
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        menuItems: [UIAction]
    ) {
        setTitle(primaryTitle, for: .normal)
        self.primaryAction = primaryAction
        self.menuItems = menuItems
        addKeyboardButtonAnimations()
        setupShadow()
    }
    
    @objc private func primaryTap() {
        primaryAction?()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        showEditMenu()
    }
    
    private func showEditMenu() {
        guard let interaction = editMenuInteraction, menuItems != [] else { return }
        
        let configuration = UIEditMenuConfiguration(
            identifier: nil,
            sourcePoint: CGPoint(x: bounds.midX, y: bounds.midY)
        )
        
        interaction.presentEditMenu(with: configuration)
    }
    
    // Метод для получения меню
    private func createEditMenu() -> UIMenu {
        return UIMenu(title: "", children: menuItems)
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.masksToBounds = false
    }
    
    struct PopUpButtonViewModel {
        let primaryTitle: String
        let isSpecialKey: Bool
        let primaryAction: () -> Void
    }
}

// MARK: - UIEditMenuInteractionDelegate

extension PopUpButton: UIEditMenuInteractionDelegate {
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        guard menuItems != [] else { return nil }
        let menu = createEditMenu()
        
        return menu
    }
}

// Тактильная обратная связь как в iOS
extension PopUpButton {
    private func provideHapticFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

extension PopUpButton {
    func addKeyboardButtonAnimations() {
        removeTarget(nil, action: nil, for: .allEvents)

        addTarget(self, action: #selector(keyboardTouchDown), for: [.touchDown, .touchDragInside])
        addTarget(self, action: #selector(keyboardTouchUp), for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchCancel])
    }
    
    @objc private func keyboardTouchDown() {
        UIView.animate(withDuration: 0.1,
                      delay: 0,
                      options: [.curveEaseOut, .allowUserInteraction],
                      animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.7)
        })

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func keyboardTouchUp() {
        UIView.animate(withDuration: 0.15,
                      delay: 0,
                      options: [.curveEaseOut, .allowUserInteraction],
                      animations: {
            self.transform = .identity
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
        })
    }
}
