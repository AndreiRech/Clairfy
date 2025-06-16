//
//  AnalysisViewController.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 12/06/25.
//
import AVFoundation
import UIKit

class AnalysisViewController: UIViewController {
    
    var consultation: ConsultationModel?
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private let scrollView = UIScrollView()
    private let contentView = UIView()


    
    // MARK: components & variables
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = "Análise"
        label.textColor = .label
        return label
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Médico", "Paciente"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var artificialInteligenceSummary: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Resumo Clínico"
//        textComponent.text = "Paciente Ana Paula, 37 anos, em acompanhamento de hipotireoidismo autoimune. Refere cansaço persistente, ganho de peso (5kg), constipação, sono não reparador e episódios esporádicos de ansiedade. Adere bem à levotiroxina 100mcg. Exame físico normal exceto palpação tireoidiana irregular. Solicitados exames hormonais e vitamínicos."

        // Configuração do botão Editar
        textComponent.editButtonText = "Editar"
        textComponent.editButtonImage = UIImage(systemName: "pencil")
        
        // Configuração do botão Ação
        textComponent.actionButtonText = "Copiar"
        textComponent.actionButtonImage = UIImage(systemName: "doc.on.doc.fill")
        
        // Usando cores personalizadas (opção 1 - contraste automático)
        textComponent.editButtonColor = .clairBlue
        textComponent.actionButtonColor = .clairBlue
        
        // OU usando cores específicas (opção 2 - cores manuais)
         textComponent.editButtonColor = UIColor(named: "clairBlue") ?? .systemBlue
         textComponent.editButtonIconColor = .tertiarySystemBackground
         textComponent.editButtonLabelColor = .tertiarySystemBackground
         textComponent.actionButtonColor = UIColor(named: "clairBlue") ?? .systemBlue
         textComponent.actionButtonIconColor = .tertiarySystemBackground
         textComponent.actionButtonLabelColor = .tertiarySystemBackground

        // Adicionando ações
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        
        return textComponent
    }()
    
    private lazy var audioComponent: AudioComponent = {
            let component = AudioComponent()
            component.translatesAutoresizingMaskIntoConstraints = false
            component.title = "Audio"
            component.date = "10/06/2024 - 21:00"
            component.duration = "00:48:14"
        
            //caminho
            component.audioPath = consultation?.audio?.audioPath
            
            // Configurar cores dos textos
            component.titleColor = .label
            component.dateColor = .secondaryLabel
            component.durationColor = .secondaryLabel
            
            // Configurar cores dos botões
            component.playButtonColor = .clairBlue
            component.trashButtonColor = .clairBlue
            component.shareButtonColor = .clairBlue
            
            // Configurar cores dos ícones
            component.playButtonIconColor = .tertiarySystemBackground
            component.trashButtonIconColor = .tertiarySystemBackground
            component.shareButtonIconColor = .tertiarySystemBackground
            
            // Configurar grossura dos ícones (opções: .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black)
//            component.playButtonIconWeight = .bold
            component.trashButtonIconWeight = .bold
            component.shareButtonIconWeight = .bold
    
            
            // Configurar ações dos botões
            component.playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
            component.trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
            component.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
            
            return component
        }()
    //pro teste
    private lazy var buttonTeste: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(gerarAnalise), for: .touchUpInside)
        button.setTitle( "Gerar Análise", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProRounded-Semibold", size: 17)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: "main"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        
        // Garante que o título seja exibido corretamente e evite comportamento estranho
        navigationItem.title = "Análise"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupViews()
        
        // Teste: printa o caminho do áudio se existir
        if let audioPath = consultation?.audio?.audioPath {
            print("Áudio da consulta: \(audioPath)")
        }
      
    }
    
    // MARK: functions
    @objc func gerarAnalise() {
        guard let audioPath = consultation?.audio?.audioPath else {
            print("❌ Caminho do áudio não encontrado.")
            return
        }

        let originalURL = URL(fileURLWithPath: audioPath)
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsDir.appendingPathComponent("audioTranscricao.m4a")

        do {
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.copyItem(at: originalURL, to: destinationURL)
                print("📥 Áudio copiado para: \(destinationURL.path)")
            } else {
                print("✅ Áudio já estava em Documents: \(destinationURL.path)")
            }
        } catch {
            print("❌ Erro ao copiar o áudio:", error.localizedDescription)
            return
        }

        let api = APIchatGPT()
        print("🎙️ Iniciando transcrição...")
        api.transcreverAudio(audioFileURL: destinationURL) { [weak self] transcricao in
            guard let self = self, let transcricao = transcricao, !transcricao.isEmpty else {
                print("❌ Transcrição vazia ou nula.")
                return
            }

            print("📝 Transcrição recebida:")
            print(transcricao)

            let transcricaoModel = TranscriptionModel(
                id: UUID(),
                transcription: transcricao,
                summary: "",
                didctarized: "",
                keyWords: [],
                actionPoints: []
            )

            DispatchQueue.main.async {
                self.consultation = ConsultationModel(
                    id: self.consultation?.id ?? UUID(),
                    title: self.consultation?.title ?? "Consulta",
                    date: self.consultation?.date ?? Date(),
                    audio: self.consultation?.audio,
                    transcription: transcricaoModel
                )
            }

            print("💬 Enviando para resumo...")
            api.resumirTexto(transcricao) { resumo in
                guard let resumo = resumo else {
                    print("❌ Falha ao gerar resumo.")
                    return
                }

                DispatchQueue.main.async {
                    self.artificialInteligenceSummary.text = resumo
                    print("✅ Resumo exibido na interface.")
                }
            }
        }
    }


    
}

// MARK: addViews & setConstraints
extension AnalysisViewController: ViewCodeProtocol {
    
    func addSubViews() {
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)

            contentView.addSubview(titleLabel)
            contentView.addSubview(segmentedControl)
            contentView.addSubview(artificialInteligenceSummary)
            contentView.addSubview(audioComponent)
            contentView.addSubview(buttonTeste)
        
    }

    func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // ScrollView preenchendo a tela
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView dentro da scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // ContentView deve ter a mesma largura da scrollView
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Constraints dos componentes internos
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            audioComponent.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            audioComponent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            audioComponent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            artificialInteligenceSummary.topAnchor.constraint(equalTo: audioComponent.bottomAnchor, constant: 20),
            artificialInteligenceSummary.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artificialInteligenceSummary.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            buttonTeste.topAnchor.constraint(equalTo: artificialInteligenceSummary.bottomAnchor, constant: 20),
            buttonTeste.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonTeste.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonTeste.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32) // Importante para dar fim ao scroll
        ])
    }
    
    func setupViews() {
        addSubViews()
        setupConstraints()
    }
}

// MARK: button functions
extension AnalysisViewController {
    
    enum PlayButtonState {
        case play
        case pause
    }
    
    private func updatePlayIcon(to state: PlayButtonState) {
        let iconName: String
        
        print(state)
        switch state {
        case .play:
            iconName = "play.fill"
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            let image = UIImage(systemName: iconName, withConfiguration: config)
            audioComponent.playButtonIconColor = .tertiarySystemBackground
            audioComponent.playButtonView.backgroundColor = .clairBlue
            audioComponent.playButton.setImage(image, for: .normal)
            //audioComponent.playButton.tintColor = .tertiarySystemBackground

        case .pause:
            
            iconName = "pause.fill"
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            let image = UIImage(systemName: iconName, withConfiguration: config)
            audioComponent.playButtonIconColor = .tertiarySystemBackground
            audioComponent.playButtonView.backgroundColor = .clairBlue
            audioComponent.playButton.setImage(image, for: .normal)
            audioComponent.playButton.tintColor = .tertiarySystemBackground
        }

//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
//        let image = UIImage(systemName: iconName, withConfiguration: config)

        // Atualiza o ícone na célula
//        audioComponent.playButtonIconColor = .tertiarySystemBackground
//        audioComponent.playButtonView.backgroundColor = .clairBlue
//        audioComponent.playButton.setImage(image, for: .normal)
//        audioComponent.playButton.tintColor = .tertiarySystemBackground
        
    }
    /// linkar botões com suas ações
    private func setupButtonActions() {
        
    }
    
    /// ações dos botões
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Segmento selecionado: \(sender.selectedSegmentIndex)")
        // adicionar a lógica para quando o segmento é alterado
    }
    
    @objc private func editButtonTapped(_ sender: UISegmentedControl) {
        print("Edit button selecionado")
        // adicionar a lógica para quando o botao de editar é apertado
    }
    
    @objc private func copyButtonTapped(_ sender: UISegmentedControl) {
        print("Copy button selecionado")
        // adicionar a lógica para quando o botao de copiar é apertado
    }
    
    @objc private func playButtonTapped() {
            // Se o player já existe, alterna entre play/pause
            if let player = audioPlayer {
                if player.isPlaying {
                    player.pause()
                    isPlaying = false
                    updatePlayIcon(to: .play)
                    print("⏸ Áudio pausado")
                } else {
                    player.play()
                    isPlaying = true
                    updatePlayIcon(to: .pause)
                    print("▶️ Áudio retomado")
                }
                return
            }

            // Caso o player ainda não tenha sido criado (primeira vez)
            guard let path = audioComponent.audioPath else {
                print("Caminho de áudio não definido")
                return
            }

            let url = URL(fileURLWithPath: path)

            if !FileManager.default.fileExists(atPath: url.path) {
                print("❌ Arquivo de áudio não encontrado no caminho: \(url.path)")
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
                updatePlayIcon(to: .pause)
                print("🎵 Tocando áudio: \(url.path)")
            } catch {
                print("❌ Erro ao tocar o áudio: \(error.localizedDescription)")
            }
        }


    @objc private func trashButtonTapped() {
        print("Trash button tapped")
    }

    @objc private func shareButtonTapped() {
        print("Share button tapped")
    }
    
}
