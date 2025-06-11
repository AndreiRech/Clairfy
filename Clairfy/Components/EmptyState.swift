//
//  EmptyState.swift
//  Clairfy
//
//  Created by Eduardo Ferrari on 11/06/25.
//

import UIKit

class EmptyState: UIView {
    
    private lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(systemName: "microphone.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: "Label-Basic")
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProText-Bold", size: 24)
        label.textAlignment = .center
        label.text = "No audios yet"
        label.textColor = UIColor(named: "Label-Basic")
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProRounded-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = """
            Record your first\n conversation and see\n how every word\n becomes care.
            """
        label.textColor = UIColor(named: "Label-Basic")
        return label
    }()
    
    private lazy var stack: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EmptyState: ViewCodeProtocol {
    func setup() {
        addSubViews()
        setupConstraints()
    }
    
    func addSubViews() {
        addSubview(imageView)
        addSubview(stack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 31),
            imageView.heightAnchor.constraint(equalToConstant: 34),
            
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
        ])
    }
    
    
}
