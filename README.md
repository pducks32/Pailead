# Pailead

Pailead works just like the Palette library on Android and other tools like node-vibrant but is
completely written in Swift and optimized for macOS and iOS.

### Usage
```swift
let image = <#Image#>
Pailead.extractPalette(from: image) { palette in
<#Do Something with Palette#>
}
```

The generated palette provides some swatches that represent the image in different ways. These are:
- Muted Swatch (middle range luma and low saturation)
- Dark Muted Swatch (low range luma)
- Light Muted Swatch (high range luma)
- Vibrant Swatch (middle range luma and high saturation)
- Dark Vibrant Swatch (low range luma)
- Light Vibrant Swatch (high range luma)

### Todo
- [x] Switch to swatches
- [x] Add palette
- [ ] Paralleize pixel extraction
- [ ] Add more performance tests
- [ ] Make better docs with example uses
- [ ] Optimize processing loop
- [ ] Add support for other clustering algorithms

### Name

If palette is pronounced *pa-let* then Pailead is pronounced *pa-lid*.

The word comes from the Irish word paileád meaning palette which is what this library extracts.

### Author
- @pducks32 (Patrick Metcalfe, git@patrickmetcalfe.com)
