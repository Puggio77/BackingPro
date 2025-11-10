//
//  ContainerView.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 07/11/25.
//

import SwiftUI

struct ContainerView: View {
    

    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "music.note.house.fill"){
                HomeView()
            }
            Tab("Tracks", systemImage: "music.pages.fill"){
                BackingTracksView()
            }
            Tab("Metronome", systemImage: "metronome.fill"){
                MetronomeView()
            }
        }
    }
}


#Preview {
    ContainerView()
}
