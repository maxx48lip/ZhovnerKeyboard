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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Настройка внешнего вида
        backgroundColor = Constants.keyNormalColour
        setTitleColor(.black, for: .normal)
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
        return createEditMenu()
    }
    
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        willPresentMenuFor configuration: UIEditMenuConfiguration,
        animator: UIEditMenuInteractionAnimating
    ) {
        guard menuItems != [] else { return }
        // Анимация при появлении меню
        animator.addAnimations {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.backgroundColor = .systemGray3
        }
    }
    
    private func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        willDismissMenuWith configuration: UIEditMenuConfiguration,
        animator: UIEditMenuInteractionAnimating
    ) {
        guard menuItems != [] else { return }
        // Анимация при скрытии меню
        animator.addAnimations {
            self.transform = .identity
            self.backgroundColor = .systemGray
        }
    }
}
