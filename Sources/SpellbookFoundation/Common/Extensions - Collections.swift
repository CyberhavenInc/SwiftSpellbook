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

// MARK: - Dictionary

extension Dictionary {
    public var reader: DictionaryReader<Key, Value> { .init(self) }
    
    /// Get the value in nested dictionary
    /// Specific cases:
    ///     - Nested Array:
    ///         - pass [1] to follow the 1-st item in the nested array
    ///         - pass [Int.max] to follow the last item in the nested array
    public subscript(codingPath codingPath: [DictionaryCodingKey]) -> Any? {
        try? reader.read(codingPath: codingPath, as: Any.self)
    }
    
    /// Get value in nested dictionary using dot-separated key path.
    /// Keys in dictionary at keyPath componenets must be of String type
    /// Specific cases:
    ///     - Nested Array:
    ///         - pass [1] to follow the 1-st item in the nested array
    ///         - pass [*] to follow the last item in the nested array
    public subscript(dotPath dotPath: String) -> Any? {
        try? reader.read(dotPath: dotPath, as: Any.self)
    }
}

extension Dictionary {
    public var writer: DictionaryWriter<Key, Value> { .init(self) }
    
    /// Inserts value in nested dictionary using CodingPath-separated key path
    public mutating func insert(value: Any, codingPath: [DictionaryCodingKey]) -> Bool {
        var writer = DictionaryWriter(self)
        let inserted = (try? writer.insert(value: value, codingPath: codingPath)) != nil
        if inserted {
            self = writer.dictionary
        }
        return inserted
    }
    
    /// Inserts value in nested dictionary using dot-separated key path
    public mutating func insert(value: Any, dotPath: String) -> Bool {
        var writer = DictionaryWriter(self)
        let inserted = (try? writer.insert(value: value, dotPath: dotPath)) != nil
        if inserted {
            self = writer.dictionary
        }
        return inserted
    }
}

extension Dictionary {
    /// Removes the all elements from the array and returns them.
    public mutating func popAll(keepingCapacity: Bool = false) -> Self {
        guard !isEmpty else { return [:] }
        let removed = self
        removeAll(keepingCapacity: keepingCapacity)
        return removed
    }
    
    /// Removes the all elements from the array and returns them.
    public mutating func popAll(where: (Element) -> Bool) -> Self {
        guard !isEmpty else { return [:] }
        var removed: [Key: Value] = [:]
        for element in self {
            if `where`(element) {
                removeValue(forKey: element.key)
                removed[element.key] = element.value
            }
        }
        return removed
    }
}

// MARK: - Array

extension Array {
    public mutating func mutateElements(mutate: (inout Element) throws -> Void) rethrows {
        self = try mutatingMap(mutate: mutate)
    }
    
    /// Creates new array by appending `newElement` to the end of current one.
    public func appending(_ newElement: Element) -> Self {
        var appended = self
        appended.append(newElement)
        return appended
    }
}

extension Array {
    /// Bounds-safe access to the element at index.
    public subscript(safe index: Index) -> Element? {
        index < count ? self[index] : nil
    }
    
    /// If exists, removes the first element from the array and returns it. Otherwise returns `nil`.
    /// Simply combination of `isEmpty` + `removeFirst`.
    public mutating func popFirst() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
    
    /// Removes the all elements from the array and returns them.
    public mutating func popAll(keepingCapacity: Bool = false) -> Self {
        guard !isEmpty else { return [] }
        let removed = self
        removeAll(keepingCapacity: keepingCapacity)
        return removed
    }
    
    /// Removes the all elements from the array and returns them.
    public mutating func popAll(where: (Element) -> Bool) -> Self {
        guard !isEmpty else { return [] }
        var removed: [Element] = []
        for (offset, element) in enumerated().reversed() {
            if `where`(element) {
                removed.append(remove(at: offset))
            }
        }
        return removed.reversed()
    }
}

// MARK: - Collection

extension Collection {
    public func mutatingMap(mutate: (inout Element) throws -> Void) rethrows -> [Element] {
        try map {
            var mutated = $0
            try mutate(&mutated)
            return mutated
        }
    }
}

extension RangeReplaceableCollection {
    @discardableResult
    public mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let idx = try firstIndex(where: predicate) else { return nil }
        let element = self[idx]
        remove(at: idx)
        return element
    }
}
