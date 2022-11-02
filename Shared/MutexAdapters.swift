//
//  MutexAdapters.swift
//  MutexBenchmark
//
//  Created by Serhiy Butz on 4/24/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import Mutexes

final class PthreadRecursiveMutex: BasicMutex {
    // MARK: - State

    let mutex = PthreadMutex { $0.type = .recursive }

    // MARK: - Initialization

    required init() {}

    // MARK: - API

    @inline(__always)
    @inlinable
    func lock() { mutex.lock() }

    @inline(__always)
    @inlinable
    func unlock() { mutex.unlock() }
}

final class PthreadRWLock_ReadLock: BasicMutex {
    // MARK: - State

    let rwLock = PthreadRWLock()

    // MARK: - Initialization

    required init() {}

    // MARK: - API

    @inline(__always)
    @inlinable
    func lock() { rwLock.readLock() }

    @inline(__always)
    @inlinable
    func unlock() { rwLock.unlock() }
}

final class PthreadRWLock_WriteLock: BasicMutex {
    // MARK: - State

    let rwLock = PthreadRWLock()

    // MARK: - Initialization

    required init() {}

    // MARK: - API

    @inline(__always)
    @inlinable
    func lock() { rwLock.writeLock() }

    @inline(__always)
    @inlinable
    func unlock() { rwLock.unlock() }
}
