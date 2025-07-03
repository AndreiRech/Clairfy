//import AVFAudio
//import UIKit
//
//final class MicrophonePermissionManager {
//    static func requestPermission(completion: @escaping (Bool) -> Void) {
//        AVAudioApplication.requestRecordPermission { granted in
//            DispatchQueue.main.async {
//                completion(granted)
//            }
//        }
//    }
//    
//    static func showPermissionAlert(on viewController: UIViewController) {
//        let alert = UIAlertController(
//            title: "Permissão Necessária",
//            message: "Este app precisa de acesso ao microfone para gravar áudio. Vá em Ajustes > Privacidade > Microfone e ative o acesso.",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "Abrir Ajustes", style: .default) { _ in
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
//               UIApplication.shared.canOpenURL(settingsURL) {
//                UIApplication.shared.open(settingsURL)
//            }
//        })
//
//        viewController.present(alert, animated: true, completion: nil)
//    }
//}

/// agora suporta versões mais antigas do iOS!

import AVFAudio
import UIKit

final class MicrophonePermissionManager {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }

    static func showPermissionAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Permissão Necessária",
            message: "Este app precisa de acesso ao microfone para gravar áudio. Vá em Ajustes > Privacidade > Microfone e ative o acesso.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Abrir Ajustes", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        })

        viewController.present(alert, animated: true, completion: nil)
    }
}
