//
//  main.swift
//  MutexBenchmarkContended
//
//  Created by Serge Bouts on 4/24/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XConcurrencyKit
import Mutexes

typealias MeasurementSummary = (mutexType: BasicMutex.Type, nanotime: UInt64, nanotime2: UInt64)

func measure<T: BasicMutex>(_ mutexType: T.Type, exec: () -> Void = {}) -> MeasurementSummary {
    let sut = mutexType.init()
    let concurrentThreads = 10
    let iterations = 10_000

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
    return MeasurementSummary(
        mutexType,
        summary.maxNanosecs,
        summary.minNanosecs)
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
        measure(PthreadRWLock_WriteLock.self),
        measure(BiSemaphore.self),
    ]
    let col1Sep = format == .numbersChartData ? "," : ":"
    print("<mutex name>\(col1Sep) <lock+unlock time, contended>, <lock+unlock time, non-contended>")
    if format == .textPrintOut {
        print("---")
    }
    for measurement in measurements.sorted(by: { $0.nanotime < $1.nanotime }) {
        print("\(measurement.mutexType)\(col1Sep) \(measurement.nanotime), \(measurement.nanotime2)")
    }
}

run(renderingAs: .textPrintOut)
