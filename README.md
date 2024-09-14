# BarcodeGeneratorKit

Work in progress library for rendering popular barcode formats using canvas

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
