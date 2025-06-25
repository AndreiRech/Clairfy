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
        view.addSubview(textStack)
        view.addSubview(buttonStack)
        view.addSubview(pageControl)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            textStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0),
            textStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            textStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            
            pageControl.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 16),
            pageControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            pageControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            buttonStack.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
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
