import Foundation
import CoreData

struct ConsultationModel {
    let id: UUID
    let title: String
    let date: Date
    let audio: AudioFileModel?
    let transcription: TranscriptionModel?
}

extension ConsultationModel {
    func toEntity(in context: NSManagedObjectContext) -> Consultation {
        let request: NSFetchRequest<Consultation> = Consultation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", self.id.uuidString)
        
        if let existing = try? context.fetch(request).first {
            existing.title = self.title
            existing.date = self.date
            existing.audio = self.audio?.toEntity(in: context)
            existing.transcription = self.transcription?.toEntity(in: context)
            return existing
        } else {
            let entity = Consultation(context: context)
            entity.id = self.id
            entity.title = self.title
            entity.date = self.date
            entity.audio = self.audio?.toEntity(in: context)
            entity.transcription = self.transcription?.toEntity(in: context)
            return entity
        }
    }
}

extension Consultation {
    func toModel() -> ConsultationModel {
        ConsultationModel(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            date: self.date ?? Date(),
            audio: self.audio?.toModel(),
            transcription: self.transcription?.toModel()
        )
    }
}
