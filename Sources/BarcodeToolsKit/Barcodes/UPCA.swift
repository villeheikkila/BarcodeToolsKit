import SwiftUI

struct UPCAView: View {
    @Environment(\.barcodeLineColor) private var barcodeLineColor

    private let fullHeightRatio = 0.8
    private let guardBarHeightRatio = 1.15
    private let textYPositionRatio = 0.9
    private let fontSizeRatio = 0.15
    private let totalModules = 107
    private let leftmostTextPosition = 1
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

    let upca: UPCA

    var body: some View {
        Canvas { context, size in
            drawBarcode(context: context, size: size)
            drawText(context: context, size: size)
        }
    }

    private func drawBarcode(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fullHeight = size.height * fullHeightRatio

        for (index, char) in upca.barcodePattern.enumerated() where char == "1" {
            let isGuardBar = (index >= guardBarStartIndex && index <= guardBarEndIndex) ||
                (index >= guardBarSecondStartIndex && index <= guardBarSecondEndIndex) ||
                (index >= guardBarThirdStartIndex && index <= guardBarThirdEndIndex) ||
                index == upca.barcodePattern.count - 1

            let barHeight = isGuardBar ? fullHeight * guardBarHeightRatio : fullHeight

            context.drawBarcodeLine(at: index + 6, moduleWidth: moduleWidth, height: barHeight, color: barcodeLineColor)
        }
    }

    private func drawText(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fontSize = size.height * fontSizeRatio
        let font = Font.system(size: fontSize).weight(.medium)
        let innerYPosition = size.height * textYPositionRatio
        let outerYPosition = size.height * outerTextYPositionRatio

        context.drawText(String(upca.barcode.prefix(1)), x: moduleWidth * Double(leftmostTextPosition), y: outerYPosition, font: font, color: barcodeLineColor)
        context.drawText(String(upca.barcode.dropFirst().prefix(5)), x: moduleWidth * Double(leftTextPosition), y: innerYPosition, font: font, color: barcodeLineColor)
        context.drawText(String(upca.barcode.dropFirst(6).prefix(5)), x: moduleWidth * Double(rightTextPosition), y: innerYPosition, font: font, color: barcodeLineColor)
        context.drawText(String(upca.barcode.suffix(1)), x: moduleWidth * Double(rightmostTextPosition), y: outerYPosition, font: font, color: barcodeLineColor)
    }
}

struct UPCA {
    let barcode: String

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

    var isValid: Bool {
        guard barcode.count == 12 else { return false }
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

    private func encodeDigits(digits: String, encodingPatterns: [String]) -> String {
        digits.compactMap { Int(String($0)).flatMap { encodingPatterns[$0] } }.joined()
    }
}

#Preview {
    VStack(spacing: 20) {
        UPCAView(upca: .init(barcode: "123456789012"))
            .frame(width: 200, height: 100)
    }
}
