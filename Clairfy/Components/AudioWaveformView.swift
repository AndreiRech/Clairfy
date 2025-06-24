//
//  AudioWaveformView.swift
//  POC-waveForm
//
//  Created by Bernardo Garcia Fensterseifer on 24/06/25.
//

import UIKit
import AVFoundation

class AudioWaveformView: UIView {
    
    // MARK: - Properties
    private var waveformColor: UIColor = .systemBlue
    
    // MARK: - Subviews
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configure
    func configure(with audioURL: URL, color: UIColor = .systemBlue) {
        self.waveformColor = color
        
        Task {
            let image = await generateWaveformImage(from: audioURL, color: color, size: self.bounds.size)
            await MainActor.run {
                self.imageView.image = image
            }
        }
    }
    
    // MARK: - Private Waveform Generator
    private func generateWaveformImage(from url: URL, color: UIColor, size: CGSize) async -> UIImage? {
        guard size.width > 0 && size.height > 0 else { return nil }
        
        let asset = AVURLAsset(url: url)
        guard let track = try? await asset.loadTracks(withMediaType: .audio).first else { return nil }
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMBitDepthKey: 16
        ]
        
        guard let reader = try? AVAssetReader(asset: asset) else { return nil }
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var sampleData = [Int16]()
        
        while reader.status == .reading {
            guard let buffer = output.copyNextSampleBuffer(),
                  let blockBuffer = CMSampleBufferGetDataBuffer(buffer) else { continue }
            
            let length = CMBlockBufferGetDataLength(blockBuffer)
            var data = Data(count: length)
            _ = data.withUnsafeMutableBytes { (bufferPointer: UnsafeMutableRawBufferPointer) in
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bufferPointer.baseAddress!)
            }
            
            let samples = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> [Int16] in
                Array(UnsafeBufferPointer(start: ptr.bindMemory(to: Int16.self).baseAddress!, count: length / 2))
            }
            
            sampleData.append(contentsOf: samples)
            CMSampleBufferInvalidate(buffer)
        }
        
        guard !sampleData.isEmpty else { return nil }
        
        let safeWidth = max(1, Int(size.width))
        let samplesPerPixel = max(1, sampleData.count / safeWidth)
        var normalizedSamples = [CGFloat]()
        
        for i in stride(from: 0, to: sampleData.count, by: samplesPerPixel) {
            let start = i
            let end = min(i + samplesPerPixel, sampleData.count)
            if start >= end { continue }

            let slice = sampleData[start..<end]
            guard !slice.isEmpty else { continue }

        
            let maxSample = Int(slice.max() ?? 0)
            let minSample = Int(slice.min() ?? 0)
            let peak = max(abs(minSample), abs(maxSample))

            normalizedSamples.append(CGFloat(peak))
        }

        
        let maxAmplitude = normalizedSamples.max() ?? 0.1
        let scaledSamples: [CGFloat] = maxAmplitude > 0.001
            ? normalizedSamples.map { $0 / maxAmplitude }
            : Array(repeating: 0, count: normalizedSamples.count)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.cgContext.setLineWidth(0)
            
            let barWidth: CGFloat = 3
            let spacing: CGFloat = 2
            let totalBars = max(1, Int(size.width / (barWidth + spacing)))
            let samplesPerBar = max(1, scaledSamples.count / totalBars)
            
            for i in 0..<totalBars {
                let start = i * samplesPerBar
                let end = min(start + samplesPerBar, scaledSamples.count)
                if start >= end { continue }
                
                let slice = scaledSamples[start..<end]
                let avg: CGFloat = slice.isEmpty ? 0 : (slice.reduce(0, +) / CGFloat(slice.count))
                
                let barHeight = avg * size.height
                let x = CGFloat(i) * (barWidth + spacing)
                let y = (size.height - barHeight) / 2
                
                let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: barWidth / 2)
                path.fill()
            }
        }
        
        return image
    }
}

// MARK: - ViewCodeProtocol
extension AudioWaveformView: ViewCodeProtocol {
    func addSubViews() {
        addSubview(imageView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
