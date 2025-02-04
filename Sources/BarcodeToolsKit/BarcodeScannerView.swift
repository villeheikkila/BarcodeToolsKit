import SwiftUI

#if os(iOS) || os(visionOS)

public struct BarcodeScannerView: View {
    @Environment(\.barcodeScannerMode) private var barcodeScannerMode
    let onDataFound: (_ barcode: Barcode?) -> Void

    public init(onDataFound: @escaping (_: Barcode?) -> Void) {
        self.onDataFound = onDataFound
    }

    public var body: some View {
        switch barcodeScannerMode {
            case .dataScanner:
                BarcodeDataScannerView(onDataFound: onDataFound, recognizedSymbologies: [.ean8, .ean13, .upce])
            case .default:
                AVScannerView(onDataFound: onDataFound, recognizedSymbologies: [.ean8, .ean13, .upce])
        }
    }
}

public enum BarcodeScannerType {
        case `default`
        case dataScanner
}

public extension EnvironmentValues {
    @Entry var barcodeScannerMode: BarcodeScannerType = .default
}

public extension View {
    func barcodeScannerMode(_ mode: BarcodeScannerType) -> some View {
        environment(\.barcodeScannerMode, mode)
    }
}

#Preview {
    BarcodeScannerView(onDataFound: { _ in })
}

#endif
