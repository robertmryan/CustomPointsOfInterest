//
//  InstrumentsInterval.swift
//
//  Created by Robert Ryan on 6/5/21.
//

import Foundation
import os.log

// MARK: - CustomPointsOfInterestLog

/// Custom Points of Interest Log
///
/// This allows logging of events and intervals to a custom “Points of Interest” tool in Instruments.
///
/// Needless to say, this assumes that you have installed the custom Points of Interest tool in Instrumewnts.

class CustomPointsOfInterestLog {
    fileprivate let log: OSLog

    init(subsystem: String) {
        log = OSLog(subsystem: subsystem, category: "com.robertmryan.CustomPointsOfInterest")
    }

    /// Post an event
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - label: The text associated with the particular event.
    ///   - concept: The event-concept (i.e., the color and symbol) of the event.

    func event(lane: StaticString = "Points", _ label: String, concept: EventConcept = .signpost) {
        os_signpost(.event, log: log, name: lane, InstrumentsInterval.formatString, label, concept.rawValue)
    }

    /// Record an interval in “Custom Points of Interest” tool for a synchronous block of work
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - label: The text associated with the particular interval.
    ///   - concept: The event-concept (i.e., the color) of the lane.
    ///   - block: The synchronous block to execute.
    /// - Returns: The value returned by the block, if any.

    func interval<T>(lane: StaticString = "Intervals", _ label: String, concept: EventConcept = .signpost, block: () throws -> T) rethrows -> T {
        let interval = InstrumentsInterval(lane: lane, label: label, concept: concept, log: self)

        interval.begin()
        defer { interval.end() }
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

    func interval<T>(lane: StaticString = "Intervals", _ label: String, concept: EventConcept = .signpost, block: () async throws -> T) async rethrows -> T {
        let interval = InstrumentsInterval(lane: lane, label: label, concept: concept, log: self)

        interval.begin()
        defer { interval.end() }
        return try await block()
    }
}

// MARK: - EventConcept

extension CustomPointsOfInterestLog {
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

// MARK: - InstrumentsInterval

/// Interval to be shown in custom instrument when profiling app

struct InstrumentsInterval {
    fileprivate static let formatString: StaticString = "Label:%{public}@,Concept:%{public}@"

    let lane: StaticString
    let label: String
    let concept: CustomPointsOfInterestLog.EventConcept
    let log: CustomPointsOfInterestLog
    let id: OSSignpostID

    init(lane: StaticString, label: String, concept: CustomPointsOfInterestLog.EventConcept = .signpost, log: CustomPointsOfInterestLog) {
        self.lane = lane
        self.concept = concept
        self.label = label
        self.log = log
        self.id = OSSignpostID(log: log.log)
    }

    /// Manually begin an interval

    func begin() {
        os_signpost(.begin, log: log.log, name: lane, signpostID: id, Self.formatString, label, concept.rawValue)
    }

    /// Manually end an interval

    func end() {
        os_signpost(.end, log: log.log, name: lane, signpostID: id)
    }
}
