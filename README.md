# BarcodeToolsKit

Work in progress library for providing additional barcode tools for Swift and SwiftUI

### Features

| Symbology | Validation | View |
| --------- | ---------- | ---- |
| EAN-8     | ✅         | ✅   |
| EAN-13    | ✅         | ✅   |

### Example

Generate views from barcodes

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            BarcodeGenerator(barcode: .ean13("6410405176059"))
            BarcodeGenerator(barcode: .ean8("20886509"))
            BarcodeGenerator(barcode: .ean8("12345678")) {
                Text("INVALID")
            }
        }
    }
}
```
