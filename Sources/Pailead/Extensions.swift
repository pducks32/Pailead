//
//  Extensions.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 12/31/17.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(WatchKit)
    import WatchKit
#elseif canImport(UIKit)
    import UIKit
#endif

import CoreGraphics

/// Allows cross platfrom image resizing
public protocol Resizeable {
    /// Returns a copy of the image that fits the given dimensions
    ///
    /// - Parameters:
    ///   - width: The new width
    ///   - height: The new height
    /// - Returns: A resized image copy or nil if error
    func resizedTo(width : CGFloat, height : CGFloat) -> Image?
    
    /// Returns a copy of the image that fits the given size
    ///
    /// - Parameters:
    ///   - size: The new size
    /// - Returns: A resized image copy or nil if error
    func resizedTo(_ size : CGSize) -> Image?
}

extension Resizeable {
    public func resizedTo(width : CGFloat, height : CGFloat) -> Image? {
        return resizedTo(CGSize(width: width, height: height))
    }
}

#if canImport(AppKit)
    extension NSImage : Resizeable {
        public func resizedTo(_ newSize : CGSize) -> Image? {
            let img = NSImage(size: newSize)
            
            img.lockFocus()
            
            let ctx = NSGraphicsContext.current
            ctx?.imageInterpolation = .high
            self.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1)
            img.unlockFocus()
            
            return img
        }
    }
#elseif os(iOS)
    
    extension UIImage : Resizeable {
        public func resizedTo(_ newSize : CGSize) -> Image? {
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: newSize))
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

extension Image {
    /// The number of pixels in each dimension of the image
    var pixelSize : CGSize {
        #if canImport(AppKit)
            guard let firstRepresentaion = self.representations.first else {
                fatalError("NSImage#pixelSize - image does not have any representations")
            }
            let height = firstRepresentaion.pixelsHigh
            let width = firstRepresentaion.pixelsWide
            return CGSize(width: width, height: height)
        #elseif canImport(UIKit)
            return self.size.applying(CGAffineTransform(scaleX: self.scale, y: self.scale))
        #endif
    }
}

public extension Image {
    public typealias PixelFormat = UInt8
    /// The individual pixel values of the image
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
        
        #if canImport(UIKit)
            guard let cgImage = self.cgImage else { return nil }
        #elseif canImport(AppKit)
            guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        #endif
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}
