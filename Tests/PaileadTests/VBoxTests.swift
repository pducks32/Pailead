//
//  VBoxTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 11/21/17.
//

import XCTest
@testable import Pailead

class VBoxAxisTests : XCTestCase {
    func testDescriptions() {
        XCTAssertEqual(VBox.Axis.red.description, "red")
        XCTAssertEqual(VBox.Axis.green.description, "green")
        XCTAssertEqual(VBox.Axis.blue.description, "blue")
    }
}

class VBoxTests: XCTestCase {
    
    // MARK: Build from Contents Tests
    let shouldAppearOnce = Pixel(red: 215, green: 6, blue: 90)
    let shouldAppearTwice = Pixel(red: 7, green: 14, blue: 231)
    let shouldAppearThrice = Pixel(red: 15, green: 60, blue: 9)
    let shouldAppearOnceToo = Pixel(red: 9, green: 14, blue: 231)
    
    var subjectInitialContents : [Pixel] = []
    var subject : VBox!
    
    override func setUp() {
        subjectInitialContents = [
            shouldAppearOnce,
            shouldAppearThrice,
            shouldAppearTwice,
            shouldAppearOnceToo,
            shouldAppearTwice,
            shouldAppearThrice,
            shouldAppearThrice
        ]
        
        subject = VBox(pixels: subjectInitialContents)
    }
    
    func testInitWithDictionary() {
        let theInitialContents : [Pixel: Int] = [
            shouldAppearOnce: 1,
            shouldAppearThrice: 3,
            shouldAppearTwice: 2,
            shouldAppearOnceToo: 1
        ]
        let dictionarySubject = VBox(pixels: theInitialContents)
        
        XCTAssertEqual(subject, dictionarySubject)
    }
    
    // Min Pixel
    func testMinPixel() {
        let wantedMinPixel = Pixel(red: 7, green: 6, blue: 9)
        XCTAssertEqual(subject.minPixel, wantedMinPixel)
    }
    
    // Max Pixel
    func testMaxPixel() {
        let wantedMaxPixel = Pixel(red: 215, green: 60, blue: 231)
        XCTAssertEqual(subject.maxPixel, wantedMaxPixel)
    }
    
    func testPopulations() {
        let expectedPopulations = [
            shouldAppearOnce: 1,
            shouldAppearOnceToo: 1,
            shouldAppearTwice: 2,
            shouldAppearThrice: 3
        ]
        
        XCTAssertEqual(subject.contents, expectedPopulations)
    }
    
    // Initial, Final, Extremities
    func testInitialValues() {
        XCTAssertEqual(subject.inital(in: .red), 7)
        XCTAssertEqual(subject.inital(in: .green), 6)
        XCTAssertEqual(subject.inital(in: .blue), 9)
    }
    
    func testFinalValues() {
        XCTAssertEqual(subject.final(in: .red), 215)
        XCTAssertEqual(subject.final(in: .green), 60)
        XCTAssertEqual(subject.final(in: .blue), 231)
    }
    
    func testExtremitiesValues() {
        let wantedMinPixel = Pixel(red: 7, green: 6, blue: 9)
        let wantedMaxPixel = Pixel(red: 215, green: 60, blue: 231)
        
        VBox.Axis.all.forEach({ axis in
            let actual = subject.extremities(in: axis)
            let expected = (lower: wantedMinPixel[axis], upper: wantedMaxPixel[axis])
            
            XCTAssertEqual(actual.lower, expected.lower, "Lower Pixel#\(axis) does not match.")
            XCTAssertEqual(actual.upper, expected.upper, "Upper Pixel#\(axis) does not match.")
        })
    }
    
    func testLengthValues() {
        XCTAssertEqual(subject.redLength, 208)
        XCTAssertEqual(subject.greenLength, 54)
        XCTAssertEqual(subject.blueLength, 222)
    }
    
    func testExtentValues() {
        XCTAssertEqual(subject.redExtent, 208 + 1)
        XCTAssertEqual(subject.greenExtent, 54 + 1)
        XCTAssertEqual(subject.blueExtent, 222 + 1)
    }
    
    // Volume
    func testVolume() {
        let expectedVolume = (208 + 1) * (54 + 1) * (222 + 1)
        XCTAssertEqual(subject.volume, expectedVolume)
    }
    
    // Contains
    func testContains() {
        XCTAssertTrue(subject.contains(shouldAppearOnce))
        
        
        let doesNotExistInBox = Pixel(red: 123, green: 102, blue: 101)
        XCTAssertFalse(subject.contains(doesNotExistInBox))
    }
    
    // Covers
    func testCoversExtrema() {
        let wantedMinPixel = Pixel(red: 7, green: 6, blue: 9)
        let wantedMaxPixel = Pixel(red: 215, green: 60, blue: 231)
        
        XCTAssertTrue(subject.covers(wantedMinPixel), "VBox doesn't cover minPixel")
        XCTAssertTrue(subject.covers(wantedMaxPixel), "VBox doesn't cover maxPixel")
    }
    
    func testCoversPixel() {
        XCTAssertTrue(subject.covers(shouldAppearOnce))
        
        let randomCoveredPixel = Pixel(red: 44, green: 31, blue: 101)
        XCTAssertTrue(subject.covers(randomCoveredPixel))
        
        let randomNotCoveredPixel = Pixel(red: 1, green: 31, blue: 101)
        XCTAssertFalse(subject.covers(randomNotCoveredPixel))
    }
    
    func testCoversPixelInDimension() {
        XCTAssertTrue(subject.covers(value: shouldAppearOnce.red, in: .red))
        XCTAssertTrue(subject.covers(value: shouldAppearOnce.green, in: .green))
        XCTAssertTrue(subject.covers(value: shouldAppearOnce.blue, in: .blue))
        
        let blueIsGoodRedIsBad = Pixel(red: 1, green: 31, blue: 101)
        // Blue is good
        XCTAssertTrue(subject.covers(value: blueIsGoodRedIsBad.blue, in: .blue))
        // Red is bad
        XCTAssertFalse(subject.covers(value: blueIsGoodRedIsBad.red, in: .red))
    }
    
    // Longest Dimension
    func testLongestDimension() {
        XCTAssertEqual(subject.longestDimension, .blue)
    }
    
    func testAveragePoint() {
        let averageRed = round(Double(215+(7*2)+(15*3)+9)/7.0)
        let averageGreen = round(Double(6+(14*2)+(60*3)+14)/7.0)
        let averageBlue = round(Double(90+(231*2)+(9*3)+231)/7.0)
        let averagePixel = Pixel(red: Int(averageRed), green: Int(averageGreen), blue: Int(averageBlue))
        
        XCTAssertEqual(subject.average(), averagePixel)
    }
    
    func testHashValueIsUnique() {
        let alphaPixel = Pixel(red: 1, green: 2, blue: 3)
        let betaPixel = Pixel(red: 4, green: 5, blue: 6)
        let first = VBox(min: alphaPixel, max: betaPixel, contents: [:])
        let second = VBox(min: betaPixel, max: alphaPixel, contents: [:])
        XCTAssertEqual(first, second)
    }
    
    // Midpoint
    func testMidpoint() {
        let minPixel = Pixel(red: 5, green: 7, blue: 0)
        let maxPixel = Pixel(red: 15, green: 28, blue: 55)
        let vbox = VBox(min: minPixel, max: maxPixel, contents: [:])
        let expectedMidpoint = Pixel(red: 10, green: 17, blue: 27)
        
        XCTAssertEqual(vbox.midpoint(in: .red), expectedMidpoint.red)
        XCTAssertEqual(vbox.midpoint(in: .green), expectedMidpoint.green)
        XCTAssertEqual(vbox.midpoint(in: .blue), expectedMidpoint.blue)
        
    }
    
    // Average Point
    // Median Along Dimensions
    //   First Slice has everything
    //   Last Slice has everything
    //   Slice is exactly on half average
    // Split
}
