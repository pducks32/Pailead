//
//  MMCQTests.swift
//  PaileadTests
//
//  Created by Patrick Metcalfe on 12/9/17.
//

import XCTest
@testable import Pailead

#if os(macOS)
    import AppKit
    public typealias Image = NSImage
    public typealias Color = NSColor
#elseif os(iOS)
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
#endif

extension Image {
    var pixelSize : CGSize {
        #if os(macOS)
            guard let firstRepresentaion = self.representations.first else {
                fatalError("NSImage#pixelSize - image does not have any representations")
            }
            let height = firstRepresentaion.pixelsHigh
            let width = firstRepresentaion.pixelsWide
            return CGSize(width: width, height: height)
        #elseif os(iOS)
            return self.size.applying(CGAffineTransform(scaleX: self.scale, y: self.scale))
        #endif
    }
}

public extension Image {
    public typealias PixelFormat = UInt8
    public func pixelData() -> [PixelFormat]? {
        let componentCount = 4
        let size = self.pixelSize
        let dataSize = size.width * size.height * CGFloat(componentCount)
        var pixelData = [PixelFormat](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = MemoryLayout<PixelFormat>.size * 8
        let bitsPerPixel = componentCount * bitsPerComponent
        let bytesPerPixel = bitsPerPixel / 8
        
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerPixel * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        #if os(iOS)
            guard let cgImage = self.cgImage else { return nil }
        #elseif os(macOS)
            guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        #endif
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}

class BlockMMCQProcessingDelegate : MMCQProcessingDelegate {
    var onDidStart : ((VBox) -> Void)?
    var onDidSplit : ((VBox, VBox) -> Void)?
    var onDidFinish : (() -> Void)?
    
    func mmcq(_ mmcq: ModifiedMedianCutQuantizer, didStartWith vbox: VBox) {
        self.onDidStart?(vbox)
    }
    
    func mmcq(_ mmcq: ModifiedMedianCutQuantizer, didSplitBox: VBox, into: (VBox, VBox)) {
        self.onDidSplit?(into.0, into.1)
    }
    
    func mmcqDidFinishProcessing(_ mmcq: ModifiedMedianCutQuantizer) {
        self.onDidFinish?()
    }
}

class MMCQTests: XCTestCase {
    
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
    
    var mmcq : ModifiedMedianCutQuantizer!
    
    override func setUp() {
        mmcq = ModifiedMedianCutQuantizer(numberOfSwatches: 3, pixels: vboxInitialContents)
    }
    
    func testStartsWithACompleteVBox() {
        
        let startVBox = VBox(pixels: [
            shouldAppearOnce: 1,
            shouldAppearTwice: 2,
            shouldAppearThrice: 3,
            shouldAppearOnceToo: 1
        ])
        
        let didOnStartGetCalledExpectation = expectation(description: "onStart was called")
        let blockDelegate = BlockMMCQProcessingDelegate()
        blockDelegate.onDidStart = { vbox in
            didOnStartGetCalledExpectation.fulfill()
            XCTAssertEqual(vbox.contents, startVBox.contents)
        }
        
        mmcq.delegate = blockDelegate
        mmcq.run()
        
        wait(for: [didOnStartGetCalledExpectation], timeout: 5)
    }
    
    func testCallsAllDelegateMethods() {
        let didOnStartGetCalledExpectation = expectation(description: "onStart was called")
        let didOnSplitGetCalledExpectation = expectation(description: "onSplit was called")
        let didOnEndGetCalledExpectation = expectation(description: "onEnd was called")
        
        didOnSplitGetCalledExpectation.expectedFulfillmentCount = 2
        didOnSplitGetCalledExpectation.assertForOverFulfill = true
        
        let blockDelegate = BlockMMCQProcessingDelegate()
        blockDelegate.onDidStart = { vbox in
            didOnStartGetCalledExpectation.fulfill()
        }
        blockDelegate.onDidSplit = { (first, second) in
            didOnSplitGetCalledExpectation.fulfill()
        }
        blockDelegate.onDidFinish = {
            didOnEndGetCalledExpectation.fulfill()
        }
        
        mmcq.delegate = blockDelegate
        mmcq.run()
        
        wait(for: [didOnStartGetCalledExpectation, didOnSplitGetCalledExpectation, didOnEndGetCalledExpectation], timeout: 5)
    }
    
    func testRunPerformance() throws {
        let bundle = Bundle(for: MMCQTests.self)
        let image = try require(UIImage(named: "flower.jpg", in: bundle, compatibleWith: nil))
        
        guard let pixelData = image.pixelData() else { fatalError("Ugh") }
        var pixels : [Pixel] = []
        pixels.reserveCapacity(pixelData.count / 4)
        
        for index in stride(from: 0, to: pixelData.count, by: 4) {
            let pixel = Pixel(red: Int(pixelData[index]), green: Int(pixelData[index + 1]), blue: Int(pixelData[index + 2]))
            pixels.append(pixel)
        }
        
        
        self.measure {
            let biggerMMCQ = ModifiedMedianCutQuantizer(pixels: pixels)
            biggerMMCQ.run()
        }
    }
    
}
