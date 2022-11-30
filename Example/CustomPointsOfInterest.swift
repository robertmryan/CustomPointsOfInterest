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
        log = OSLog(subsystem: subsystem, category: "Interval")
    }

    func event(name: StaticString = "Points", label: String, concept: EventConcept = .debug) {
        os_signpost(.event, log: log, name: name, InstrumentsInterval.formatString, label, concept.rawValue)
    }

    func interval<T>(name: StaticString = "Intervals", label: String, concept: EventConcept = .debug, block: () throws -> T) rethrows -> T {
        let interval = InstrumentsInterval(name: name, label: label, concept: concept, log: self)

        interval.begin()
        defer { interval.end() }
        return try block()
    }
}

// MARK: - EventConcept

extension CustomPointsOfInterestLog {
    /// EventConcept enumeration
    ///
    /// This is used to dictate the color of the intervals in our custom instrument.
    /// See [Event Concept Engineering Type](https://help.apple.com/instruments/developer/mac/current/#/dev66257045).

    enum EventConcept: String {
        case success = "Success"
        case failure = "Failure"

        case fault = "Fault"
        case critical = "Critical"
        case error = "Error"
        case debug = "Debug"
        case pedantic = "Pedantic"
        case info = "Info"

        case signpost = "Signpost"

        case veryLow = "Very Low"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"

        case red = "Red"
        case orange = "Orange"
        case blue = "Blue"
        case purple = "Purple"
        case green = "Green"
    }
}

// MARK: - InstrumentsInterval

/// Interval to be shown in custom instrument when profiling app

struct InstrumentsInterval {
    fileprivate static let formatString: StaticString = "Label:%{public}@,Concept:%{public}@"

    let name: StaticString
    let label: String
    let concept: CustomPointsOfInterestLog.EventConcept
    let log: CustomPointsOfInterestLog
    let id: OSSignpostID

    init(name: StaticString, label: String, concept: CustomPointsOfInterestLog.EventConcept = .debug, log: CustomPointsOfInterestLog) {
        self.name = name
        self.concept = concept
        self.label = label
        self.log = log
        self.id = OSSignpostID(log: log.log)
    }

    /// Manually begin an interval
    func begin() {
        os_signpost(.begin, log: log.log, name: name, signpostID: id, Self.formatString, label, concept.rawValue)
    }

    /// Manually end an interval
    func end() {
        os_signpost(.end, log: log.log, name: name, signpostID: id)
    }

    /// Manually emit an event
    func event() {
        os_signpost(.event, log: log.log, name: name, signpostID: id, Self.formatString, label, concept.rawValue)
    }
}

extension OSLog {
    func event(name: StaticString = "Points", string: String) {
        os_signpost(.event, log: self, name: name, "%{public}@", string)
    }

    /// Manually begin an interval
    func begin(name: StaticString = "Intervals", _ string: String) -> OSSignpostID {
        let id = OSSignpostID(log: self)
        os_signpost(.begin, log: self, name: name, signpostID: id, "%{public}@", string)
        return id
    }

    /// Manually end an interval
    func end(name: StaticString = "Intervals", _ string: String, id: OSSignpostID) {
        os_signpost(.end, log: self, name: name, signpostID: id, "%{public}@", string)
    }

    func interval<T>(name: StaticString = "Intervals", _ string: String, block: () throws -> T) rethrows -> T {
        let id = OSSignpostID(log: self)

        os_signpost(.begin, log: self, name: name, signpostID: id, "%{public}@", string)
        defer { os_signpost(.end, log: self, name: name, signpostID: id, "%{public}@", string) }
        return try block()
    }
}
