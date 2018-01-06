//
//  HSLConverterTest.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 1/6/18.
//

import XCTest
@testable import Pailead

class HSLConverterTests : XCTestCase {
    func testReversability() {
        let converter = HSLConverter()
        let subject = Pixel(red: 123, green: 45, blue: 67)
        let hsl = converter.hslFor(subject)
        let reversed = converter.pixelFor(hue: hsl.0, saturation: hsl.1, lumience: hsl.2)
        
        XCTAssertEqual(subject.red, reversed.red)
        XCTAssertEqual(subject.green, reversed.green)
        XCTAssertEqual(subject.blue, reversed.blue)
    }
}

