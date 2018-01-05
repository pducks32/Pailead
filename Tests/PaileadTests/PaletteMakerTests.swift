//
//  PaletteMakerTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 1/4/18.
//

import XCTest
@testable import Pailead

class PaletteMakerTests : XCTestCase {
    let maker = Palette(baseImageSwatches: [])
    
    func testNilSwatches() {
        XCTAssertNil(maker.vibrantSwatch)
        XCTAssertNil(maker.mutedSwatch)
        
        XCTAssertNil(maker.lightVibrantSwatch)
        XCTAssertNil(maker.lightMutedSwatch)
        
        XCTAssertNil(maker.darkVibrantSwatch)
        XCTAssertNil(maker.darkMutedSwatch)
    }
    
    func testInvertedDiff() {
        XCTAssertEqual(maker.invertDiff(value: 10, targetValue: 10), 1)
        
        // Farther apart is lower that closer together values
        XCTAssertLessThan(maker.invertDiff(value: 10, targetValue: 25), maker.invertDiff(value: 10, targetValue: 20))
    }
    
    func testWeightedMean() {
        XCTAssertEqual(maker.weightedMean((5, 3), (10, 1), (0, 4)), 3.125)
    }
}
