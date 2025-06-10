import Foundation
import CoreData

struct AudioFileModel {
    let id: UUID
    let audioPath: String
}

extension AudioFileModel {
    func toEntity(in context: NSManagedObjectContext) -> AudioFile {
        let request: NSFetchRequest<AudioFile> = AudioFile.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", self.id.uuidString)
            
        if let existing = try? context.fetch(request).first {
            existing.audioPath = self.audioPath
            return existing
        } else {
            let entity = AudioFile(context: context)
            entity.id = self.id
            entity.audioPath = self.audioPath
            return entity
        }
    }
}

extension AudioFile {
    func toModel() -> AudioFileModel {
        AudioFileModel(
            id: self.id ?? UUID(),
            audioPath: self.audioPath ?? ""
        )
    }
}
