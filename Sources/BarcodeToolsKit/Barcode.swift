import SwiftUI
import Vision

public enum Barcode: Sendable {
    case ean13(String)
    case ean8(String)
    case upca(String)
    case upce(String)

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmedString.count {
        case 13:
            self = .ean13(trimmedString)
        case 12:
            self = .upca(trimmedString)
        case 8:
            if UPCE(barcode: trimmedString).isValid {
                self = .upce(trimmedString)
            } else {
                self = .ean8(trimmedString)
            }
        default:
            return nil
        }
        if !isValid {
            return nil
        }
    }

    public var barcodeString: String {
        switch self {
        case let .ean13(barcode), let .ean8(barcode), let .upce(barcode), let .upca(barcode):
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
        case let .upce(barcode):
            UPCE(barcode: barcode).isValid
        }
    }

    public var vnBarcodeSymbology: VNBarcodeSymbology {
        switch self {
        case .ean8:
            .ean8
        case .ean13:
            .ean13
        case .upca, .upce:
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
        case .upce:
            "org.gs1.UPC-E"
        }
    }
}
