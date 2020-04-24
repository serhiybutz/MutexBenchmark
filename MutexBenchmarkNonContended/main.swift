//
//  main.swift
//  MutexBenchmarkNonContended
//
//  Created by Serge Bouts on 4/24/20.
//  Copyright © 2020 irizen.com. All rights reserved.
//

import Foundation
import XConcurrencyKit
import Mutexes

let iterations = 100_000
let subIterations = 1_000

typealias MeasurementSummary = (mutexType: BasicMutex.Type, lockUnlockTime: TimeInterval)

func measure<T: BasicMutex>(_ mutexType: T.Type) -> MeasurementSummary {
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
    return MeasurementSummary(mutexType, lockUnlockTimeMeter.averageExecutionTime / Double(subIterations))
}

enum RenderFormat {
    case numbersChartData
    case textPrintOut
}

func run(renderingAs format: RenderFormat = .textPrintOut) {
    let measurements: [MeasurementSummary] = [
        measure(OSUnfairLock.self),
        measure(NSLock.self),
        measure(NSRecursiveLock.self),
        measure(PthreadMutex.self),
        measure(PthreadRecursiveMutex.self),
        measure(PthreadRWLock_ReadLock.self),
        measure(PthreadRWLock_WriteLock.self),
        measure(BiSemaphore.self),
    ]
    let col1Sep = format == .numbersChartData ? "," : ":"
    print("<mutex name>\(col1Sep) <lock+unlock time>")
    if format == .textPrintOut {
        print("---")
    }
    for measurement in measurements.sorted(by: { $0.lockUnlockTime < $1.lockUnlockTime }) {
        print("\(measurement.mutexType)\(col1Sep) \(measurement.lockUnlockTime)")
    }
}

run(renderingAs: .numbersChartData)
