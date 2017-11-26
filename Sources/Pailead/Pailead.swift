import Foundation

public protocol MMCQProcessingDelegate : class {
    func mmcq(_ mmcq : MMCQ, didSplitBox : VBox, into : (VBox, VBox))
    func mmcq(_ mmcq : MMCQ, didStartWith vbox : VBox)
}

public class MMCQ {
    public var numberOfSwatches : Int
    public var pixels : [Pixel]
    public var queue : PriorityQueue<VBox>
    
    public weak var delegate : MMCQProcessingDelegate? = nil
    
    public init(numberOfSwatches : Int = 10, pixels : [Pixel]) {
        self.numberOfSwatches = numberOfSwatches
        self.pixels = pixels
        
        
        self.queue = PriorityQueue<VBox> { (first, second) -> Bool in
            first.volume > second.volume
        }
        
        let vbox = VBox(pixels: pixels)
        queue.offer(vbox)
    }
    
    public func run() {
        DispatchQueue.main.async {
            self.delegate?.mmcq(self, didStartWith: self.queue.peek())
        }
        while queue.count < numberOfSwatches {
            print("Going again")
            doThatThing()
        }
    }
    
    public func getVBoxes() -> ArraySlice<VBox> {
        return queue.feed().prefix(numberOfSwatches)
    }
    
    public func getSwatches() -> [Pixel] {
        return getVBoxes().map { (vbox) -> Pixel in
            vbox.average()
        }
    }
    
    public func doThatThing() {
        guard let nextLargest = queue.poll() else { return }
        let (alpha, beta) = nextLargest.split()
        DispatchQueue.main.async {
            self.delegate?.mmcq(self, didSplitBox: nextLargest, into: (alpha, beta))
        }
        queue.offer(alpha)
        queue.offer(beta)
    }
}

struct Pailead {
    var text = "Hello, World!"
}
