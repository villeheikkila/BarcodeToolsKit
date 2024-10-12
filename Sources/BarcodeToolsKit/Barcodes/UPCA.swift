import SwiftUI

public struct UPCA: Sendable, Hashable, CustomStringConvertible {
    public let barcode: String

    public init?(barcode: String) {
        let trimmedBarcode = barcode.trimmedAndSpaceless
        guard trimmedBarcode.count == 12,
              trimmedBarcode.isAllNumbers,
              Self.isValid(barcode: trimmedBarcode)
        else {
            return nil
        }
        self.barcode = trimmedBarcode
    }

    private static func isValid(barcode: String) -> Bool {
        let digits = barcode.compactMap { Int(String($0)) }
        guard digits.count == 12 else { return false }
        guard let checkDigit = digits.last else { return false }
        let sum = digits
            .dropLast()
            .enumerated()
            .reduce(0) { total, curr in
                total + (curr.element * (curr.offset.isMultiple(of: 2) ? 3 : 1))
            }
        let calculatedCheckDigit = (10 - (sum % 10)) % 10
        return checkDigit == calculatedCheckDigit
    }

    private enum Constants {
        static let guardPattern = "101"
        static let centerGuardPattern = "01010"
    }

    private enum Patterns {
        static let leftPatterns = ["0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011"]
        static let rightPatterns = ["1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100"]
    }

    var barcodePattern: String {
        let leftDigits = encodeDigits(digits: String(barcode.prefix(6)), encodingPatterns: Patterns.leftPatterns)
        let rightDigits = encodeDigits(digits: String(barcode.suffix(6)), encodingPatterns: Patterns.rightPatterns)

        return "\(Constants.guardPattern)\(leftDigits)\(Constants.centerGuardPattern)\(rightDigits)\(Constants.guardPattern)"
    }

    private func encodeDigits(digits: String, encodingPatterns: [String]) -> String {
        digits.compactMap { Int(String($0)).flatMap { encodingPatterns[$0] } }.joined()
    }

    var numberSystemDigit: String { barcode.prefix(1).description }
    var manufacturerCode: String { barcode.dropFirst().prefix(5).description }
    var productCode: String { barcode.dropFirst(6).prefix(5).description }
    var checkDigit: String { barcode.suffix(1).description }

    public var description: String {
        String(interpolatingUPCA: self)
    }

    @MainActor
    public var view: some View {
        UPCAView(upca: self)
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: UPCA) {
        appendLiteral(value.numberSystemDigit)
        appendLiteral(" ")
        appendLiteral(value.manufacturerCode)
        appendLiteral(" ")
        appendLiteral(value.productCode)
        appendLiteral(" ")
        appendLiteral(value.checkDigit)
    }
}

extension String {
    init(interpolatingUPCA value: UPCA) {
        self.init(stringInterpolation: .init(literalCapacity: 14, interpolationCount: 1))
        append(contentsOf: "\(value)")
    }
}

struct UPCAView: View {
    @Environment(\.barcodeLineColor) private var barcodeLineColor
    @Environment(\.barcodeStyle) private var barcodeStyle

    private let fullHeightRatio = 0.8
    private let guardBarHeightRatio = 1.15
    private let textYPositionRatio = 0.9
    private let fontSizeRatio = 0.15
    private let totalModules = 107
    private let leftmostTextPosition = 1
    private let leftTextAreaModuleCount = 6
    private let leftTextPosition = 28
    private let rightTextPosition = 78
    private let rightmostTextPosition = 105
    private let outerTextYPositionRatio = 0.85
    private let guardBarStartIndex = 0
    private let guardBarEndIndex = 2
    private let guardBarSecondStartIndex = 45
    private let guardBarSecondEndIndex = 49
    private let guardBarThirdStartIndex = 91
    private let guardBarThirdEndIndex = 93

    private var showNumbers: Bool {
        barcodeStyle == .default
    }

    let upca: UPCA

    var body: some View {
        Canvas { context, size in
            drawBarcode(context: context, size: size)
            if showNumbers {
                drawText(context: context, size: size)
            }
        }
    }

    private func drawBarcode(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fullHeight = size.height * fullHeightRatio
        for (index, value) in upca.barcodePattern.enumerated() where value == "1" {
            let isGuardBar = (index >= guardBarStartIndex && index <= guardBarEndIndex) ||
                (index >= guardBarSecondStartIndex && index <= guardBarSecondEndIndex) ||
                (index >= guardBarThirdStartIndex && index <= guardBarThirdEndIndex) ||
                index == upca.barcodePattern.count - 1
            let barHeight: Double = if showNumbers {
                isGuardBar ? fullHeight * guardBarHeightRatio : fullHeight
            } else {
                size.height
            }
            context.drawBarcodeLine(at: index + leftTextAreaModuleCount, width: moduleWidth, height: barHeight, color: barcodeLineColor)
        }
    }

    private func drawText(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fontSize = size.height * fontSizeRatio
        let innerYPosition = size.height * textYPositionRatio
        let outerYPosition = size.height * outerTextYPositionRatio
        context.drawText(String(upca.barcode.prefix(1)), x: moduleWidth * Double(leftmostTextPosition), y: outerYPosition, fontSize: fontSize, color: barcodeLineColor)
        context.drawText(String(upca.barcode.dropFirst().prefix(5)), x: moduleWidth * Double(leftTextPosition), y: innerYPosition, fontSize: fontSize, color: barcodeLineColor)
        context.drawText(String(upca.barcode.dropFirst(6).prefix(5)), x: moduleWidth * Double(rightTextPosition), y: innerYPosition, fontSize: fontSize, color: barcodeLineColor)
        context.drawText(String(upca.barcode.suffix(1)), x: moduleWidth * Double(rightmostTextPosition), y: outerYPosition, fontSize: fontSize, color: barcodeLineColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        UPCAView(upca: .init(barcode: "123456789012")!)
            .frame(width: 200, height: 100)
            .barcodeStyle(.default)
        UPCAView(upca: .init(barcode: "123456789012")!)
            .frame(width: 200, height: 100)
            .barcodeStyle(.plain)
    }
}
