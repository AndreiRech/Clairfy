import Foundation
import CoreData

struct TranscriptionModel {
    let id: UUID
    let transcription: String
    let summary: String
    let didctarized: String
    let keyWords: [String]
    let actionPoints: [String]
}

extension TranscriptionModel {
    func toEntity(in context: NSManagedObjectContext) -> Transcription {
        let request: NSFetchRequest<Transcription> = Transcription.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", self.id.uuidString)
            
        if let existing = try? context.fetch(request).first {
            existing.transcription = self.transcription
            existing.summary = self.summary
            existing.didctarized = self.didctarized
            existing.keyWords = self.keyWords as NSObject
            existing.actionPoints = self.actionPoints as NSObject
            return existing
        } else {
            let entity = Transcription(context: context)
            entity.id = self.id
            entity.transcription = self.transcription
            entity.summary = self.summary
            entity.didctarized = self.didctarized
            entity.keyWords = self.keyWords as NSObject
            entity.actionPoints = self.actionPoints as NSObject
            return entity
        }
    }
}

extension Transcription  {
    func toModel() -> TranscriptionModel {
        TranscriptionModel(
            id: self.id ?? UUID(),
            transcription: self.transcription ?? "",
            summary: self.summary ?? "",
            didctarized: self.didctarized ?? "",
            keyWords: self.keyWords as? [String] ?? [],
            actionPoints: self.actionPoints as? [String] ?? []
        )
    }
}
