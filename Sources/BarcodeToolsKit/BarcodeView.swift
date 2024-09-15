import SwiftUI

/// A SwiftUI view that generates and displays barcodes.
///
/// This struct supports EAN-13 and EAN-8 barcode formats. It also provides
/// a customizable view for invalid barcodes.
///
/// Example usage:
/// ```swift
/// BarcodeView(barcode: .ean13("6410405176059"))
/// ```
public struct BarcodeView<InvalidView: View>: View {
    let barcode: Barcode?
    let invalidBarcodeView: () -> InvalidView

    public init(
        barcode: Barcode,
        @ViewBuilder invalidBarcodeView: @escaping () -> InvalidView = { EmptyView() }
    ) {
        self.barcode = barcode
        self.invalidBarcodeView = invalidBarcodeView
    }

    public init(
        barcode: String,
        @ViewBuilder invalidBarcodeView: @escaping () -> InvalidView = { EmptyView() }
    ) {
        self.barcode = .init(rawValue: barcode)
        self.invalidBarcodeView = invalidBarcodeView
    }

    public var body: some View {
        if let barcode {
            barcode.view
        } else {
            invalidBarcodeView()
        }
    }
}

public extension EnvironmentValues {
    @Entry var barcodeLineColor: Color = .accentColor
}

public extension View {
    func barcodeLineColor(_ color: Color) -> some View {
        environment(\.barcodeLineColor, color)
    }
}

#Preview {
    VStack(spacing: 20) {
        BarcodeView(barcode: "6410405176059")
            .frame(width: 200, height: 100)
            .barcodeLineColor(.red)
        BarcodeView(barcode: "20886509")
            .frame(width: 200, height: 100)
            .barcodeLineColor(.blue)
        BarcodeView(barcode: "123456789012")
            .barcodeLineColor(.green)
            .frame(width: 200, height: 100)
        BarcodeView(barcode: "04252614")
            .frame(width: 150, height: 100)
        BarcodeView(barcode: "123456722") {
            Text("INVALID")
        }
        .frame(width: 200, height: 100)
    }
}
