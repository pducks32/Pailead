//
//  PriorityQueue.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import Foundation

public class PriorityQueue<Element> {
    
    var elements : [Element]
    var isOrderedBefore : (Element, Element) -> Bool
    
    public init(_ elements : [Element] = [], comparator : @escaping (Element, Element) -> Bool) {
        self.elements = elements
        self.isOrderedBefore = comparator
        sort()
    }
    
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingLargestValue : @escaping (Element) -> ThingToCompare) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            compareUsingLargestValue(first) > compareUsingLargestValue(second)
        }
        sort()
    }
    
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingLargestValue : KeyPath<Element, ThingToCompare>) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            first[keyPath: compareUsingLargestValue] > second[keyPath: compareUsingLargestValue]
        }
        sort()
    }
    
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingSmallestValue : @escaping (Element) -> ThingToCompare) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            compareUsingSmallestValue(first) < compareUsingSmallestValue(second)
        }
        sort()
    }
    
    public init<ThingToCompare : Comparable>(_ elements : [Element] = [], compareUsingSmallestValue : KeyPath<Element, ThingToCompare>) {
        self.elements = elements
        self.isOrderedBefore = { first, second in
            first[keyPath: compareUsingSmallestValue] < second[keyPath: compareUsingSmallestValue]
        }
        sort()
    }
    
    public func offer(_ element : Element) {
        if let insertionIndex = elements.index(where: { self.isOrderedBefore(element, $0) }) {
            elements.insert(element, at: insertionIndex)
        } else {
            elements.append(element)
        }
    }
    
    public func poll() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }
        
        return elements.removeFirst()
    }
    
    public func peek() -> Element {
        return elements[0]
    }
    
    public func feed() -> [Element] {
        return elements
    }
    
    public var count : Int {
        return elements.count
    }
    
    public var isEmpty : Bool {
        return elements.isEmpty
    }
    
    private func sort() {
        elements.sort(by: isOrderedBefore)
    }
}
