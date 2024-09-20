import SwiftUI
import Vision

public enum Barcode: Sendable, CustomStringConvertible {
    case ean13(EAN13)
    case ean8(EAN8)
    case upca(UPCA)
    case upce(UPCE)

    public init?(rawValue: String) {
        if let ean13 = EAN13(barcode: rawValue) {
            self = .ean13(ean13)
        } else if let ean8 = EAN8(barcode: rawValue) {
            self = .ean8(ean8)
        } else if let upca = UPCA(barcode: rawValue) {
            self = .upca(upca)
        } else if let upce = UPCE(barcode: rawValue) {
            self = .upce(upce)
        } else {
            return nil
        }
    }

    public var barcodeString: String {
        switch self {
        case let .ean13(ean13):
            ean13.barcode
        case let .ean8(ean8):
            ean8.barcode
        case let .upce(upce):
            upce.barcode
        case let .upca(upca):
            upca.barcode
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

    public var description: String {
        switch self {
        case let .ean13(ean13):
            "\(ean13)"
        case let .ean8(ean8):
            "\(ean8)"
        case let .upca(upca):
            "\(upca)"
        case let .upce(upce):
            "\(upce)"
        }
    }

    @MainActor
    @ViewBuilder
    public var view: some View {
        switch self {
        case let .ean13(ean13):
            ean13.view
        case let .ean8(ean8):
            ean8.view
        case let .upca(upca):
            upca.view
        case let .upce(upce):
            upce.view
        }
    }
}
