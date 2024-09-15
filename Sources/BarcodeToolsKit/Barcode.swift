import SwiftUI
import Vision

public enum Barcode: Sendable {
    case ean13(String)
    case ean8(String)
    case upca(String)

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedString.count == 13 {
            self = .ean13(trimmedString)
        } else if trimmedString.count == 8 {
            self = .ean8(trimmedString)
        } else {
            return nil
        }

        if !isValid {
            return nil
        }
    }

    public var barcodeString: String {
        return switch self {
        case let .ean13(barcode):
            barcode
        case let .ean8(barcode):
            barcode
        case let .upca(barcode):
            barcode
        }
    }

    public var isValid: Bool {
        switch self {
        case let .ean13(barcode):
            EAN13(barcode: barcode).isValid
        case let .ean8(barcode):
            EAN8(barcode: barcode).isValid
        case let .upca(barcode):
            UPCA(barcode: barcode).isValid
        }
    }

    public var vnBarcodeSymbology: VNBarcodeSymbology {
        switch self {
        case .ean8:
            .ean8
        case .ean13:
            .ean13
        case .upca:
            .upce
        }
    }

    public var standardName: String {
        switch self {
        case .ean8:
            "org.gs1.EAN-8"
        case .ean13:
            "org.gs1.EAN-13"
        case .upca:
            "org.gs1.UPC-A"
        }
    }

    @MainActor
    public var view: some View {
        BarcodeView(barcode: self)
    }

    static let barcodeSymbologies: [VNBarcodeSymbology] = [.ean8, .ean13, .upce]
}
