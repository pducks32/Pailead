//
//  PaletteMakerPictureTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 1/4/18.
//

import XCTest
@testable import Pailead

func XCTAssertWithin<Thing : Comparable>(_ actual : Thing, within : (Thing, Thing), file : StaticString = #file, line : UInt = #line) {
    XCTAssertGreaterThan(actual, within.0, file: file, line: line)
    XCTAssertLessThan(actual, within.1, file: file, line: line)
}

func XCTAssertWithin<Thing : Comparable>( _ actual : Thing, withinOrOn : (Thing, Thing), file : StaticString = #file, line : UInt = #line) {
    XCTAssertGreaterThanOrEqual(actual, withinOrOn.0, file: file, line: line)
    XCTAssertLessThanOrEqual(actual, withinOrOn.1, file: file, line: line)
}

class PaletteMakerPictureTests: XCTestCase {
    var image : Image!
    var processingExpectation : XCTestExpectation!
    var swatches : Set<Swatch> = []
    var isSetup = false
    
    override func setUp() {
        if !isSetup {
            let bundle = Bundle(for: PaletteMakerPictureTests.self)
            #if os(iOS)
                image = UIImage(named: "flower.jpg", in: bundle, compatibleWith: nil)!
            #elseif os(macOS)
                image = bundle.image(forResource: NSImage.Name("flower.jpg"))!
            #endif
            
            processingExpectation = XCTestExpectation(description: "Processing image")
            Pailead.extractTop(16, from: image) { (someSwatches : Set<Swatch>) in
                self.swatches = someSwatches
                self.processingExpectation.fulfill()
            }
            isSetup = true
        }
        
        wait(for: [processingExpectation], timeout: 20)
    }
    
    func luminance(of swatch : Swatch) -> Float {
        return HSLConverter().hslFor(swatch.pixel).2
    }
    
    func saturation(of swatch : Swatch) -> Float {
        return HSLConverter().hslFor(swatch.pixel).1
    }
    
    func testSwatchesAreInRange () {
        let maker = Palette(baseImageSwatches: swatches)
        if let darkVibrantSwatch = maker.darkVibrantSwatch {
            print("Dark Vibrant Found")
            XCTAssertWithin(self.luminance(of: darkVibrantSwatch), withinOrOn: (0, 0.45))
            XCTAssertWithin(self.saturation(of: darkVibrantSwatch), withinOrOn: (0.35, 1))
        }
        if let vibrantSwatch = maker.vibrantSwatch {
            print("Vibrant Found")
            XCTAssertWithin(self.luminance(of: vibrantSwatch), withinOrOn: (0.3, 0.7))
            XCTAssertWithin(self.saturation(of: vibrantSwatch), withinOrOn: (0.35, 1))
        }
        if let lightVibrantSwatch = maker.lightVibrantSwatch {
            print("Light Vibrant Found")
            XCTAssertWithin(self.luminance(of: lightVibrantSwatch), withinOrOn: (0.55, 1))
            XCTAssertWithin(self.saturation(of: lightVibrantSwatch), withinOrOn: (0.35, 1))
        }
        
        if let darkMutedSwatch = maker.darkMutedSwatch {
            print("Dark Muted Found")
            XCTAssertWithin(self.luminance(of: darkMutedSwatch), withinOrOn: (0, 0.45))
            XCTAssertWithin(self.saturation(of: darkMutedSwatch), withinOrOn: (0, 0.4))
        }
        if let mutedSwatch = maker.mutedSwatch {
            print("Muted Found")
            XCTAssertWithin(self.luminance(of: mutedSwatch), withinOrOn: (0.3, 0.7))
            XCTAssertWithin(self.saturation(of: mutedSwatch), withinOrOn: (0, 0.4))
        }
        if let lightMutedSwatch = maker.lightMutedSwatch {
            print("Light Muted Found")
            XCTAssertWithin(self.luminance(of: lightMutedSwatch), withinOrOn: (0.55, 1))
            XCTAssertWithin(self.saturation(of: lightMutedSwatch), withinOrOn: (0, 0.4))
        }
    }
}
