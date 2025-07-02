import UIKit

class OnboardingPageVC: UIViewController {
    // MARK: Subviews
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = Fonts.title1
        title.textAlignment = .center
        title.textColor = .label
        title.numberOfLines = 0
        return title
    }()
    
    lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.font = Fonts.body
        description.textAlignment = .center
        description.textColor = .label
        description.numberOfLines = 0
        return description
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = .init(top: 0, left: 14, bottom: 0, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    lazy var nextButton: ButtonComponent = {
        let button = ButtonComponent()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.text = "Continuar"
        button.font = Fonts.headline
        button.cornerRadius = 20
        button.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
        return button
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pular", for: .normal)
        button.titleLabel?.font = Fonts.body
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(skipAll), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nextButton, skipButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textStack, pageControl, buttonStack])
        stack.axis = .vertical
        stack.alignment = .fill
//        stack.distribution = .fillProportionally
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: Proprieties
    private let page: OnboardingPage
    var onNext: (() -> Void)?
    var onSkip: (() -> Void)?
    
    // MARK: Init
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    private func additionalSetup() {
        view.backgroundColor = .secondarySystemBackground
        configureContent()
    }
    
    private func configureContent() {
        imageView.image = UIImage(named: page.imageName)
        titleLabel.attributedText = UILabel().attributedText(
            withString: page.title,
            highlightedString: page.highlight,
            normalFont: Fonts.title1,
            highlightColor: .clairBlue
        )
        descriptionLabel.text = page.description
    }
    
    func configurePageControl(currentPage: Int, totalPages: Int) {
        pageControl.numberOfPages = totalPages
        pageControl.currentPage = currentPage
    }
}

extension OnboardingPageVC: ViewCodeProtocol {
    func addSubViews() {
        view.addSubview(imageView)
        view.addSubview(bottomStack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            bottomStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -24),
            bottomStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            
            nextButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}

extension OnboardingPageVC {
    @objc private func nextScreen() {
        onNext?()
    }

    @objc private func skipAll() {
        onSkip?()
    }
}
