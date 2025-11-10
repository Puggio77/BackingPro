//
//  Metronome.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 10/11/25.
//

import Foundation
import AVFoundation
import Combine

final class Metronome: ObservableObject {
    private var timer: Timer?
    private var player: AVAudioPlayer?
    private var currentBPM: Double = 120

    init() {
        if let url = Bundle.main.url(forResource: "click", withExtension: "wav") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
            } catch {
                print("❌ Errore nel caricamento del suono del metronomo:", error.localizedDescription)
            }
        } else {
            print("⚠️ File click.wav non trovato nel bundle.")
        }
    }

    func start(bpm: Double) {
        stop()
        currentBPM = bpm
        let interval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        print("✅ Metronomo avviato a \(Int(bpm)) BPM")
    }

    /// Ferma il metronomo
    func stop() {
        timer?.invalidate()
        timer = nil
        print("🛑 Metronomo fermato")
    }

    /// Aggiorna il BPM se è già in esecuzione
    func update(bpm: Double) {
        guard timer != nil else { return }
        start(bpm: bpm)
    }

    /// Suona il click
    private func tick() {
        guard let player = player else { return }
        player.currentTime = 0
        player.play()
    }
}
