# Pailead
[![Version](https://img.shields.io/cocoapods/v/Pailead.svg?style=flat)](http://cocoapods.org/pods/Pailead)
[![License](https://img.shields.io/cocoapods/l/Pailead.svg?style=flat)](http://cocoapods.org/pods/Pailead)
[![Platform](https://img.shields.io/cocoapods/p/Pailead.svg?style=flat)](http://cocoapods.org/pods/Pailead)

Pailead works just like the Palette library on Android and other tools like node-vibrant but is
completely written in Swift and optimized for macOS and iOS.

## Installation

Pailead is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Pailead"
```

## Usage
### Extracting Palette
All images are resized to 1000 pixels to speed up extraction, but don't worry this hasn't been shown to degrade the quality of the palette.
```swift
let image = <#Image#>
Pailead.extractPalette(from: image) { palette in
<#Do Something with Palette#>
}
```
### Palette Swatches
The generated palette generates useful swatches to use in your UI or as a loading background perhaps.
All swatches are actual colors found in the MMCQ calculation though it will generate some if no suitable ones can be found.
These are:
- Muted Swatch (middle range luma and low saturation)
- Dark Muted Swatch (low range luma)
- Light Muted Swatch (high range luma)
- Vibrant Swatch (middle range luma and high saturation)
- Dark Vibrant Swatch (low range luma)
- Light Vibrant Swatch (high range luma)

## How it works
### Modified Mean Cut Quantization
That's a big word. The image's pixels are grouped and counted.
Then they are laid out in RGB space. From there the quantizer finds
RGB boxes that encapsulate the pixels equally. From these boxes the
average color is generated and then sorted by how common it is in the image.


## Todo
- [x] Switch to swatches
- [x] Add palette
- [ ] Paralleize pixel extraction
- [ ] Add more performance tests
- [ ] Make better docs with example uses
- [ ] Optimize processing loop
- [ ] Add support for other clustering algorithms

## Name

If palette is pronounced *pa-let* then Pailead is pronounced *pa-lid*.

The word comes from the Irish word paileád meaning palette which is what this library extracts.

## Author
- @pducks32 (Patrick Metcalfe, git@patrickmetcalfe.com)
