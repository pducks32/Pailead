import Foundation

#if os(macOS)
    public typealias Image = NSImage
    public typealias Color = NSColor
#elseif os(iOS)
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
#endif

private class BlockMMCQProcessingDelegate : MMCQProcessingDelegate {
    var onDidFinish : ((ModifiedMedianCutQuantizer) -> Void)?
    
    func mmcq(_ mmcq: ModifiedMedianCutQuantizer, didStartWith vbox: VBox) {}
    
    func mmcq(_ mmcq: ModifiedMedianCutQuantizer, didSplitBox: VBox, into: (VBox, VBox)) {}
    
    func mmcqDidFinishProcessing(_ mmcq: ModifiedMedianCutQuantizer) {
        self.onDidFinish?(mmcq)
    }
}

public struct Pailead {
    private static let defaultQueue = DispatchQueue(label: "com.patrickmetcalfe.pailead.processing", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil)
    
    
    /// Extract the top average colors from a image
    /// - Remarks: Using Modified Median Cut Quantization, extract
    ///            the top colors found in the image using the given queue.
    ///
    /// - Parameters:
    ///   - numberOfColors: Number of avergae colors to extract
    ///   - image: The image to extract from.
    ///   - queue: The queue to use. (default is a private concurrent queue).
    ///   - completionHandler: What to do with the colors once generated.
    public static func extractTop(_ numberOfColors : Int, from image : Image, onQueue queue : DispatchQueue? = nil, completionHandler : @escaping (([Color]) -> Void)) {
        let chosenQueue = queue ?? defaultQueue
        chosenQueue.async {
            guard let pixelData = image.pixelData() else { fatalError("Pixel Extraction Failed") }
            var pixels : [Pixel] = []
            pixels.reserveCapacity(pixelData.count / 4)
            
            for index in stride(from: 0, to: pixelData.count, by: 4) {
                let pixel = Pixel(red: Int(pixelData[index]), green: Int(pixelData[index + 1]), blue: Int(pixelData[index + 2]))
                pixels.append(pixel)
            }
            
            let paileadThingy = ModifiedMedianCutQuantizer(numberOfSwatches: numberOfColors, pixels: pixels)
            let blockDelegate = BlockMMCQProcessingDelegate()
            blockDelegate.onDidFinish = { mmcq in
                let colors = mmcq.getSwatches().map({ (pixel : Pixel) -> Color in
                    let red = CGFloat(pixel.red) / 255
                    let green = CGFloat(pixel.green) / 255
                    let blue = CGFloat(pixel.blue) / 255
                    
                    return Color(red: red, green: green, blue: blue, alpha: 1)
                })
                completionHandler(colors)
            }
            paileadThingy.delegate = blockDelegate
            paileadThingy.run()
        }
    }
}
