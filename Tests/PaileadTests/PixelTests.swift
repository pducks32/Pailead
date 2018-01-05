//
//  PixelTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 11/29/17.
//

import XCTest
@testable import Pailead

extension XCTestCase {
    // We conform to LocalizedError in order to be able to output
    // a nice error message.
    public struct RequireError<T>: LocalizedError {
        let file: StaticString
        let line: UInt
        
        // It's important to implement this property, otherwise we won't
        // get a nice error message in the logs if our tests start to fail.
        public var errorDescription: String? {
            return "😱 Required value of type \(T.self) was nil at line \(line) in file \(file)."
        }
    }
    
    // Using file and line lets us automatically capture where
    // the expression took place in our source code.
    func require<T>(_ expression: @autoclosure () -> T?,
                    file: StaticString = #file,
                    line: UInt = #line) throws -> T {
        guard let value = expression() else {
            throw RequireError<T>(file: file, line: line)
        }
        
        return value
    }
}

class PixelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    func testInitizationWithComponentValues() {
        let pixel = Pixel(red: 21, green: 43, blue: 65)
        
        XCTAssertEqual(pixel.red, 21)
        XCTAssertEqual(pixel.green, 43)
        XCTAssertEqual(pixel.blue, 65)
    }
    
    func testInitizationWithDictionary() {
        let dictionary : [VBox.Axis: Pixel.SubValue] = [.red: 21, .green: 43]
        let pixel = Pixel(dictionary)
        
        XCTAssertEqual(pixel.red, 21)
        XCTAssertEqual(pixel.green, 43)
        
        // Goes to zero if not set
        XCTAssertEqual(pixel.blue, 0)
        
        let dictionaryAllZero : [VBox.Axis: Pixel.SubValue] = [:]
        let pixelAllZero = Pixel(dictionaryAllZero)
        XCTAssertEqual(pixelAllZero.red, 0)
        XCTAssertEqual(pixelAllZero.green, 0)
        XCTAssertEqual(pixelAllZero.blue, 0)
    }
    
    func testRawValueConversion() throws {
        let expectedComponents : [VBox.Axis: Pixel.SubValue] = [.red: 7, .green: 41, .blue: 6]
        
        let toRawValuePixel = Pixel(expectedComponents)
        XCTAssertEqual(toRawValuePixel.rawValue, toRawValuePixel.hashValue)
        
        XCTAssertEqual(toRawValuePixel.red, Pixel.pushAndPullValue(base: toRawValuePixel.rawValue, index: 2))
        XCTAssertEqual(toRawValuePixel.green, Pixel.pushAndPullValue(base: toRawValuePixel.rawValue, index: 1))
        XCTAssertEqual(toRawValuePixel.blue, Pixel.pushAndPullValue(base: toRawValuePixel.rawValue, index: 0))
        
        let fromRawValuePixel = try require(Pixel(rawValue: toRawValuePixel.rawValue))
        XCTAssertEqual(fromRawValuePixel.red, expectedComponents[.red])
        XCTAssertEqual(fromRawValuePixel.green, expectedComponents[.green])
        XCTAssertEqual(fromRawValuePixel.blue, expectedComponents[.blue])
    }
    
    func testSecretInitMethod() {
        let pixel = Pixel(red: 1, green: 2, blue: 3, rawValue: 4)
        XCTAssertEqual(pixel.red, 1)
        XCTAssertEqual(pixel.green, 2)
        XCTAssertEqual(pixel.blue, 3)
        XCTAssertEqual(pixel.rawValue, 4)
    }
    
    func testDescriptionValuesHaveCorrectValues() {
        let pixel = Pixel(red: 1, green: 2, blue: 3)
        XCTAssertEqual(pixel.description, "rgb(1, 2, 3)")
        XCTAssertEqual(pixel.debugDescription, "rgb(1, 2, 3, max: 255)")
    }
}
