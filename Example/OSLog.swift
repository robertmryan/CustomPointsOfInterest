//
//  OSLog.swift
//  CustomPointsOfInterest
//
//  Created by Robert Ryan on 3/13/23.
//

import Foundation
import os.log

// Extension to OSLog to simplify use of standard “Points of Interest” tool

extension OSLog {
    /// Post single event
    ///
    /// - Warning: The `string` is public, so be wary of leaking any secure information in this string.
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - string: The text associated with the particular event.

    func event(lane: StaticString = "Points", _ label: String) {
        os_signpost(.event, log: self, name: lane, "%{public}@", label)
    }

    /// Manually begin an interval
    ///
    /// - Warning: The `string` is public, so be wary of leaking any secure information in this string.
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - string: The text associated with the particular interval.
    /// - Returns: A `OSSignpostID` to be used when you call `end`.

    func begin(lane: StaticString = "Intervals", _ label: String) -> OSSignpostID {
        let id = OSSignpostID(log: self)
        os_signpost(.begin, log: self, name: lane, signpostID: id, "%{public}@", label)
        return id
    }

    /// Manually end an interval
    ///
    /// - Warning: The `string` is public, so be wary of leaking any secure information in this string.
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - string: The text associated with the start of the interval.
    ///   - id: The `OSSignpostID` returned by `begin`.

    func end(lane: StaticString = "Intervals", _ label: String, id: OSSignpostID) {
        os_signpost(.end, log: self, name: lane, signpostID: id, "%{public}@", label)
    }

    /// Record an interval for a synchronous block of work
    ///
    /// - Warning: The `string` is public, so be wary of leaking any secure information in this string.
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - string: The text associated with the end of the interval.
    ///   - block: The synchronous block to execute.
    /// - Returns: The value returned by the block, if any.

    func interval<T>(lane: StaticString = "Intervals", _ label: String, block: () throws -> T) rethrows -> T {
        let id = OSSignpostID(log: self)

        os_signpost(.begin, log: self, name: lane, signpostID: id, "%{public}@", label)
        defer { os_signpost(.end, log: self, name: lane, signpostID: id, "%{public}@", label) }
        return try block()
    }

    /// Record an interval for a throwing asynchronous block of work
    ///
    /// - Warning: The `string` is public, so be wary of leaking any secure information in this string.
    ///
    /// - Parameters:
    ///   - lane: The name for the lane in Instruments.
    ///   - string: The text associated with the end of the interval.
    ///   - block: The synchronous block to execute.
    /// - Returns: The value returned by the block, if any.

    func interval<T>(lane: StaticString = "Intervals", _ label: String, block: () async throws -> T) async rethrows -> T {
        let id = OSSignpostID(log: self)

        os_signpost(.begin, log: self, name: lane, signpostID: id, "%{public}@", label)
        defer { os_signpost(.end, log: self, name: lane, signpostID: id, "%{public}@", label) }
        return try await block()
    }
}
