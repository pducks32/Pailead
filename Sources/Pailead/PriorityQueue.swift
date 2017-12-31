//
//  PriorityQueue.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import Foundation

/// Queue that orders given elements by a priority function
public class PriorityQueue<Element> {
    /// Contents of the queue
    private var elements : [Element]
    
    /// Predicate to determine which element comes first
    var isOrderedBefore : (Element, Element) -> Bool
    
    /// New queue with given elements and predicate
    ///
    /// - Parameters:
    ///   - elements: Contents of the queue
    ///   - isOrderedBefore: Predicate to determine which element comes first
    public init(_ elements : [Element] = [], isOrderedBefore comparator : @escaping (Element, Element) -> Bool) {
        self.elements = elements
        self.isOrderedBefore = comparator
        sort()
    }
    
    /// New queue that orders elements on a `ThingToCompare` transform by greatest value
    ///
    /// - Parameters:
    ///   - elements: Contents of the queue
    ///   - compareUsingLargestValue: Returns a comparable `ThingToCompare` priority for a given element
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingLargestValue : @escaping (Element) -> ThingToCompare) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            compareUsingLargestValue(first) > compareUsingLargestValue(second)
        }
        sort()
    }
    
    /// New queue that orders elements by a given property that is comparable
    ///
    /// - Parameters:
    ///   - elements: Contents of the queue
    ///   - compareUsingLargestValue: Keypath that provides what to prioritze by largest value
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingLargestValue : KeyPath<Element, ThingToCompare>) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            first[keyPath: compareUsingLargestValue] > second[keyPath: compareUsingLargestValue]
        }
        sort()
    }
    
    /// New queue that orders elements on a `ThingToCompare` transform by greatest value
    ///
    /// - Parameters:
    ///   - elements: Contents of the queue
    ///   - compareUsingSmallestValue: Returns a comparable `ThingToCompare` priority for a given element
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingSmallestValue : @escaping (Element) -> ThingToCompare) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            compareUsingSmallestValue(first) < compareUsingSmallestValue(second)
        }
        sort()
    }
    
    /// New queue that orders elements by a given property that is comparable
    ///
    /// - Parameters:
    ///   - elements: Contents of the queue
    ///   - compareUsingSmallestValue: Keypath that provides what to prioritze by smallest value
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingSmallestValue : KeyPath<Element, ThingToCompare>) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            first[keyPath: compareUsingSmallestValue] < second[keyPath: compareUsingSmallestValue]
        }
        sort()
    }
    
    /// Adds another element to the queue in correct order
    public func offer(_ element : Element) {
        if let insertionIndex = elements.index(where: { self.isOrderedBefore(element, $0) }) {
            elements.insert(element, at: insertionIndex)
        } else {
            elements.append(element)
        }
    }
    
    /// Removes the next element in the queue
    public func poll() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }
        
        return elements.removeFirst()
    }
    
    /// Returns (but not removes) the next element in the queue
    public func peek() -> Element {
        return elements[0]
    }
    
    /// Returns the queue's elements
    ///
    /// - Returns: Each element in the queue in proper order
    public func feed() -> [Element] {
        return elements
    }
    
    /// Number of elements in queue
    public var count : Int {
        return elements.count
    }
    
    /// Is the queue empty
    public var isEmpty : Bool {
        return elements.isEmpty
    }
    
    /// Sorts using the given predicate
    private func sort() {
        elements.sort(by: isOrderedBefore)
    }
}
