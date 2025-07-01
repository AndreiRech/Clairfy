protocol TranscriptionManagerDelegate: AnyObject {
    func didChangeLoadingState(_ isLoading: Bool)
    func didFinishTranscription(success: Bool)
    func didChangeConsultation(_ consultation: ConsultationModel?)
    func didErrorHappend()
}
