//
//  NonContendedBenchmarking.swift
//  MutexBenchmarkContended
//
//  Created by Serhiy Butz on 4/25/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XConcurrencyKit
import Mutexes

typealias NonContendedMeasurementSummary = (mutexType: BasicMutex.Type, lockUnlockTime: TimeInterval)

func measureNonContended<T: BasicMutex>(_ mutexType: T.Type) -> NonContendedMeasurementSummary {
    let iterations = 100_000
    let subIterations = 1_000

    var lockUnlockTimeMeter = MachExecutionTimeMeter()
    let sut = mutexType.init()
    for _ in 0..<iterations {
        lockUnlockTimeMeter.measure {
            for _ in (0..<subIterations) {
                sut.lock()
                sut.unlock()
            }
        }
    }
    lockUnlockTimeMeter.reportInNanosecs = true
    return NonContendedMeasurementSummary(mutexType, lockUnlockTimeMeter.averageExecutionTime / Double(subIterations))
}

func runNonContended(renderingAs format: RenderFormat = .textPrintOut) -> String {
    let measurements: [NonContendedMeasurementSummary] = [
        measureNonContended(OSUnfairLock.self),
        measureNonContended(NSLock.self),
        measureNonContended(NSRecursiveLock.self),
        measureNonContended(PthreadMutex.self),
        measureNonContended(PthreadRecursiveMutex.self),
        measureNonContended(PthreadRWLock_ReadLock.self),
        measureNonContended(PthreadRWLock_WriteLock.self),
        measureNonContended(BiSemaphore.self),
    ]
    let col1Sep = format == .numbersChartData ? "," : ":"

    var result: String = ""
    result += "<mutex name>\(col1Sep) <lock+unlock time>\n"
    if format == .textPrintOut {
        result += "---\n"
    }
    for measurement in measurements.sorted(by: { $0.lockUnlockTime < $1.lockUnlockTime }) {
        result += "\(measurement.mutexType)\(col1Sep) \(measurement.lockUnlockTime)\n"
    }
    return result
}
