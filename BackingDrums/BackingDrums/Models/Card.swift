//
//  Card.swift
//  BackingDrums
//
//  Created by Riccardo Puggioni on 07/11/25.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    var value: String
    var label: String
}

