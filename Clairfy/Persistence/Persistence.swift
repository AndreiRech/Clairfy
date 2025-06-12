import Foundation
import CoreData

final class Persistence: PersistenceProtocol {
    static var shared = Persistence()

    var context: NSManagedObjectContext?

    func createAudio(_ audio: AudioFileModel) {
        guard let context else { return }
        
        let newAudio = AudioFile(context: context)
        newAudio.id = audio.id
        newAudio.audioPath = audio.audioPath
        
        save()
    }
    
    func getAllAudio() -> [AudioFileModel] {
        guard let context else { return [] }
        
        do {
            let request: NSFetchRequest<AudioFile> = AudioFile.fetchRequest()
            
            let result = try context.fetch(request)
            return result.map { $0.toModel() }
        } catch {
            print(error)
            return []
        }
    }
    
    func getAudio(by id: UUID) -> AudioFileModel? {
        guard let context else { return nil }
        
        do {
            let request: NSFetchRequest<AudioFile> = AudioFile.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            
            return try context.fetch(request).first?.toModel()
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteAudio(by id: UUID) -> Bool {
        guard let context else { return false }
        
        do {
            let request: NSFetchRequest<AudioFile> = AudioFile.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
                
            if let audioToDelete = try context.fetch(request).first {
                context.delete(audioToDelete)
                save()
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func createConsultation(_ consultation: ConsultationModel) {
        guard let context else { return }
        
        let newConsultation = Consultation(context: context)
        newConsultation.id = consultation.id
        newConsultation.title = consultation.title
        newConsultation.date = consultation.date
        newConsultation.transcription = consultation.transcription?.toEntity(in: context)
        newConsultation.audio = consultation.audio?.toEntity(in: context)
        
        save()
    }
    
    func getAllConsultations() -> [ConsultationModel] {
        guard let context else { return [] }
        
        do {
            let request: NSFetchRequest<Consultation> = Consultation.fetchRequest()
            
            let result = try context.fetch(request)
            return result.map { $0.toModel() }
        } catch {
            print(error)
            return []
        }
    }
    
    func getConsultation(by id: UUID) -> ConsultationModel? {
        guard let context else { return nil }
        
        do {
            let request: NSFetchRequest<Consultation> = Consultation.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            
            return try context.fetch(request).first?.toModel()
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteConsultation(by id: UUID) -> Bool {
        guard let context else { return false }
        
        do {
            let request: NSFetchRequest<Consultation> = Consultation.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
                
            if let consultationToDelete = try context.fetch(request).first {
                context.delete(consultationToDelete)
                save()
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func updateConsultation(_ consultation: ConsultationModel) -> Bool {
        guard let context else { return false }
        
        do {
            let request: NSFetchRequest<Consultation> = Consultation.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", consultation.id.uuidString)
                
            if let existingConsultation = try context.fetch(request).first {
                existingConsultation.title = consultation.title
                existingConsultation.date = consultation.date
                    
                if let transcriptionModel = consultation.transcription {
                    existingConsultation.transcription = transcriptionModel.toEntity(in: context)
                } else {
                    existingConsultation.transcription = nil
                }
                    
                if let audioModel = consultation.audio {
                    existingConsultation.audio = audioModel.toEntity(in: context)
                } else {
                    existingConsultation.audio = nil
                }
                    
                save()
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func createTranscription(_ transcription: TranscriptionModel) {
        guard let context else { return }
        
        let newTranscription = Transcription(context: context)
        newTranscription.id = transcription.id
        newTranscription.transcription = transcription.transcription
        newTranscription.summary = transcription.summary
        newTranscription.didctarized = transcription.didctarized
        newTranscription.keyWords = transcription.keyWords as NSObject
        newTranscription.actionPoints = transcription.actionPoints as NSObject
        
        save()
    }
    
    func getAllTranscriptions() -> [TranscriptionModel] {
        guard let context else { return [] }
        
        do {
            let request: NSFetchRequest<Transcription> = Transcription.fetchRequest()
            
            let result = try context.fetch(request)
            return result.map { $0.toModel() }
        } catch {
            print(error)
            return []
        }
    }
    
    func getTranscription(by id: UUID) -> TranscriptionModel? {
        guard let context else { return nil }
        
        do {
            let request: NSFetchRequest<Transcription> = Transcription.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            
            return try context.fetch(request).first?.toModel()
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteTranscription(by id: UUID) -> Bool {
        guard let context else { return false }
        
        do {
            let request: NSFetchRequest<Transcription> = Transcription.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
                
            if let transcriptionToDelete = try context.fetch(request).first {
                context.delete(transcriptionToDelete)
                save()
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func updateTranscription(_ transcription: TranscriptionModel) -> Bool {
        guard let context else { return false }
        
        do {
            let request: NSFetchRequest<Transcription> = Transcription.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", transcription.id.uuidString)
                
            if let existingTranscription = try context.fetch(request).first {
                existingTranscription.transcription = transcription.transcription
                existingTranscription.summary = transcription.summary
                existingTranscription.didctarized = transcription.didctarized
                existingTranscription.keyWords = transcription.keyWords as NSObject
                existingTranscription.actionPoints = transcription.actionPoints as NSObject
                    
                save()
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func save() {
        guard let context else { return }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    private var mockData: [ConsultationModel] = [
        ConsultationModel(id: UUID(), title: "Consulta com Dr. House", date: Date(), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Psicoterapia com Dra. Ana", date: Date().addingTimeInterval(-86400), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil),
        ConsultationModel(id: UUID(), title: "Retorno Clínico", date: Date().addingTimeInterval(-172800), audio: nil, transcription: nil)
    ]
        
    func getAllConsultationsMock() -> [ConsultationModel] {
        return mockData
    }
        
    func deleteConsultationMock(by id: UUID) -> Bool {
        if let index = mockData.firstIndex(where: { $0.id == id }) {
            mockData.remove(at: index)
            return true
        }
        return false
    }
}
