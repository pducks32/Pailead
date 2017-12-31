import Foundation

#if os(macOS)
    public typealias Image = NSImage
    public typealias Color = NSColor
#elseif os(iOS)
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
#endif

struct Pailead {
    var text = "Hello, World!"
}
