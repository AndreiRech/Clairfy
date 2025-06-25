import UIKit

class CustomCell: UITableViewCell {
    // MARK: Properties
    static let identifier = "cuctom-cell"
    
    // MARK: Subviews
    private lazy var title: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder - Title"
        label.font = Fonts.body
        label.textColor = .label
        return label
    }()
    
    private lazy var timer: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder - timer"
        label.font = Fonts.subheadline
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var image: UIImageView = {
        var image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleToFill
        image.image = UIImage(systemName: "chevron.right")
        image.tintColor = .clairBlue
        return image
    }()
    
    private lazy var textStack: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [title, timer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.axis = .vertical
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return stack
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray // cor da linha
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = false
        view.backgroundColor = .separator
        return view
    }()
    
    // MARK: Functions
    func configure(titleText: String, timerText: String) {
        title.text = titleText
        timer.text = timerText
    }
    
    func hideBottomLine() {
        bottomLine.isHidden = true
    }
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomCell: ViewCodeProtocol {
    func addSubViews() {
        contentView.addSubview(textStack)
        contentView.addSubview(image)
        contentView.addSubview(bottomLine)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            image.widthAnchor.constraint(equalToConstant: 10),
            image.heightAnchor.constraint(equalToConstant: 16),
            
            bottomLine.heightAnchor.constraint(equalToConstant: 0.5),
            bottomLine.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 7)
        ])
    }
}
