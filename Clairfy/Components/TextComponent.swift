//
//  AudioComponent.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 12/06/25.
//

import UIKit

class OverviewComponent: UIView {
    
    private var textFieldHeight: CGFloat

    lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        return label
    }()

    var labelText: String? {
        didSet {
            nameLabel.text = labelText
        }
    }

    lazy var nameTextField: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "AI summary here..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        return label
    }()

    var textColor: UIColor? {
        didSet {
            nameTextField.textColor = textColor
        }
    }
    
    var text: String? {
        didSet {
            nameTextField.text = text
        }
    }

    lazy var stackName: UIStackView = {
        var label = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
        label.translatesAutoresizingMaskIntoConstraints = false
        label.axis = .vertical
        label.spacing = 8
        return label
    }()

    init(height: CGFloat = 46) {
        self.textFieldHeight = height
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension OverviewComponent: ViewCodeProtocol {

    func addSubViews() {
        addSubview(stackName)
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([
            stackName.topAnchor.constraint(equalTo: topAnchor),
            stackName.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackName.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackName.bottomAnchor.constraint(equalTo: bottomAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
        ])

    }

}
