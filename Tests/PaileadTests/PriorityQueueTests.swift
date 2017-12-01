//
//  PriorityQueueTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import XCTest
@testable import Pailead

class PriorityQueueTests: XCTestCase {
    
    func testInitialization() {
        let unsortedItems = ["A", "ABCD", "AB", "ABCDE", "ABC"]
        let pqLarge = PriorityQueue(unsortedItems, compareUsingLargestValue: \String.count)
        let pqSmall = PriorityQueue(unsortedItems, compareUsingSmallestValue: \String.count)
        
        let pqLargeSuperLong = PriorityQueue(unsortedItems, comparator: { first, second in
            return first.count > second.count
        })
        let pqSmallSuperLong = PriorityQueue(unsortedItems, comparator: { first, second in
            return first.count < second.count
        })
        
        let pqLargeLong = PriorityQueue(unsortedItems, compareUsingLargestValue: { $0.count })
        let pqSmallLong = PriorityQueue(unsortedItems, compareUsingSmallestValue: { $0.count })
        
        // They do the opposite things
        XCTAssertEqual(pqSmall.feed(), pqLarge.feed().reversed())
        XCTAssertEqual(pqSmallLong.feed(), pqLargeLong.feed().reversed())
        XCTAssertEqual(pqSmallSuperLong.feed(), pqLargeSuperLong.feed().reversed())
        
        // They equal eachother
        XCTAssertEqual(pqSmall.feed(), pqSmallLong.feed())
        XCTAssertEqual(pqSmallLong.feed(), pqSmallSuperLong.feed())
    }
    
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
    
    func testElementsIsEmpty() {
        let unsortedItems = ["A"]
        
        let pqSmall = PriorityQueue(unsortedItems, compareUsingSmallestValue: \String.count)
        XCTAssertFalse(pqSmall.isEmpty)
        XCTAssertEqual(pqSmall.count, 1)
        XCTAssertEqual(pqSmall.poll(), "A")
        
        // When finally empty
        XCTAssertTrue(pqSmall.isEmpty)
        XCTAssertEqual(pqSmall.count, 0)
        XCTAssertNil(pqSmall.poll())
    }
}
