//
//  ContendedBenchmarking.swift
//  MutexBenchmarkContended
//
//  Created by Serhiy Butz on 4/25/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XConcurrencyKit
import Mutexes

typealias ContendedMeasurementSummary = (mutexType: BasicMutex.Type, nanotime: UInt64, nanotime2: UInt64)

func measureContended<T: BasicMutex>(_ mutexType: T.Type, exec: () -> Void = {}) -> ContendedMeasurementSummary {
    let concurrentThreads = 10
    let iterations = 10_000

    let sut = mutexType.init()

    let benchmark = MutlithreadBenchmark()

    let mutlithreadTimeMeter = MultithreadMachExecutionPreservingTimeMeter()

    benchmark.perform(
        threads: concurrentThreads,
        runs: iterations,
        subject: {
            sut.lock()
            sut.unlock()
            NanoUtils.spinDelay(for: 0)
    },
        multithreadExecutionTimeMeter: mutlithreadTimeMeter,
        overheadAdjustment: {
            NanoUtils.spinDelay(for: 0)
    })

    let summary = mutlithreadTimeMeter.kMeansReport.generate()
    return ContendedMeasurementSummary(
        mutexType,
        summary.maxNanosecs,
        summary.minNanosecs)
}

func runContended(renderingAs format: RenderFormat = .textPrintOut) -> String {
    let measurements: [ContendedMeasurementSummary] = [
        measureContended(OSUnfairLock.self),
        measureContended(NSLock.self),
        measureContended(NSRecursiveLock.self),
        measureContended(PthreadMutex.self),
        measureContended(PthreadRecursiveMutex.self),
        measureContended(PthreadRWLock_WriteLock.self),
        measureContended(BiSemaphore.self),
    ]
    let col1Sep = format == .numbersChartData ? "," : ":"

    var result: String = ""

    result += "<mutex name>\(col1Sep) <lock+unlock time, contended>, <lock+unlock time, non-contended>\n"
    if format == .textPrintOut {
        result += "---\n"
    }
    for measurement in measurements.sorted(by: { $0.nanotime < $1.nanotime }) {
        result += "\(measurement.mutexType)\(col1Sep) \(measurement.nanotime), \(measurement.nanotime2)\n"
    }

    return result
}
