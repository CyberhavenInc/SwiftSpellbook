//  MIT License
//
//  Copyright (c) 2022 Alkenso (Vladimir Vashurkin)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

extension NSLocking {
    public func withLock<R>(_ body: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try body()
    }
}

extension os_unfair_lock {
    public mutating func withLock<R>(_ body: () throws -> R) rethrows -> R {
        os_unfair_lock_lock(&self)
        defer { os_unfair_lock_unlock(&self) }
        return try body()
    }
}

extension pthread_rwlock_t {
    public mutating func withReadLock<R>(_ body: () throws -> R) rethrows -> R {
        pthread_rwlock_rdlock(&self)
        defer { pthread_rwlock_unlock(&self) }
        return try body()
    }
    
    public mutating func withWriteLock<R>(_ body: () throws -> R) rethrows -> R {
        pthread_rwlock_wrlock(&self)
        defer { pthread_rwlock_unlock(&self) }
        return try body()
    }
}
