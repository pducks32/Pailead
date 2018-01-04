import Foundation

#if os(macOS)
    import AppKit
    public typealias Image = NSImage
    public typealias Color = NSColor
    
    extension NSImage {
        func resized(toWidth width: CGFloat, and height : CGFloat) -> NSImage? {
            let img = NSImage(size: CGSize(width: width, height: height))
            
            img.lockFocus()
            
            let ctx = NSGraphicsContext.current
            ctx?.imageInterpolation = .high
            self.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, size.width, size.height), operation: .copy, fraction: 1)
            img.unlockFocus()
            
            return img
        }
    }
#elseif os(iOS)
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
    
    extension Image {
        func resized(toWidth width: CGFloat, and height : CGFloat) -> UIImage? {
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            imageView.contentMode = .scaleAspectFit
            imageView.image = self
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            imageView.layer.render(in: context)
            guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            return result
        }
    }
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
        return image.resized(toWidth: newWidth, and: newHeight) ?? image
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
    public static func extractTop(_ numberOfColors : Int, from image : Image, onQueue queue : DispatchQueue? = nil, completionHandler : @escaping (([Color]) -> Void)) {
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
    
    /// Takes swatches and organizes them into a palette
    public class PaletteMaker {
        /// The swatches from the base image
        let swatches : Set<Swatch>
        
        /// A possible swatch that's from darker but vibrant range of image
        public var darkVibrantSwatch : Swatch?
        /// A possible swatch that's from vibrant range of image
        public var vibrantSwatch : Swatch?
        /// A possible swatch that's from lighter and vibrant range of image
        public var lightVibrantSwatch : Swatch?
        
        /// A possible swatch that's from darker and muted range of image
        public var darkMutedSwatch : Swatch?
        /// A possible swatch that's from muted range of image
        public var mutedSwatch : Swatch?
        /// A possible swatch that's from lighter but muted range of image
        public var lightMutedSwatch : Swatch?
        
        /// The highest population of all the base image's swatches
        internal let highestPopulation : Int
        
        /// Make a new PaletteMaker from a collection of swatches
        ///
        /// - Parameter swatches: The base image's swatches
        public init(swatches : Set<Swatch>) {
            self.swatches = swatches
            self.highestPopulation = swatches.map({ $0.count }).max()!
            
            organizeSwatches()
        }
        
        /// Finds colors for each of the palette's requested swatches
        private func organizeSwatches() {
            vibrantSwatch = findColor(targetLuma: 0.5, minLuma: 0.3, maxLuma: 0.7, targetSaturation: 1, minSaturation: 0.35, maxSaturation: 1)
            
            lightVibrantSwatch = findColor(targetLuma: 0.74, minLuma: 0.55, maxLuma: 1, targetSaturation: 1, minSaturation: 0.35, maxSaturation: 1)
            
            darkVibrantSwatch = findColor(targetLuma: 0.26, minLuma: 0, maxLuma: 0.45, targetSaturation: 1, minSaturation: 0.35, maxSaturation: 1)
            
            
            mutedSwatch = findColor(targetLuma: 0.5, minLuma: 0.3, maxLuma: 0.7, targetSaturation: 0.3, minSaturation: 0, maxSaturation: 0.4)
            
            lightMutedSwatch = findColor(targetLuma: 0.74, minLuma: 0.55, maxLuma: 1, targetSaturation: 0.3, minSaturation: 0, maxSaturation: 0.4)
            
            darkMutedSwatch = findColor(targetLuma: 0.26, minLuma: 0, maxLuma: 0.45, targetSaturation: 0.3, minSaturation: 0, maxSaturation: 0.4)
        }
        
        /// Checks that the swatch isn't already chosen as a palette swatch
        ///
        /// - Parameter swatch: The swatch to check
        /// - Returns: Is the swatch already chosen
        private func isAlreadySelected(_ swatch : Swatch) -> Bool {
            return vibrantSwatch == swatch || darkVibrantSwatch == swatch ||
                    lightVibrantSwatch == swatch || mutedSwatch == swatch ||
                    darkMutedSwatch == swatch || lightMutedSwatch == swatch
        }
        
        /// Loop through image's swatches and find one that's close to a target
        /// luminance and saturation
        ///
        /// - Parameters:
        ///   - targetLuma: The most ideal luminance
        ///   - minLuma: The min luminance that's acceptable
        ///   - maxLuma: The max luminance that's acceptable
        ///   - targetSaturation: The most ideal saturation
        ///   - minSaturation: The min saturation that's acceptable
        ///   - maxSaturation: The max saturation that's acceptable
        /// - Returns: A swatch from the base image that fits into range
        private func findColor(targetLuma : Float, minLuma : Float, maxLuma : Float,
                       targetSaturation : Float, minSaturation : Float, maxSaturation : Float) -> Swatch? {
            var max : Swatch? = nil
            var maxValue : Float = 0
            let converter = HSLConverter()
            swatches.forEach { swatch in
                let (_, sat, luma) = converter.hslFor(swatch.pixel)
                if (sat >= minSaturation && sat <= maxSaturation &&
                    luma >= minLuma && luma <= maxLuma && !isAlreadySelected(swatch)) {
                    let thisValue : Float = findComparisonValue(saturation: sat, targetSaturation: targetSaturation, luma: luma, targetLuma: targetLuma, population: swatch.count, highestPopulation: highestPopulation)
                    if (max == nil || thisValue > maxValue) {
                        max = swatch
                        maxValue = thisValue;
                    }
                }
            }
            
            return max
        }
        
        /// Reduce the swatch and the target swatch to a comparable value
        ///
        /// - Parameters:
        ///   - saturation: The current swatch saturation
        ///   - targetSaturation: The target swatch saturation
        ///   - luma: The current swatch luminance
        ///   - targetLuma: The target swatch luminance
        ///   - population: The number of times a pixel appears in the base image
        ///   - highestPopulation: The highest population found in the base image
        /// - Returns: A weighted average of the distances from current swatch's values
        ///            to the target swatch's
        private func findComparisonValue(saturation : Float, targetSaturation : Float, luma : Float, targetLuma : Float, population : Int, highestPopulation : Int) -> Float {
            return weightedMean((invertDiff(value: saturation, targetValue: targetSaturation), 3),
                                (invertDiff(value: luma, targetValue: targetLuma), 6.5),
                                (Float(population) / Float(highestPopulation), 0.5))
        }
        
        /// Returns a number between from -∞ to 1 where values closer
        /// to 1 represent `value` and `targetValue` being closer.
        ///
        /// - Note: When used with luminance and saturation which
        /// are (0, 1) this function returns a number between (0, 1)
        /// where 1 means the values are the same.
        ///
        /// This is used to weight swatches with close target lum/sat
        /// as more ideal.
        ///
        /// - Parameters:
        ///   - value: The value to check against target
        ///   - targetValue: The most ideal value
        /// - Returns: A float on (0, 1) where 1 is equality
        private func invertDiff(value : Float, targetValue : Float) -> Float {
            return 1.0 - abs(value - targetValue)
        }
        
        /// Finds the average of a collection where each element is
        /// weighted by another value
        ///
        /// Unlike a normal average the values are–in some sense–counted
        /// multiple times where the number of times is their weight.
        /// This helps unbalance the scale to favor particular values.
        ///
        /// - Parameter values: List of (Element, Weight)
        /// - Returns: The weighted mean
        private func weightedMean(_ values : (Float, Float)...) -> Float {
            var sum : Float = 0
            var sumWeight : Float = 0
            values.forEach { entry in
                sum += (entry.0 * entry.1)
                sumWeight += entry.1
            }
            return sum / sumWeight
        }
        
    }
    
    
    func generatePalettes(from image : Image) -> [Swatch] {
        
        return []
    }
}
