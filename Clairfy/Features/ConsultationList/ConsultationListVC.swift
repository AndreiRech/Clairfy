import UIKit

class ConsultationListVC: UIViewController {
    // MARK: Subviews
    lazy var searchButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                               style: .plain,
                               target: self,
                               action: #selector(searchButtonTapped))
    }()
    
    lazy var selectButtonItem: UIBarButtonItem = {
       return UIBarButtonItem(title: "Selecionar",
                              style: .plain,
                              target: self,
                              action: #selector(selectButtonTapped))
    }()
    
    lazy var emptyState: EmptyState = {
       var emptyState = EmptyState()
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        return emptyState
    }()
    
    lazy var tableView: UITableView = {
        var table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        table.backgroundColor = .secondarySystemBackground
        table.layer.cornerRadius = 16
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    lazy var button: UIButton = {
        var button = UIButton()
        button.backgroundColor = .clairBlue
        button.translatesAutoresizingMaskIntoConstraints = false

        /// constraints
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 92),
            button.heightAnchor.constraint(equalToConstant: 92)
        ])

        /// Força o cálculo do layout
        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.1
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .heavy)
            let playImage = UIImage(systemName: "circle.fill", withConfiguration: symbolConfig)
            button.setImage(playImage, for: .normal)
        }

        button.tintColor = .systemBackground
        button.layer.cornerRadius = 46
        button.layer.masksToBounds = true
        
        button.setTitle("REC", for: .normal)
        button.titleLabel?.font = Fonts.headline
        button.setTitleColor(.systemBackground, for: .normal)
        
        button.layer.borderColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        button.layer.borderWidth = 3
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        return button
    }()
    
    // MARK: Properties
    var consultations = Persistence.shared.getAllConsultationsMock() {
        didSet {
            buildContent()
            tableView.reloadData()
        }
    }
    
    var rows: [ConsultationModel] = []

    // MARK: Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: Functions
    func additionalSetup() {
        title = "Áudios"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [selectButtonItem, searchButtonItem]
        
        view.backgroundColor = .secondarySystemBackground
        buildContent()
    }
    
    func buildContent() {
        rows = buildRows()
    }
    func buildRows() -> [ConsultationModel] {
        return consultations
    }
    
    func getConsultation(by indexPath: IndexPath) -> ConsultationModel {
        return rows[indexPath.row]
    }
}

extension ConsultationListVC: ViewCodeProtocol {
    func addSubViews() {
        view.addSubview(tableView)
        view.addSubview(button)
        view.addSubview(emptyState)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyState.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyState.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}

extension ConsultationListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, complete in
            guard let self else { return }
            let id = self.getConsultation(by: indexPath).id
            if Persistence.shared.deleteConsultationMock(by: id) {
                self.consultations = Persistence.shared.getAllConsultationsMock()
                complete(true)
            } else {
                complete(false)
            }
        }
        
        action.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ConsultationListVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.emptyState.isHidden = !rows.isEmpty
        self.tableView.isHidden = rows.isEmpty
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let consultation = getConsultation(by: indexPath)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {
            return UITableViewCell()
        }
            
        cell.configure(titleText: consultation.title, timerText: consultation.date.description)
        cell.backgroundColor = .tertiarySystemBackground
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == rows.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
}

extension ConsultationListVC {
    @objc func searchButtonTapped() {
        print("Search botão pressionado")
    }
    
    @objc func selectButtonTapped() {
        print("Selecionar botão pressionado")
    }
    
    @objc func buttonTapped() {
        let viewController = VoiceRecordingViewController()
        navigationController?.pushViewController(viewController, animated: true)
        navigationController?.isNavigationBarHidden = false
    }
}
