//
//  CustomSignposter.swift
//
//  Created by Robert Ryan on 6/5/21.
//

import Foundation
import os.signpost

// MARK: - CustomPointsOfInterestLog

/// Custom Points of Interest Log
///
/// This allows logging of events and intervals to a custom “Points of Interest” tool in Instruments.
///
/// Needless to say, this assumes that you have installed the custom Points of Interest tool in Instrumewnts.

class CustomSignposter {
    private let log: OSSignposter

    init(subsystem: String) {
        log = OSSignposter(subsystem: subsystem, category: "com.robertmryan.CustomPointsOfInterest")
    }

    /// Post an event
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - label: The text associated with the particular event.
    ///   - concept: The event-concept (i.e., the color and symbol) of the event.

    func emitEvent(lane: StaticString = "Points", label: String, concept: EventConcept = .signpost) {
        log.emitEvent(lane, "Label:\(label, privacy: .public),Concept:\(concept.rawValue, privacy: .public)")
    }

    func beginInterval(lane: StaticString = "Intervals", _ label: String, concept: EventConcept = .signpost) -> OSSignpostIntervalState {
        let id = log.makeSignpostID()
        return log.beginInterval(lane, id: id, "Label:\(label, privacy: .public),Concept:\(concept.rawValue, privacy: .public)")
    }
    
    func endInterval(lane: StaticString = "Points", state: OSSignpostIntervalState) {
        log.endInterval(lane, state)
    }
    
    /// Record an interval in “Custom Points of Interest” tool for a synchronous block of work
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - label: The text associated with the particular interval.
    ///   - concept: The event-concept (i.e., the color) of the lane.
    ///   - block: The synchronous block to execute.
    /// - Returns: The value returned by the block, if any.

    func withIntervalSignpost<T>(lane: StaticString = "Intervals", _ label: String, concept: EventConcept = .signpost, around block: () throws -> T) rethrows -> T {
        let state = beginInterval(lane: lane, label, concept: concept)
        defer { endInterval(lane: lane, state: state) }

        return try block()
    }

    /// Record an interval in “Custom Points of Interest” tool for a throwing asynchronous block of work
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - label: The text associated with the particular interval.
    ///   - concept: The event-concept (i.e., the color) of the lane.
    ///   - block: The synchronous block to execute.
    /// - Returns: The value returned by the block, if any.

    func withIntervalSignpost<T>(lane: StaticString = "Intervals", _ label: String, concept: EventConcept = .signpost, around block: () async throws -> T) async rethrows -> T {
        let state = beginInterval(lane: lane, label, concept: concept)
        defer { endInterval(lane: lane, state: state) }

        return try await block()
    }
}

// MARK: - EventConcept

extension CustomSignposter {
    /// EventConcept enumeration
    ///
    /// This is used to dictate the color of the intervals in our custom instrument.
    /// See [Event Concept Engineering Type](https://help.apple.com/instruments/developer/mac/current/#/dev66257045).

    enum EventConcept: String, CaseIterable {
        case success  = "Success"
        case failure  = "Failure"

        case fault    = "Fault"
        case critical = "Critical"
        case error    = "Error"
        case debug    = "Debug"
        case pedantic = "Pedantic"
        case info     = "Info"

        case signpost = "Signpost"

        case high     = "High"
        case moderate = "Moderate"
        case low      = "Low"
        case veryLow  = "Very Low"

        case red      = "Red"
        case orange   = "Orange"
        case blue     = "Blue"
        case purple   = "Purple"
        case green    = "Green"
    }
}
