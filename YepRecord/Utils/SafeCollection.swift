//
//  SafeCollection.swift
//  Expandable
//
//  Created by DianQK on 8/18/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation

public struct SafeCollection<Base: Collection> { //: Collection {
    /// Returns a subsequence containing all but the given number of initial
    /// elements.
    ///
    /// If the number of elements to drop exceeds the number of elements in
    /// the sequence, the result is an empty subsequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropFirst(2))
    ///     // Prints "[3, 4, 5]"
    ///     print(numbers.dropFirst(10))
    ///     // Prints "[]"
    ///
    /// - Parameter n: The number of elements to drop from the beginning of
    ///   the sequence. `n` must be greater than or equal to zero.
    /// - Returns: A subsequence starting after the specified number of
    ///   elements.
    ///
    /// - Complexity: O(*n*), where *n* is the number of elements to drop from
    ///   the beginning of the sequence.
    public typealias SubSequence = Base.SubSequence
    public func dropFirst(_ n: Int) -> SubSequence {
        return _base.dropFirst(n)
    }

    fileprivate var _base: Base
    public init(_ base: Base) {
        _base = base
    }

    public typealias Index = Base.Index
    public var startIndex: Index {
        return _base.startIndex
    }

    public var endIndex: Index {
        return _base.endIndex
    }

    public subscript(index: Base.Index) -> Base.Iterator.Element? {
        if startIndex <= index && index < endIndex {
            return _base[index]
        }
        return nil
    }

    public subscript(bounds: Range<Base.Index>) -> Base.SubSequence? {
        if startIndex <= bounds.lowerBound && bounds.upperBound < endIndex {
            return _base[bounds]
        }
        return nil
    }

    var safe: SafeCollection<Base> { //Allows to chain ".safe" without side effects
        return self
    }
}

public extension Collection {
    var safe: SafeCollection<Self> {
        return SafeCollection(self)
    }
}
