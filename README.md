# BarcodeToolsKit

Work in progress library for providing additional barcode tools for Swift and SwiftUI

### Features

| Symbology | Validation | View | Scanner |
|-----------|------------|------|---------|
| EAN-8     | ✅          | ✅    | ✅       |
| EAN-13    | ✅          | ✅    | ✅       |
| UPC-A    | ✅          | ✅    | ✅       |

### Example

Generate views from barcodes

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            BarcodeView(barcode: .ean13("6410405176059"))
            BarcodeView(barcode: .ean8("20886509"))
            BarcodeView(barcode: .ean8("12345678")) {
                Text("INVALID")
            }
        }
    }
}
```

Scan a barcode

```swift
import SwiftUI

BarcodeScannerView(onDataFound: { barcode in print(barcode) })
```
