//
//  AudioAnimationView.swift
//  MentalApp
//
//  Created by Guilherme Borges Cavali on 30/08/24.
//

import Foundation
import UIKit

protocol AudioMeteringDelegate: AnyObject {
    /// amplitude já normalizada (0‒1)
    func audioMeter(didUpdateAmplitude amplitude: Float)
}

class AudioVisualizerView: UIView {
    
    enum ComponentValue {
        static let numOfColumns = 30
    }
    
    // Propriedade para a cor dos círculos
    var visualizerColor: UIColor = .clairBlue {  // Default color
        didSet {
            self.updateVisualizerColor()
        }
    }
    
    var columnWidth: CGFloat?
    var columns: [CAShapeLayer] = []
    var amplitudesHistory: [CGFloat] = []
    
    // Playback variables
    var displayLink: CADisplayLink?
    var amplitudesDuringPlayback: [CGFloat] = []
    var frameCounter = 0
    var updateFrequency = 2  // Atualiza a animação a cada 2 frames
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawVisualizerCircles() {
        self.amplitudesHistory = Array(repeating: 0, count: ComponentValue.numOfColumns)
        
        // Ajuste no cálculo do diâmetro para garantir espaçamento correto
        let diameter = self.bounds.width / CGFloat(3 * ComponentValue.numOfColumns + 1)  // Modificado de 2 para 3 para aumentar o espaçamento
        self.columnWidth = diameter / 2  // Reduzindo a largura dos círculos

        let startingPointY = self.bounds.midY - diameter / 2
        
        // Recalculando o ponto inicial X para preencher toda a largura horizontalmente
        let totalPadding = self.bounds.width - CGFloat(ComponentValue.numOfColumns) * diameter
        let padding = totalPadding / CGFloat(ComponentValue.numOfColumns + 1)
        var startingPointX = padding
        
        for _ in 0..<ComponentValue.numOfColumns {
            let circleOrigin = CGPoint(x: startingPointX, y: startingPointY)
            let circleSize = CGSize(width: self.columnWidth!, height: diameter)
            
            let circle = UIBezierPath(roundedRect: CGRect(origin: circleOrigin, size: circleSize), cornerRadius: self.columnWidth! / 2)
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = visualizerColor.cgColor  // Usa a cor configurável

            self.layer.addSublayer(circleLayer)
            self.columns.append(circleLayer)
            
            // Incrementando o X com diâmetro mais padding para espaçar adequadamente
            startingPointX += diameter + padding
        }
    }
    
    func removeVisualizerCircles() {
        for column in self.columns {
            column.removeFromSuperlayer()
        }
        
        self.columns.removeAll()
    }
    
    func displaySavedAmplitudes(_ amplitudes: [Float]) {
         for (index, amplitude) in amplitudes.enumerated() {
             DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) { // Assumindo que 0.08 é o intervalo de medição
                 self.updateVisualizerView(with: CGFloat(amplitude))
             }
         }
     }
    
    // Atualiza a cor de todos os círculos já desenhados
    private func updateVisualizerColor() {
        for column in columns {
            column.fillColor = self.visualizerColor.cgColor
        }
    }
    
    func startPlaybackVisualization(with amplitudes: [Double], recordingDuration: TimeInterval) {
        self.amplitudesDuringPlayback = amplitudes.map { CGFloat($0) }
        
        // Cálculo do número de quadros por segundo baseado na duração e no número de amostras
        var framesPerSecond = 0.0
        if recordingDuration > 0 {
            framesPerSecond = Double(amplitudes.count) / recordingDuration
        } else {
            framesPerSecond = Double(amplitudes.count) / 1
        }

        self.setupDisplayLink(framesPerSecond: framesPerSecond)
    }

    private func setupDisplayLink(framesPerSecond: Double) {
        self.displayLink = CADisplayLink(target: self, selector: #selector(step))
        self.displayLink?.preferredFramesPerSecond = Int(round(framesPerSecond))
        self.displayLink?.add(to: .main, forMode: .common)
    }

    func stopPlaybackVisualization() {
        self.stopDisplayLink()
    }

    private func stopDisplayLink() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    @objc private func step(displayLink: CADisplayLink) {
        if let amplitude = self.amplitudesDuringPlayback.first {
            self.updateVisualizerView(with: amplitude)
            self.amplitudesDuringPlayback.removeFirst()
        } else {
            self.stopPlaybackVisualization()
        }
    }
    
    private func computeNewPath(for layer: CAShapeLayer, with amplitude: CGFloat) -> CGPath {
        let width = self.columnWidth ?? 8.0

        // maxHeightGain = fullHeight - (circleInitialDiameter + 2 padding)
        let maxHeightGain = self.bounds.height - 2 * width  // Reduzindo o padding
        
        // Ajuste do fator de sensibilidade
        let sensitivityFactor: CGFloat = 1.5  // Ajuste conforme necessário
        let heightGain = maxHeightGain * amplitude * sensitivityFactor
        let newHeight = width + heightGain  // Aumentando a altura proporcionalmente
        
        let newOrigin = CGPoint(x: layer.path?.boundingBox.origin.x ?? 0,
                                y: (layer.superlayer?.bounds.midY ?? 0) - (newHeight / 2))
        let newSize = CGSize(width: width, height: newHeight)
        
        return UIBezierPath(roundedRect: CGRect(origin: newOrigin, size: newSize), cornerRadius: width / 2).cgPath
    }
    
    func updateVisualizerView(with amplitude: CGFloat) {
        
        guard self.columns.count == ComponentValue.numOfColumns else { return }
        
        // Adding a new value, removing the oldest
        self.amplitudesHistory.append(amplitude)
        self.amplitudesHistory.removeFirst()
        
        for i in 0..<self.columns.count {
            self.columns[i].path = self.computeNewPath(for: self.columns[i], with: self.amplitudesHistory[i])
        }
    }
}

// MARK: - AudioMeteringDelegate
extension AudioVisualizerView: AudioMeteringDelegate {
    func audioMeter(didUpdateAmplitude amplitude: Float) {
        DispatchQueue.main.async {
            self.updateVisualizerView(with: CGFloat(amplitude))
        }
    }
}

// MARK: – Redesenha após AutoLayout
private var _lastSizeKey: UInt8 = 0

extension AudioVisualizerView {

    private var lastDrawnSize: CGSize {
        get { (objc_getAssociatedObject(self, &_lastSizeKey) as? NSValue)?.cgSizeValue ?? .zero }
        set { objc_setAssociatedObject(self, &_lastSizeKey, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Quando o AutoLayout mudar o frame, redesenha se necessário
    override open func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.size != .zero else { return }
        guard bounds.size != lastDrawnSize else { return }  

        lastDrawnSize = bounds.size

        removeVisualizerCircles()
        drawVisualizerCircles()
    }
}
