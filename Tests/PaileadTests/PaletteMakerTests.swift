//
//  PaletteMakerTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 1/4/18.
//

import XCTest
@testable import Pailead

class PaletteMakerTests : XCTestCase {
    func testNilSwatches() {
        let maker = Pailead.PaletteMaker(swatches: [])
        XCTAssertNil(maker.vibrantSwatch)
        XCTAssertNil(maker.mutedSwatch)
        
        XCTAssertNil(maker.lightVibrantSwatch)
        XCTAssertNil(maker.lightMutedSwatch)
        
        XCTAssertNil(maker.darkVibrantSwatch)
        XCTAssertNil(maker.darkMutedSwatch)
    }
}
