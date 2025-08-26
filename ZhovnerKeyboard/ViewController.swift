//
//  ViewController.swift
//  ZhovnerKeyboard
//
//  Created by Максим Павлов on 21.08.2025.
//

import UIKit

final class ViewController: UIViewController {
    
    private let openSettingsButton = UIButton()

    private let testTextfield: UITextField = {
        let textfield =  UITextField()
        textfield.borderStyle = .roundedRect
        textfield.placeholder = "Type smth..."
        textfield.font = UIFont.systemFont(ofSize: 15)
        textfield.backgroundColor = .lightGray
        textfield.layer.cornerRadius = 25
        textfield.layer.borderWidth = 1.5
        textfield.clipsToBounds = true
        return textfield
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        view.addSubview(testTextfield)
        view.addSubview(openSettingsButton)
        testTextfield.delegate = self
        setupConstrainsts()
        setupSettingsButton()
        hideKeyboardIfTapedOutside()
    }
    
    private func setupConstrainsts() {
        testTextfield.translatesAutoresizingMaskIntoConstraints = false
        openSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testTextfield.heightAnchor.constraint(equalToConstant: 50),
            testTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            testTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testTextfield.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            
            openSettingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openSettingsButton.heightAnchor.constraint(equalToConstant: 64),
            openSettingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            openSettingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            openSettingsButton.topAnchor.constraint(equalTo: testTextfield.topAnchor, constant: 250)
        ])
    }
    
    private func setupSettingsButton() {
        openSettingsButton.setTitleColor(.black, for: .normal)
        openSettingsButton.setTitleColor(.lightGray, for: .highlighted)
        openSettingsButton.backgroundColor = .yellow
        openSettingsButton.layer.cornerRadius = 16
        openSettingsButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        openSettingsButton.setTitle("ADD KEYBOARD", for: .normal)
        openSettingsButton.addTarget(self, action: #selector(openSettingsButtonAction), for: .touchUpInside)
        
        
    }
    
    @objc private func openSettingsButtonAction() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    private func hideKeyboardIfTapedOutside() {
        let outsideTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(outsideTap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension ViewController: UITextFieldDelegate {
}

