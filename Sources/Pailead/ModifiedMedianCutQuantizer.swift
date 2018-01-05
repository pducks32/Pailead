//
//  ModifiedMedianCutQuantizer.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 11/30/17.
//

import Foundation

public protocol MMCQProcessingDelegate : class {
    func mmcq(_ mmcq : ModifiedMedianCutQuantizer, didSplitBox : VBox, into : (VBox, VBox))
    func mmcq(_ mmcq : ModifiedMedianCutQuantizer, didStartWith vbox : VBox)
    func mmcqDidFinishProcessing(_ mmcq : ModifiedMedianCutQuantizer)
}

public class ModifiedMedianCutQuantizer {
    public var numberOfSwatches : Int
    public var pixels : [Pixel]
    public var queue : PriorityQueue<VBox>
    
    public weak var delegate : MMCQProcessingDelegate?
    
    public init(numberOfSwatches : Int = 10, pixels : [Pixel]) {
        self.numberOfSwatches = numberOfSwatches
        self.pixels = pixels
        
        self.queue = PriorityQueue<VBox> { (first, second) -> Bool in
            if !first.canSplit && second.canSplit { return false }
            return first.volume > second.volume
        }
        
        let filteredPixels = pixels.filter { !self.shouldIgnore(pixel: $0) }
        
        let vbox = VBox(pixels: filteredPixels)
        queue.offer(vbox)
    }
    
    public func run() {
        guard !queue.isEmpty else { return }
        self.delegate?.mmcq(self, didStartWith: self.queue.peek())
        while queue.count < numberOfSwatches {
            makeCut()
        }
        self.delegate?.mmcqDidFinishProcessing(self)
    }
    
    public func getVBoxes() -> ArraySlice<VBox> {
        return queue.feed().prefix(numberOfSwatches)
    }
    
    public func getSwatches() -> Set<Swatch> {
        return Set<Swatch>(getVBoxes().map { (vbox) -> Swatch in
            vbox.average()
        })
    }
    
    private func makeCut() {
        guard let nextLargest = queue.poll() else { return }
        let (alpha, beta) = nextLargest.split()
        self.delegate?.mmcq(self, didSplitBox: nextLargest, into: (alpha, beta))
        queue.offer(alpha)
        queue.offer(beta)
    }
    
    private func getLuminence(of pixel : Pixel) -> Float {
        let rf = Float(pixel.red) / 255.0
        let gf = Float(pixel.green) / 255.0
        let bf = Float(pixel.blue) / 255.0
        
        let theMax = max(rf, max(gf, bf))
        let theMin = min(rf, min(gf, bf))
        
        return (theMax + theMin) / 2
    }
    
    private func shouldIgnore(pixel : Pixel) -> Bool {
        let lumience = getLuminence(of: pixel)
        return lumience >= 0.95 || lumience <= 0.05
    }
}
