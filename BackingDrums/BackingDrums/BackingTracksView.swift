import SwiftUI
import AVFoundation

struct BackingTracksView: View {
    
    let viewModel = CardViewModel()
    @StateObject private var trackViewModel = TrackCardViewModel()
    @StateObject private var metronome = Metronome()
    
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var totalTime: Double = 180.0
    
    @State private var showingTrackPicker = false
    @State private var selectedTrack: Track? = nil
    
    @State private var showingSettingSheet = false
    @State private var selectedSetting: String? = nil
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
                    
                    // MARK: -- Track settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Track Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.cards) { card in
                                if card.label == "Click" {
                                    Button {
                                        isClickOn.toggle()
                                        if isClickOn {
                                            metronome.start(bpm: tempo)
                                        } else {
                                            metronome.stop()
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(isClickOn ? "on" : "off")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            Text("Click")
                                                .font(.footnote)
                                                .foregroundColor(.black)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(isClickOn ? Color.green : Color.red.opacity(0.4))
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 1, y: 1)
                                    }
                                } else {
                                    Button {
                                        selectedSetting = card.label
                                        showingSettingSheet = true
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(value(for: card.label))
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            Text(card.label)
                                                .font(.footnote)
                                                .foregroundColor(.black)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.teal)
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 1, y: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingSettingSheet) {
                        settingSheet
                    }
                    
                    // MARK: -- Track info
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
                                        Text("Original Tempo: \(selectedTrack?.OriginalTempo ?? "-")")
                                    }
                                    HStack {
                                        Image(systemName: "music.quarternote.3")
                                        Text("Time Signature: \(selectedTrack?.TimeSignature ?? "-")")
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .shadow(radius: 1, y: 1)
                        .padding(.horizontal)
                    }
                    
                    // MARK: -- Music Player
                    VStack(spacing: 8) {
                        Text(selectedTrack?.SongName ?? "-")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 4) {
                            Slider(value: $currentTime, in: 0...totalTime)
                            HStack {
                                Text(formatTime(currentTime))
                                    .font(.caption2)
                                Spacer()
                                Text(formatTime(totalTime))
                                    .font(.caption2)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: 30) {
                            Button(action: {}) {
                                Image(systemName: "backward.fill")
                                    .font(.title3)
                            }
                            Button(action: {
                                isPlaying.toggle()
                            }) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.teal)
                            }
                            Button(action: {}) {
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
            .navigationTitle("Drum Backing Tracks")
            .onChange(of: tempo) { newTempo in
                metronome.update(bpm: newTempo)
            }
        }
    }
    
    // MARK: -- Helpers
    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    func value(for label: String) -> String {
        switch label {
        case "Tempo":
            return "\(Int(tempo))"
        case "Pitch":
            return "\(pitch)"
        case "Voice Count":
            return "\(voiceCount) bars"
        default:
            return "-"
        }
    }
    
    func clampTempo(from originalTempoString: String) -> Double {
        let digits = originalTempoString
            .split(separator: " ")
            .compactMap { Double($0) }
            .first ?? 120
        return min(200, max(60, digits))
    }
    
    var settingSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                if selectedSetting == "Tempo" {
                    VStack {
                        Text("Tempo: \(Int(tempo)) BPM")
                            .font(.headline)
                        Slider(value: $tempo, in: 60...200, step: 1)
                    }
                    .padding()
                } else if selectedSetting == "Pitch" {
                    VStack {
                        Text("Pitch")
                            .font(.headline)
                        Picker("Pitch", selection: $pitch) {
                            ForEach(-12...12, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding()
                } else if selectedSetting == "Voice Count" {
                    VStack {
                        Text("Voice Count")
                            .font(.headline)
                        Picker("Voice Count", selection: $voiceCount) {
                            ForEach(0...4, id: \.self) { i in
                                Text("\(i) bars").tag(i)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding()
                }
                Spacer()
            }
            .navigationTitle(selectedSetting ?? "Settings")
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
