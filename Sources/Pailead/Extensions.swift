//
//  Extensions.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 12/31/17.
//

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
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
