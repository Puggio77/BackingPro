//
//  BackingTracksView.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 07/11/25.
//

import SwiftUI
import AVFoundation

struct BackingTracksView: View {
    
    let viewModel = CardViewModel()
    @StateObject private var trackViewModel = TrackCardViewModel()
    @StateObject private var metronome = Metronome()
    
    // AUDIO PLAYER
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var totalTime: Double = 180.0
    
    @State private var showingTrackPicker = false
    @State private var selectedTrack: Track? = nil
    
    @State private var showingSettingSheet = false
    @State private var tempo: Double = 120
    @State private var pitch: Int = 0
    @State private var voiceCount: Int = 0
    @State private var isClickOn: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: -- Backing Track
                    Button {
                        showingTrackPicker.toggle()
                    } label: {
                        HStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.teal)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: selectedTrack?.img ?? "music.note.list")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedTrack?.SongName ?? "-")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(selectedTrack?.Artist ?? "-")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.leading, 4)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .shadow(radius: 1, y: 1)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingTrackPicker) {
                        NavigationView {
                            List(trackViewModel.tracks) { track in
                                Button {
                                    
                                    selectedTrack = track
                                    tempo = clampTempo(from: track.OriginalTempo)
                                    
                                    // CARICA AUDIO SOLO PER BLUES 01
                                    if track.SongName == "Blues 01" {
                                        audioPlayer.loadWav(named: "Blues Drumless Backing Track")
                                        totalTime = audioPlayer.duration
                                        currentTime = 0
                                    } else {
                                        audioPlayer.stop()
                                        currentTime = 0
                                        totalTime = 180
                                    }
                                    
                                    showingTrackPicker = false
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(track.SongName)
                                            .font(.headline)
                                        Text(track.Artist)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .navigationTitle("Select a Track")
                        }
                    }
                    
                    // MARK: -- Track Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Track Info")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    HStack {
                                        Image(systemName: "metronome")
                                        Text("Original Tempo: ")
                                            .font(.callout)
                                            .fontWeight(.heavy)
                                        Text("\(selectedTrack?.OriginalTempo ?? "-")")
                                    }
                                    
                                    HStack {
                                        Image(systemName: "music.quarternote.3")
                                        Text("Time Signature: ")
                                            .font(.callout)
                                            .fontWeight(.heavy)
                                        Text("\(selectedTrack?.TimeSignature ?? "-")")
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    
                    // MARK: -- Track settings
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Text("Track Settings")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button {
                                showingSettingSheet = true
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            
                            VStack(spacing: 6) {
                                Text("\(Int(tempo))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Tempo")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.teal.opacity(0.7)))
                            
                            VStack(spacing: 6) {
                                Text("\(pitch)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Pitch")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.teal.opacity(0.7)))
                            
                            VStack(spacing: 6) {
                                Text("\(voiceCount) bars")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Voice Count")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.teal.opacity(0.7)))
                            
                            VStack(spacing: 6) {
                                Text(isClickOn ? "on" : "off")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Click")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isClickOn ? Color.green.opacity(0.7) : Color.red.opacity(0.5))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingSettingSheet) {
                        unifiedSettingSheet
                    }
                    
                    // MARK: -- Music Player
                    VStack(spacing: 8) {
                        Text(selectedTrack?.SongName ?? "-")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 4) {
                            Slider(
                                value: $currentTime,
                                in: 0...totalTime,
                                onEditingChanged: { editing in
                                    if !editing {
                                        audioPlayer.seek(to: currentTime)
                                    }
                                }
                            )
                            HStack {
                                Text(formatTime(currentTime)).font(.caption2)
                                Spacer()
                                Text(formatTime(totalTime)).font(.caption2)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: 30) {
                            
                            Button(action: {
                                let newTime = max(0, currentTime - 5)
                                currentTime = newTime
                                audioPlayer.seek(to: newTime)
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.title3)
                            }
                            
                            Button(action: {
                                if audioPlayer.isPlaying {
                                    audioPlayer.pause()
                                    metronome.stop()
                                } else {
                                    audioPlayer.play()
                                    
                                    if isClickOn {
                                        metronome.start(bpm: tempo)
                                    }
                                }
                                
                                isPlaying = audioPlayer.isPlaying
                            }) {
                                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.teal)
                            }
                            
                            Button(action: {
                                let newTime = min(totalTime, currentTime + 5)
                                currentTime = newTime
                                audioPlayer.seek(to: newTime)
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, 4)
                        
                    }
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(radius: 1, y: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding(.top)
            }
            .navigationTitle("Backing Tracks")
            
            // RATE + BPM SYNC
            .onChange(of: tempo) { _, newTempo in
                
                if let selectedTrack {
                    let original = clampTempo(from: selectedTrack.OriginalTempo)
                    audioPlayer.changeRate(originalTempo: original, newTempo: newTempo)
                }
                
                if audioPlayer.isPlaying && isClickOn {
                    metronome.update(bpm: newTempo)
                }
            }
            
            // PITCH
            .onChange(of: pitch) { _, newPitch in
                audioPlayer.changePitch(semitones: newPitch)
            }
            
            // CLICK TOGGLE (non avvia più il metronomo autonomamente)
            .onChange(of: isClickOn) { _, newValue in
                if audioPlayer.isPlaying {
                    if newValue {
                        metronome.start(bpm: tempo)
                    } else {
                        metronome.stop()
                    }
                } else {
                    metronome.stop()
                }
            }
            
            // SYNC SLIDER
            .onReceive(audioPlayer.$currentTime) { time in
                currentTime = time
            }
            .onReceive(audioPlayer.$duration) { duration in
                totalTime = duration
            }
        }
    }
    
    // MARK: -- Helpers
    
    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    func clampTempo(from originalTempoString: String) -> Double {
        let digits = originalTempoString
            .split(separator: " ")
            .compactMap { Double($0) }
            .first ?? 120
        return min(200, max(60, digits))
    }
    
    // MARK: -- Settings Sheet
    var unifiedSettingSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(alignment: .leading) {
                    Text("Tempo: \(Int(tempo)) BPM")
                        .font(.headline)
                    Slider(value: $tempo, in: 60...200, step: 1)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Pitch")
                        .font(.headline)
                    Picker("Pitch", selection: $pitch) {
                        ForEach(-12...12, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Voice Count")
                        .font(.headline)
                    Picker("Voice Count", selection: $voiceCount) {
                        ForEach(0...4, id: \.self) { i in
                            Text("\(i) bars").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding(.horizontal)
                
                Toggle("Metronome Click", isOn: $isClickOn)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Edit Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showingSettingSheet = false }
                }
            }
        }
    }
}

#Preview {
    BackingTracksView()
}
