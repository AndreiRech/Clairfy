protocol AudioMeteringProtocol: AnyObject {
    func audioMeter(didUpdateAmplitude amplitude: Float)
}
