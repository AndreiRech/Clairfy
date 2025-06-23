//
//  AnalysisAudio.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 20/06/25.
//

import AVFoundation
import UIKit

// MARK: - AVAudioPlayerDelegate
extension AnalysisViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioComponent.playButtonState = .play
        isPlaying = false
        print("✅ Áudio terminou de tocar")
    }
    
}
