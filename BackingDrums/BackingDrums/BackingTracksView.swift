//
//  BackingTracksView.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 07/11/25.
//

import SwiftUI

struct BackingTracksView: View {
    
    let viewModel = CardViewModel()
    
    var body: some View {
        
        NavigationStack{
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
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 380, height: 100
                          )

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
                
                // Cards grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.cards) { card in
                        VStack(spacing: 6) {
                            Text(card.value)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(card.label)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.teal)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 1, y: 1)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
            
            // MARK: -- Track info
            VStack(spacing: 0){
                List{
                    Section(header: Text("Track Info")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    ){
                        HStack {
                            Image(systemName: "metronome")
                            Text("Original Tempo: 120BPM")
                        }
                        HStack {
                            Image(systemName: "music.quarternote.3")
                            Text("Time Signature: 4/4")
                        }
                    }
                }
            }
            .navigationTitle("Drum Backing Tracks")
        }
    }
}

#Preview {
    BackingTracksView()
}
