//
//  SplitTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 12/9/17.
//

import XCTest
@testable import Pailead

class SplitTests: XCTestCase {
    
    // MARK: Build from Contents Tests
    let shouldAppearOnce = Pixel(red: 215, green: 6, blue: 90)
    let shouldAppearTwice = Pixel(red: 7, green: 14, blue: 231)
    let shouldAppearThrice = Pixel(red: 15, green: 60, blue: 9)
    let shouldAppearOnceToo = Pixel(red: 9, green: 14, blue: 231)
    
    lazy var vboxInitialContents : [Pixel] = {
        return [
            shouldAppearOnce,
            shouldAppearThrice,
            shouldAppearTwice,
            shouldAppearOnceToo,
            shouldAppearTwice,
            shouldAppearThrice,
            shouldAppearThrice
        ]
    }()
    
    lazy var vbox : VBox = {
        return VBox(pixels: vboxInitialContents)
    }()
    
    lazy var firstSplit : (VBox, VBox) = {
        return vbox.split()
    }()
    
    func testSplitsDontOverlap() {
        let (alpha, beta) = firstSplit
        let hasMinPixel = alpha.covers(beta.minPixel)
        let hasMaxPixel = alpha.covers(beta.maxPixel)
        
        XCTAssertFalse(hasMinPixel)
        XCTAssertFalse(hasMaxPixel)
    }
    
    func testSplitDoNotSharePixels() {
        let (alpha, beta) = firstSplit
        let alphaPixels = Set(alpha.contents.keys)
        let betaPixels = Set(beta.contents.keys)
        
        XCTAssertTrue(alphaPixels.isDisjoint(with: betaPixels))
    }
    
    func pixelThatIsGreaterThan(_ testPixel : Pixel) -> ((Pixel) -> Bool) {
        return { (pixel) -> Bool in
            return testPixel.red < pixel.red || testPixel.green < pixel.green || testPixel.blue < pixel.blue
        }
    }
    
    func pixelThatIsLesserThan(_ testPixel : Pixel) -> ((Pixel) -> Bool) {
        return { (pixel) -> Bool in
            return testPixel.red > pixel.red || testPixel.green > pixel.green || testPixel.blue > pixel.blue
        }
    }
    
    func pixelIsOutside(_ minPixel : Pixel, and maxPixel : Pixel) -> ((Pixel) -> Bool) {
        let pixelIsLessThanMin = pixelThatIsLesserThan(minPixel)
        let pixelIsMoreThanMax = pixelThatIsGreaterThan(maxPixel)
        return { (pixel) -> Bool in
            return pixelIsLessThanMin(pixel) || pixelIsMoreThanMax(pixel)
        }
    }
    
    func testSplitBoxesHaveCorrectBounds() {
        let (alpha, beta) = firstSplit
        
        let alphaPixels = alpha.contents.keys
        let alphaMinPixel = alpha.minPixel
        let alphaMaxPixel = alpha.maxPixel
        
        let isThereAnAlphaPixelOutsideBounds = alphaPixels.contains(where: pixelIsOutside(alphaMinPixel, and: alphaMaxPixel))
        
        let betaPixels = beta.contents.keys
        let betaMinPixel = beta.minPixel
        let betaMaxPixel = beta.maxPixel
        
        let isThereABetaPixelOutsideBounds = betaPixels.contains(where: pixelIsOutside(betaMinPixel, and: betaMaxPixel))
        
        XCTAssertFalse(isThereAnAlphaPixelOutsideBounds)
        XCTAssertFalse(isThereABetaPixelOutsideBounds)
    }
}
