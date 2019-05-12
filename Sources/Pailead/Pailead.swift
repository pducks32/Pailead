import Foundation

#if canImport(AppKit)
    import AppKit
    public typealias Image = NSImage
    public typealias Color = NSColor
#elseif canImport(UIKit)
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
    /// The default processing queue for Pailead
    private static let defaultQueue = DispatchQueue(label: "com.patrickmetcalfe.pailead.processing")
    
    /// Returns an image that is–at most–as large as `maxDimension`
    ///
    /// - Note: This operation *preserves* the aspect ratio
    ///
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxDimension: The largest dimension to allow
    /// - Returns: A resized image or the original if acceptable
    public static func optimallyResizeImage(_ image : Image, maxDimension : CGFloat = 100) -> Image {
        let height = image.pixelSize.height
        let width = image.pixelSize.width
        let minDimension = min(width, height)
        
        if minDimension <= maxDimension {
            return image
        }
        
        let scaleRatio = maxDimension / minDimension
        let newWidth = round(width * scaleRatio)
        let newHeight = round(height * scaleRatio)
        return image.resizedTo(width: newWidth, height: newHeight) ?? image
    }
    
    /// Extract an image's palette
    ///
    /// - Parameters:
    ///   - image: The image to use
    ///   - numberOfColors: The max number of colors to base the palette on
    ///   - queue: The queue to use for processing
    ///   - completionHandler: What to do with the palette once generated
    public static func extractPalette(from image : Image, numberOfColors : Int = 16, onQueue queue : DispatchQueue? = nil, completionHandler : @escaping ((Palette) -> Void)) {
        extractTop(numberOfColors, from: image, onQueue: queue) { swatches in
            completionHandler(Palette(baseImageSwatches: swatches))
        }
    }
    
    /// Extract the top average colors from a image
    /// - Remarks: Using Modified Median Cut Quantization, extract
    ///            the top colors found in the image using the given queue.
    ///
    /// - Parameters:
    ///   - numberOfColors: Number of avergae colors to extract
    ///   - image: The image to extract from.
    ///   - queue: The queue to use. (default is a private concurrent queue).
    ///   - completionHandler: What to do with the colors once generated.
    public static func extractTop(_ numberOfColors : Int, from image : Image, onQueue queue : DispatchQueue? = nil, completionHandler : @escaping ((Set<Swatch>) -> Void)) {
        let chosenQueue = queue ?? defaultQueue
        let scaledImage = Pailead.optimallyResizeImage(image)
        chosenQueue.async {
            guard let pixelData = scaledImage.pixelData() else { fatalError("Pixel Extraction Failed") }
            var pixels : [Pixel] = []
            pixels.reserveCapacity(pixelData.count / 4)
            
            for index in stride(from: 0, to: pixelData.count, by: 4) {
                let pixel = Pixel(red: Int(pixelData[index]), green: Int(pixelData[index + 1]), blue: Int(pixelData[index + 2]))
                pixels.append(pixel)
            }
            
            let quantizer = ModifiedMedianCutQuantizer(numberOfSwatches: numberOfColors, pixels: pixels)
            let blockDelegate = BlockMMCQProcessingDelegate()
            blockDelegate.onDidFinish = { mmcq in
                let swatches = mmcq.getSwatches()
                completionHandler(swatches)
            }
            quantizer.delegate = blockDelegate
            quantizer.run()
        }
    }
}
