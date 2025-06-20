//
//  RoundedButton.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 20/06/25.
//

import UIKit

class RoundedButton: UITableViewCell {
    // MARK: Properties
    static let identifier = "rouded-button"
    
    // MARK: Components
    
    private lazy var button: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleToFill
        button.layer.cornerRadius = 24
        button.backgroundColor = .clairBlue
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [button])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.axis = .vertical
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return stack
    }()
    
    // MARK: Functions
//    func configure(image: UIImage) {
//        button.icon = image
//    }
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoundedButton: ViewCodeProtocol {
    func addSubViews() {
        contentView.addSubview(stackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
