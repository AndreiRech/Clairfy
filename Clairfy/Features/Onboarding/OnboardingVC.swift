import UIKit

class OnboardingVC: UIPageViewController {
    // MARK: Subviews
    private lazy var pageControllers: [OnboardingPageVC] = {
        var controllers: [OnboardingPageVC] = []

        for (index, page) in pages.enumerated() {
            let vc = OnboardingPageVC(page: page)
            vc.configurePageControl(currentPage: index, totalPages: pages.count)
            
            vc.onNext = { [weak self] in
                guard let self = self else { return }
                let nextIndex = index + 1
                if nextIndex < self.pageControllers.count {
                    self.setViewControllers([self.pageControllers[nextIndex]], direction: .forward, animated: true, completion: nil)
                } else {
                    let vc = ConsultationListVC()
                    vc.firstTime = true
                    Persistence.setFirstTimeDone()
                    changeScreen(to: vc)
                }
            }

            vc.onSkip = { [weak self] in
                guard let self = self else { return }
                let vc = ConsultationListVC()
                vc.firstTime = true
                Persistence.setFirstTimeDone()
                changeScreen(to: vc)
            }

            controllers.append(vc)
        }

        return controllers
    }()

    
    // MARK: Proprieties
    let pages = [
        OnboardingPage(imageName: "DoctorOnboarding", title: "Grave e acompanhe cada detalhe da sua consulta", highlight: "Grave", description: "Deixe as anotações por nossa conta e converse com o seu paciente sem distrações."),
        OnboardingPage(imageName: "PreviewOnboarding", title: "Receba um resumo prático e os próximos passos", highlight: "resumo prático", description: "Transformamos a conversa em pontos de ação para você enviar para seu paciente após a consulta."),
        OnboardingPage(imageName: "DataOnboarding", title: "Seus dados, sua segurança, sua privacidade", highlight: "sua segurança", description: "Todo o processamento é criptografado; só você decide quem acessa suas informações.")
    ]
    
    // MARK: Init
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    private func additionalSetup() {
        view.backgroundColor = .secondarySystemBackground
        setViewControllers([pageControllers[0]], direction: .forward, animated: true, completion: nil)
        delegate = self
        dataSource = self
    }
}

extension OnboardingVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.firstIndex(of: viewController as! OnboardingPageVC), index > 0 else { return nil }
        return pageControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.firstIndex(of: viewController as! OnboardingPageVC), index < pages.count - 1 else { return nil }
        return pageControllers[index + 1]
    }
}

extension OnboardingVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleVC = viewControllers?.first,
           let index = pageControllers.firstIndex(of: visibleVC as! OnboardingPageVC) {
            pageControllers[index].configurePageControl(currentPage: index, totalPages: pages.count)
        }
    }
}
