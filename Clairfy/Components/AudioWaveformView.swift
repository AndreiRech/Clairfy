import UIKit
import AVFoundation

protocol AudioWaveformViewDelegate: AnyObject {
    func waveformView(_ waveformView: AudioWaveformView, didScrubTo progress: CGFloat)
}

class AudioWaveformView: UIView {
    
    weak var delegate: AudioWaveformViewDelegate?

    private var samples: [CGFloat] = []
    
    var progress: CGFloat = 0.0 {
        didSet { setNeedsDisplay() }
    }

    private var activeColor: UIColor = .clairBlue
    private var inactiveColor: UIColor = .systemGray4
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear // fundo transparente
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    func configure(with audioURL: URL, color: UIColor = .clairBlue) {
        self.activeColor = color
        self.progress = 1.0 // começa colorido por padrão

        Task {
            let (_, samples) = await generateWaveformSamples(from: audioURL, size: self.bounds.size)
            await MainActor.run {
                self.samples = samples
                self.setNeedsDisplay()
            }
        }
    }

    func resetWaveformProgress() {
        progress = 0.0
        setNeedsDisplay()
    }

    // MARK: Drawing
    override func draw(_ rect: CGRect) {
        guard !samples.isEmpty else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let barWidth: CGFloat = 3
        let spacing: CGFloat = 2
        let height = bounds.height
        let totalBars = Int(bounds.width / (barWidth + spacing))
        let samplesPerBar = max(1, samples.count / totalBars)

        for i in 0..<totalBars {
            let start = i * samplesPerBar
            let end = min(start + samplesPerBar, samples.count)
            guard start < end else { continue }

            let slice = samples[start..<end]
            let avg: CGFloat = slice.reduce(0, +) / CGFloat(slice.count)

            let barHeight = avg * height
            let x = CGFloat(i) * (barWidth + spacing)
            let y = (height - barHeight) / 2
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)

            let ratio = CGFloat(i) / CGFloat(totalBars)
            let color = ratio <= progress ? activeColor : inactiveColor
            color.setFill()
            path.fill()
        }
    }

    // MARK: Touch handling (scrubbing)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    private func handleTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let clampedX = max(0, min(location.x, bounds.width))
        let newProgress = clampedX / bounds.width
        progress = newProgress
        delegate?.waveformView(self, didScrubTo: newProgress)
    }

    // MARK: Waveform generation (simplified)
    private func generateWaveformSamples(from url: URL, size: CGSize) async -> (UIImage?, [CGFloat]) {
        // Seu método original para extrair samples, pode manter o código antigo aqui.
        // Retorna imagem nil, só amostras (samples) para o draw.
        
        guard size.width > 0 && size.height > 0 else { return (nil, []) }
        
        let asset = AVURLAsset(url: url)
        guard let track = try? await asset.loadTracks(withMediaType: .audio).first else { return (nil, []) }
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMBitDepthKey: 16
        ]
        
        guard let reader = try? AVAssetReader(asset: asset) else { return (nil, []) }
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var sampleData = [Int16]()
        
        while reader.status == .reading {
            guard let buffer = output.copyNextSampleBuffer(),
                  let blockBuffer = CMSampleBufferGetDataBuffer(buffer) else { continue }
            
            let length = CMBlockBufferGetDataLength(blockBuffer)
            var data = Data(count: length)
            _ = data.withUnsafeMutableBytes { bufferPointer in
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bufferPointer.baseAddress!)
            }
            
            let samples = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> [Int16] in
                Array(UnsafeBufferPointer(start: ptr.bindMemory(to: Int16.self).baseAddress!, count: length / 2))
            }
            
            sampleData.append(contentsOf: samples)
            CMSampleBufferInvalidate(buffer)
        }
        
        guard !sampleData.isEmpty else { return (nil, []) }
        
        let safeWidth = max(1, Int(size.width))
        let samplesPerPixel = max(1, sampleData.count / safeWidth)
        var normalizedSamples = [CGFloat]()
        
        for i in stride(from: 0, to: sampleData.count, by: samplesPerPixel) {
            let start = i
            let end = min(i + samplesPerPixel, sampleData.count)
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
        
        return (nil, scaledSamples)
    }
}
