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

import Combine

@available(macOS 10.15, iOS 13, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func eraseToAnyPublisher(attachingContext context: Any?) -> AnyPublisher<Output, Failure> {
        ProxyPublisher(self, context: context).eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: Equatable, Failure == Never {
    /// Publishes value changes in order it receives the values
    /// - Warning: When using `mapToChange`, be sure it receives the input in right order.
    /// Avoid use `receive(on:)` with concurrent queues in upstream publishers.
    public var mapToChange: AnyPublisher<Change<Output>, Never> {
        let oldValue = Atomic<Output?>(wrappedValue: nil)
        
        let subject = PassthroughSubject<Change<Output>, Never>()
        var proxy = ProxyPublisher(subject)
        proxy.context = sink {
            if let oldValue = oldValue.exchange($0), let change = Change(old: oldValue, new: $0) {
                subject.send(change)
            }
        }
        return proxy.eraseToAnyPublisher()
    }
}
