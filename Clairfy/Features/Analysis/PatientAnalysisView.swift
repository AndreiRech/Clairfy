//
//  wef.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 16/06/25.
//

import AVFoundation
import UIKit 

class PatientAnalysisView: UIView {
    
    // MARK: - Properties
    var consultation: ConsultationModel?
    weak var delegate: AnalysisViewController?
 
    // será arrumado esse componente depois...
    internal lazy var patientSummary: TextComponent = {
       let textComponent = TextComponent()
       textComponent.translatesAutoresizingMaskIntoConstraints = false
       textComponent.title = "Resumo da Consulta"
       
       textComponent.editButtonText = "Editar"
       textComponent.editButtonImage = UIImage(systemName: "pencil")
       textComponent.actionButtonText = "Copiar"
       textComponent.actionButtonImage = UIImage(systemName: "doc.on.doc.fill")
       textComponent.editButtonColor = .clairBlue
       textComponent.actionButtonColor = .clairBlue
       textComponent.editButtonIconColor = .tertiarySystemBackground
       textComponent.editButtonLabelColor = .tertiarySystemBackground
       textComponent.actionButtonIconColor = .tertiarySystemBackground
       textComponent.actionButtonLabelColor = .tertiarySystemBackground
       
       textComponent.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
       textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
       
       return textComponent
   }()
    
    internal lazy var contentStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [patientSummary])
       stackView.translatesAutoresizingMaskIntoConstraints = false
       stackView.axis = .vertical
       stackView.spacing = 24
       stackView.isHidden = false
       return stackView
   }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
     
    // MARK: - Button Actions
    @objc internal func editButtonTapped() {
        print("Botão Editar (Médico) pressionado")
    }
    
    @objc internal func copyButtonTapped() {
        print("Botão Copiar (Médico) pressionado")
    }
    
    var tempoDeRespostaAPI: Bool = false
    
}
