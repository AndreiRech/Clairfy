import Foundation

protocol AnalysisProtocol: AnyObject {
    func didTapEdit(category: TranscriptionEnum, transcriptionID: UUID?)
    func didFinishEditing()
}
