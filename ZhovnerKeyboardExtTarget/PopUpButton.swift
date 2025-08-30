//
//  PopUpButton.swift
//  ZhovnerKeyboardExtTarget
//
//  Created by Максим Павлов on 21.08.2025.
//

import UIKit

final class PopUpButton: UIButton {
    private enum Constants {
        static let buttonWidth: CGFloat = 35
        static let buttonHeight: CGFloat = 30
        static let spacing: CGFloat = 6
        static let popoverHeight: CGFloat = buttonHeight + 10
        static let itemWidth: CGFloat = buttonWidth + spacing / 2
        static let itemsHorrizontalInsets: CGFloat = 8
        static let itemsVerticalInsets: CGFloat = 8
    }

    struct MenuItemModel {
        let title: String
        let action: () -> Void
    }
    struct MenuItemsModel {
        let items: [MenuItemModel]
        let adjustPopOverArrowDirection: UIPopoverArrowDirection
        init(items: [MenuItemModel], adjustPopOverArrowDirection: UIPopoverArrowDirection = .down) {
            self.items = items
            self.adjustPopOverArrowDirection = adjustPopOverArrowDirection
        }
    }

    private var primaryAction: (() -> Void)?
    private var menuItems: MenuItemsModel?
    private var preselectedIndex: Int = 0
    private var popoverController: UIViewController?
    private var menuButtons: [UIButton] = []
    private var selectedMenuIndex: Int = 0
    private var longPressGesture: UILongPressGestureRecognizer!
    private var usedBackgroundColor: UIColor = .clear
    private var alternativeLongPressAction: ((UILongPressGestureRecognizer) -> Void)?
    private var shiftAction: ((String?) -> Void)? = nil
    private var adjustPopOverArrowDirrection: UIPopoverArrowDirection = .down
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        setTitleColor(.label, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        // Добавляем тень как в iOS клавиатуре
        setupShadow()
        
        addKeyboardButtonAnimations()
        addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        
        // Жест для отслеживания движения пальца
        setupLongPressGesture()
    }
    
    // MARK: - Configuration
    func configure(
        backgroundColor: UIColor,
        primaryTitle: String?,
        primaryAction: @escaping () -> Void,
        menuItems: MenuItemsModel? = nil,
        preselectedIndex: Int = 0,
        alternativeLongPressAction: ((UILongPressGestureRecognizer) -> Void)? = nil,
        shiftAction: ((String?) -> Void)? = nil
    ) {
        usedBackgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
        setTitle(primaryTitle, for: .normal)
        self.primaryAction = primaryAction
        self.menuItems = menuItems
        self.preselectedIndex = preselectedIndex
        self.selectedMenuIndex = preselectedIndex
        self.alternativeLongPressAction = alternativeLongPressAction
        self.shiftAction = shiftAction
        
        // Обновляем жест в зависимости от наличия menuItems
        setupLongPressGesture()
    }
    
    func shiftStateChangeCalled() {
        shiftAction?(currentTitle)
    }
    
    // MARK: - Shadow Setup
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
    
    // MARK: - Long Press Gesture Setup
    private func setupLongPressGesture() {
        // Удаляем предыдущий жест если есть
        if let existingGesture = longPressGesture {
            removeGestureRecognizer(existingGesture)
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        // Настраиваем длительность в зависимости от наличия menuItems
        if let menuItems = menuItems, !menuItems.items.isEmpty {
            longPressGesture.minimumPressDuration = 0.3 // Стандартное для popover
        } else {
            longPressGesture.minimumPressDuration = 0.5 // Более длинное нажатие для альтернативного действия
        }
        
        addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Action Handlers
    @objc private func primaryTap() {
        primaryAction?()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let menuItems = menuItems,
              !menuItems.items.isEmpty else {
            alternativeLongPressAction?(gesture)
            return
        }

        _ = gesture.location(in: self)

        switch gesture.state {
        case .began:
            showCustomPopover()
            provideHapticFeedback()
        case .changed:
            // Определяем, находится ли палец над popover
            if let popoverView = popoverController?.view,
               let superview = popoverView.superview {
                let popoverLocation = gesture.location(in: superview)
                
                if popoverView.frame.contains(popoverLocation) {
                    // Палец над popover - определяем кнопку
                    let localLocation = gesture.location(in: popoverView)
                    selectButtonAtLocation(localLocation)
                }
            }
            
        case .ended, .cancelled:
            // Выполняем выбранное действие
            if selectedMenuIndex < menuItems.items.count {
                menuItems.items[selectedMenuIndex].action()
            }
            hideCustomPopover()
            
        default:
            break
        }
    }
    
    private func showCustomPopover() {
        guard let menuItems = menuItems,
            !menuItems.items.isEmpty
        else { return }
        
        popoverController?.dismiss(animated: false)
        
        let popoverVC = UIViewController()
        popoverVC.modalPresentationStyle = .popover
        
        let itemWidth: CGFloat = Constants.itemWidth
        let spacing: CGFloat = Constants.spacing
        let totalWidth = CGFloat(menuItems.items.count) * itemWidth + CGFloat(menuItems.items.count - 1) * spacing
        let totalHeight: CGFloat = Constants.popoverHeight
        
        // Используем исходный размер
        popoverVC.preferredContentSize = CGSize(width: totalWidth, height: totalHeight)
        popoverVC.view.backgroundColor = .clear
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 6
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.alignment = .center
        
        menuButtons.removeAll()
        for (index, menuItem) in menuItems.items.enumerated() {
            let button = createMenuButton(title: menuItem.title, index: index)
            menuButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        updateButtonSelection()
        
        popoverVC.view.addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if menuItems.adjustPopOverArrowDirection == .down {
            containerView.topAnchor.constraint(equalTo: popoverVC.view.topAnchor).isActive = true
        } else {
            containerView.bottomAnchor.constraint(equalTo: popoverVC.view.bottomAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: popoverVC.view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: totalWidth),
            containerView.heightAnchor.constraint(equalToConstant: totalHeight),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.widthAnchor.constraint(
                equalTo: containerView.widthAnchor,
                constant: -Constants.itemsHorrizontalInsets
            ),
            stackView.heightAnchor.constraint(
                equalTo: containerView.heightAnchor,
                constant: -Constants.itemsVerticalInsets
            )
        ])
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = self
            popover.sourceRect = bounds
            popover.permittedArrowDirections = [.up, .down]
            popover.delegate = self
            popover.backgroundColor = .clear
        }
        
        if let rootVC = findViewController() {
            rootVC.present(popoverVC, animated: true)
            popoverController = popoverVC
        }
        
        // Анимация появления
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.7)
        }
    }
    
    private func createMenuButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.tag = index
        button.isUserInteractionEnabled = false // Отключаем обычные тапы
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        // Constraints для размера
        button.widthAnchor.constraint(equalToConstant: Constants.buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight).isActive = true
        
        return button
    }

    private func updateButtonSelection() {
        for (index, button) in menuButtons.enumerated() {
            if index == selectedMenuIndex {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                button.backgroundColor = .systemGray5
                button.setTitleColor(.label, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                button.transform = .identity
            }
        }
    }
    
    private func selectButtonAtLocation(_ location: CGPoint) {
        guard !menuButtons.isEmpty else { return }
        
        let buttonWidth: CGFloat = Constants.buttonWidth
        let spacing: CGFloat = Constants.spacing
        let totalItemWidth = buttonWidth + spacing
        
        var newIndex = Int(location.x / totalItemWidth)
        
        // Ограничиваем индекс в пределах массива
        newIndex = max(0, min(newIndex, menuButtons.count - 1))
        
        if newIndex != selectedMenuIndex {
            selectedMenuIndex = newIndex
            updateButtonSelection()
            provideHapticFeedback()
        }
    }
    
    private func provideHapticFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - Extension with Animations
extension PopUpButton {
    func addKeyboardButtonAnimations() {
        removeTarget(nil, action: nil, for: .allEvents)
        
        addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        addTarget(self, action: #selector(keyboardTouchDown), for: [.touchDown, .touchDragInside])
        addTarget(self, action: #selector(keyboardTouchUp), for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchCancel])
    }
    
    @objc private func keyboardTouchDown() {
        guard popoverController == nil else { return }
        
        UIView.animate(withDuration: 0.1,
                      delay: 0,
                      options: [.curveEaseOut, .allowUserInteraction],
                      animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.7)
            // Убираем тень при нажатии для лучшего визуального эффекта
            self.layer.shadowOpacity = 0.1
        })

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func keyboardTouchUp() {
        guard popoverController == nil else { return }
        
        UIView.animate(withDuration: 0.15,
                      delay: 0,
                      options: [.curveEaseOut, .allowUserInteraction],
                      animations: {
            self.transform = .identity
            self.backgroundColor = self.usedBackgroundColor
            // Восстанавливаем тень
            self.layer.shadowOpacity = 0.3
        })
    }
    
    private func hideCustomPopover() {
        popoverController?.dismiss(animated: true)
        popoverController = nil
        
        UIView.animate(withDuration: 0.15,
                      delay: 0,
                      options: [.curveEaseOut, .allowUserInteraction],
                      animations: {
            self.transform = .identity
            self.backgroundColor = self.usedBackgroundColor
            self.layer.shadowOpacity = 0.3 // Восстанавливаем тень
        })
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension PopUpButton: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverController = nil
    }
}
