//
//  PriorityQueueTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import XCTest
@testable import Pailead

class PriorityQueueTests: XCTestCase {
    func testItemsAreSortedWhenInitialized() {
        let unsortedItems = ["A", "ABCD", "AB", "ABCDE", "ABC"]
        
        let pqLarge = PriorityQueue(unsortedItems, compareUsingLargestValue: \String.count)
        XCTAssertEqual(pqLarge.feed(), ["ABCDE", "ABCD", "ABC", "AB", "A"])
        
        let pqSmall = PriorityQueue(unsortedItems, compareUsingSmallestValue: \String.count)
        XCTAssertEqual(pqSmall.feed(), ["A", "AB", "ABC", "ABCD", "ABCDE"])
    }
    
    func testItemsAreSortedWhenAdded() {
        let unsortedItems = ["ABCD", "AB", "ABCDE", "ABC"]
        
        let pqSmall = PriorityQueue(unsortedItems, compareUsingSmallestValue: \String.count)
        
        // When the value will come at an index
        XCTAssertEqual(pqSmall.peek(), "AB")
        pqSmall.offer("A")
        XCTAssertEqual(pqSmall.peek(), "A")
        
        // When the value will come at the end
        XCTAssertEqual(pqSmall.feed().last!, "ABCDE")
        pqSmall.offer("ABCDEF")
        XCTAssertEqual(pqSmall.feed().last!, "ABCDEF")
    }
    
    func testItemIsRemovedWhenPolled() {
        let unsortedItems = ["A", "ABCD", "AB", "ABCDE", "ABC"]
        
        let pqSmall = PriorityQueue(unsortedItems, compareUsingSmallestValue: \String.count)
        XCTAssertEqual(pqSmall.peek(), "A")
        XCTAssertEqual(pqSmall.poll(), "A")
        XCTAssertEqual(pqSmall.peek(), "AB")
    }
    
}
