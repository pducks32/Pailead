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
        
        let vbox = VBox(pixels: pixels)
        queue.offer(vbox)
    }
    
    public func run() {
        DispatchQueue.main.async {
            self.delegate?.mmcq(self, didStartWith: self.queue.peek())
        }
        while queue.count < numberOfSwatches {
            makeCut()
        }
        self.delegate?.mmcqDidFinishProcessing(self)
    }
    
    public func getVBoxes() -> ArraySlice<VBox> {
        return queue.feed().prefix(numberOfSwatches)
    }
    
    public func getSwatches() -> [Pixel] {
        return getVBoxes().map { (vbox) -> Pixel in
            vbox.average()
        }
    }
    
    private func makeCut() {
        guard let nextLargest = queue.poll() else { return }
        let (alpha, beta) = nextLargest.split()
        DispatchQueue.main.async {
            self.delegate?.mmcq(self, didSplitBox: nextLargest, into: (alpha, beta))
        }
        queue.offer(alpha)
        queue.offer(beta)
    }
}
