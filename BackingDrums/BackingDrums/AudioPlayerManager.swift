//
//  AudioPlayerManager.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 14/11/25.
//

import Foundation
import AVFoundation
import Combine

final class AudioPlayerManager: ObservableObject {
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let timePitch = AVAudioUnitTimePitch()
    
    private var audioFile: AVAudioFile?
    private var progressTimer: Timer?
    
    private var segmentStartTime: Double = 0
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    init() {
        setupAudioSession()
        setupEngine()
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func setupEngine() {
        engine.attach(player)
        engine.attach(timePitch)
        
        engine.connect(player, to: timePitch, format: nil)
        engine.connect(timePitch, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    // MARK: - LOAD
    
    func loadWav(named name: String) {
        stop()
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("File \(name).wav not found")
            return
        }
        
        do {
            let file = try AVAudioFile(forReading: url)
            audioFile = file
            
            let format = file.processingFormat
            let frames = Double(file.length)
            duration = frames / format.sampleRate
            
            currentTime = 0
            
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    // MARK: - PLAY
    
    func play() {
        guard audioFile != nil else { return }
        
        if !engine.isRunning {
            try? engine.start()
        }
        
        if !isPlaying {
            scheduleFile(from: currentTime)
            player.play()
            isPlaying = true
            startProgressTimer()
        }
    }
    
    func pause() {
        player.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    func stop() {
        player.stop()
        isPlaying = false
        currentTime = 0
        stopProgressTimer()
    }
    
    func seek(to time: Double) {
        guard audioFile != nil else { return }
        
        let clamped = max(0, min(time, duration))
        currentTime = clamped
        
        let wasPlaying = isPlaying
        
        player.stop()
        stopProgressTimer()
        
        scheduleFile(from: clamped)
        
        if wasPlaying {
            player.play()
            startProgressTimer()
        }
    }
    
    // MARK: - RATE (tempo)
    
    func changeRate(originalTempo: Double, newTempo: Double) {
        guard originalTempo > 0 else { return }
        let factor = newTempo / originalTempo
        timePitch.rate = Float(factor)
    }
    
    // MARK: - PITCH
    
    func changePitch(semitones: Int) {
        timePitch.pitch = Float(semitones * 100) // 100 cent per semitone
    }
    
    // MARK: - PRIVATE
    
    private func scheduleFile(from time: Double) {
        guard let file = audioFile else { return }
        
        let format = file.processingFormat
        let sampleRate = format.sampleRate
        
        let startFrame = AVAudioFramePosition(time * sampleRate)
        let remainingFrames = file.length - startFrame
        
        guard remainingFrames > 0 else {
            currentTime = duration
            isPlaying = false
            return
        }
        
        segmentStartTime = time
        file.framePosition = startFrame
        
        player.scheduleSegment(
            file,
            startingFrame: startFrame,
            frameCount: AVAudioFrameCount(remainingFrames),
            at: nil
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.currentTime = self?.duration ?? 0
                self?.stopProgressTimer()
            }
        }
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateCurrentTime() {
        guard
            let nodeTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: nodeTime),
            let file = audioFile
        else { return }
        
        let sampleRate = file.processingFormat.sampleRate
        let elapsed = Double(playerTime.sampleTime) / sampleRate
        
        currentTime = min(segmentStartTime + elapsed, duration)
        
        if currentTime >= duration {
            isPlaying = false
            stopProgressTimer()
        }
    }
}
