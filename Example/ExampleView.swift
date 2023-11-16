//
//  ExampleView.swift
//
//  Created by Robert Ryan on 11/16/23.
//

import SwiftUI

let log = CustomSignposter(subsystem: "Test")

struct ExampleView: View {
    var body: some View {
        VStack {
            Text("Custom Signposter")
            
            Button("Run Demonstration") {
                Task {
                    for concept in CustomSignposter.EventConcept.allCases {
                        log.emitEvent(lane: "Events", label: concept.rawValue, concept: concept)
                        try await log.withIntervalSignpost(lane: "Event concepts", concept.rawValue, concept: concept) {
                            try await Task.sleep(for: .seconds(1))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
