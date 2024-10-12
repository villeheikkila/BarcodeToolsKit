import SwiftUI

public struct BarcodeScannerView: View {
    @Environment(\.barcodeScannerMode) private var barcodeScannerMode
    let onDataFound: (_ barcode: Barcode?) -> Void

    public init(onDataFound: @escaping (_: Barcode?) -> Void) {
        self.onDataFound = onDataFound
    }

    public var body: some View {
        switch barcodeScannerMode {
        #if os(iOS) || os(visionOS)
            case .dataScanner:
                BarcodeDataScannerView(onDataFound: onDataFound, recognizedSymbologies: [.ean8, .ean13, .upce])
        #endif
        #if os(iOS) || os(visionOS) || os(macOS)
            case .default:
                AVScannerView(onDataFound: onDataFound, recognizedSymbologies: [.ean8, .ean13, .upce])
        #endif
        }
    }
}

public enum BarcodeScannerType {
    #if os(iOS) || os(visionOS)
        case `default`
    #endif
    #if os(iOS) || os(visionOS) || os(macOS)
        case dataScanner
    #endif
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
