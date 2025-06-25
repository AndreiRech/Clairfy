import UIKit
import AVFAudio

class ConsultationListVC: UIViewController {
    // MARK: Subviews
    lazy var searchButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                               style: .plain,
                               target: self,
                               action: #selector(searchButtonTapped))
    }()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchResultsUpdater = self
        sc.searchBar.delegate = self
        sc.searchBar.placeholder = "Buscar áudios"
        return sc
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
        table.separatorStyle = .none
        return table
    }()
    
    lazy var button: UIButton = {
        var button = UIButton()
        button.backgroundColor = .clairBlue
        button.translatesAutoresizingMaskIntoConstraints = false

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
    var consultations = Persistence.shared.getAllConsultations() {
        didSet {
            buildContent()
            tableView.reloadData()
        }
    }
    var consultation: ConsultationModel?
    var rows: [ConsultationModel] = []
    var firstTime: Bool = false
    
    private var isSelecting = false
    private var selectedIndexPaths: Set<IndexPath> = []

    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        consultations = Persistence.shared.getAllConsultations()
    }
    
    // MARK: Functions
    func additionalSetup() {
        title = "Áudios"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [selectButtonItem, searchButtonItem]
        
        view.backgroundColor = .secondarySystemBackground
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        navigationItem.hidesBackButton = firstTime
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !firstTime
        
        buildContent()
    }
    
    func buildContent() {
        rows = consultations
    }

    func getConsultation(by indexPath: IndexPath) -> ConsultationModel {
        return rows[indexPath.row]
    }
    
    func deselectAll() {
        for indexPath in selectedIndexPaths {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
        selectedIndexPaths.removeAll()
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
            button.heightAnchor.constraint(equalToConstant: 92),
            button.widthAnchor.constraint(equalToConstant: 92)
        ])
    }
}

// MARK: - Table View

extension ConsultationListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelecting {
            if selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths.remove(indexPath)
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                selectedIndexPaths.insert(indexPath)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            self.consultation = self.getConsultation(by: indexPath)
            let viewController = AnalysisViewController()
            viewController.consultation = consultation
            changeScreen(to: viewController)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, complete in
            guard let self else { return }
            let id = self.getConsultation(by: indexPath).id
            if Persistence.shared.deleteConsultation(by: id) {
                self.consultations = Persistence.shared.getAllConsultations()
                complete(true)
            } else {
                complete(false)
            }
        }
        
        action.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomCell {
            cell.applyRoundedCorners(at: indexPath, totalRows: rows.count)
            cell.accessoryType = selectedIndexPaths.contains(indexPath) ? .checkmark : .none
        }
    }
}

// MARK: - Table View

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
        
        cell.configure(titleText: consultation.title, timerText: consultation.date.formatDate())
        cell.backgroundColor = .tertiarySystemBackground
        cell.applyRoundedCorners(at: indexPath, totalRows: rows.count)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.hideBottomLine()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {
            return nil
        }
        
        cell.applyRoundedCorners(at: indexPath, totalRows: rows.count)
        
        return nil
    }
}

extension ConsultationListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            rows = consultations
            tableView.reloadData()
            return
        }

        rows = consultations.filter { consultation in
            consultation.title.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }
}

extension ConsultationListVC {
    @objc func searchButtonTapped() {
        searchController.isActive = true
    }
    
    @objc func selectButtonTapped() {
        isSelecting.toggle()
        tableView.allowsMultipleSelection = isSelecting
        deselectAll()
        
        tableView.reloadData()
            
        selectButtonItem.title = isSelecting ? "Cancelar" : "Selecionar"
            
        if isSelecting {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedItems))
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func buttonTapped() {
        MicrophonePermissionManager.requestPermission { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                MicrophonePermissionManager.showPermissionAlert(on: self)
                return
            }
            let viewController = VoiceRecordingViewController()
            viewController.startingRecording.toggle()
            changeScreen(to: viewController)
        }
    }
    
    @objc private func deleteSelectedItems() {
        let selectedIds = selectedIndexPaths.map { getConsultation(by: $0).id }
        for id in selectedIds {
            _ = Persistence.shared.deleteConsultation(by: id)
        }
        
        deselectAll()
        
        consultations = Persistence.shared.getAllConsultations()
        
        selectButtonTapped()
    }

}
