//
//  BackingTracksView.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 07/11/25.
//

import SwiftUI

struct BackingTracksView: View {
    
    let viewModel = CardViewModel()
    @State private var isPlaying = false
    @State private var currentTime: Double = 0.0
    @State private var totalTime: Double = 180.0
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: -- Backing Track
                    HStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.teal)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "music.note.list")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Blues Song 01")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Blues Artist")
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
                    
                    // MARK: -- Track settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Track Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.cards) { card in
                                VStack(spacing: 6) {
                                    Text(card.value)
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
                        .padding(.horizontal)
                    }
                    
                    // MARK: -- Track info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Track Info")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "metronome")
                                Text("Original Tempo: 120BPM")
                            }
                            HStack {
                                Image(systemName: "music.quarternote.3")
                                Text("Time Signature: 4/4")
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
                    
                    // MARK: -- Music Player (finto)
                    VStack(spacing: 8) {
                        Text("Song name?")
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
        }
    }
    
    // MARK: -- Helpers
    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    BackingTracksView()
}
