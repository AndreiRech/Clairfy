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
                    // Ao chegar na última página, exibe o alerta de consentimento
                    self.showConsentAlert()
                }
            }

            vc.onSkip = { [weak self] in
                // Ao pular, também exibe o alerta de consentimento
                self?.showConsentAlert()
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
    
    // Função para exibir o alerta de consentimento
    private func showConsentAlert() {
        let title = "Seu Compromisso de Uso"
        let message = """
        Ao continuar, você concorda com os seguintes pontos:

        1. Consentimento do Paciente: É sua total e exclusiva responsabilidade obter a permissão explícita do paciente ANTES de iniciar qualquer gravação.

        2. Ferramenta de Apoio, Não Diagnóstico: O Clairfy é uma ferramenta de suporte. Os resumos da IA NÃO são um diagnóstico médico e não substituem o julgamento clínico. As decisões de tratamento são de responsabilidade exclusiva do profissional.

        3. Dever de Revisão Crítica: A IA pode cometer erros ou omissões. É seu dever OBRIGATÓRIO revisar e validar a precisão de todos os resumos antes de qualquer uso.

        4. Isenção de Responsabilidade: Você assume total responsabilidade legal e ética pelo uso do aplicativo. Os desenvolvedores do Clairfy não se responsabilizam por quaisquer danos, erros clínicos ou violações legais decorrentes do uso da ferramenta.
        """

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Botão para aceitar os termos
        let acceptAction = UIAlertAction(title: "Estou Ciente e Concordo", style: .default) { [weak self] _ in
            // Ação ao aceitar: transiciona para a tela principal do app
            let vc = ConsultationListVC()
            vc.firstTime = true
            Persistence.setFirstTimeDone()
            self?.changeScreen(to: vc)
        }

        // Botão para cancelar
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

        alertController.addAction(acceptAction)
        alertController.addAction(cancelAction)

        // Apresenta o alerta na tela
        present(alertController, animated: true, completion: nil)
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

