//
//  CardViewModel.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 07/11/25.
//

import Foundation
import SwiftUI

class CardViewModel {
    var cards: [Card] = [
        Card(value: "128", label: "Tempo"),
        Card(value: "0", label: "Pitch"),
        Card(value: "0 bars", label: "Voice Count"),
        Card(value: "on", label: "Click"),
    ]
}
