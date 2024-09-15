import SwiftUI

struct EAN8View: View {
    @Environment(\.barcodeLineColor) private var barcodeLineColor

    private let fullHeightRatio = 0.9
    private let guardBarHeightRatio = 0.9
    private let textYPositionRatio = 0.9
    private let fontSizeRatio = 0.15
    private let totalModules = 85
    private let leftTextPosition = 24
    private let rightTextPosition = 55
    private let guardBarStartIndex = 12
    private let guardBarEndIndex = 41
    private let guardBarSecondStartIndex = 45
    private let guardBarSecondEndIndex = 74

    let ean8: EAN8

    var body: some View {
        Canvas { context, size in
            drawBarcode(context: context, size: size)
            drawText(context: context, size: size)
        }
    }

    private func drawBarcode(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fullHeight = size.height * fullHeightRatio

        for (index, char) in ean8.barcodePattern.enumerated() where char == "1" {
            let barHeight = (index > guardBarStartIndex && index < guardBarEndIndex) ||
                (index > guardBarSecondStartIndex && index < guardBarSecondEndIndex) ?
                fullHeight * guardBarHeightRatio : fullHeight

            context.drawBarcodeLine(at: index, moduleWidth: moduleWidth, height: barHeight, color: barcodeLineColor)
        }
    }

    private func drawText(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fontSize = size.height * fontSizeRatio
        let font = Font.system(size: fontSize).weight(.medium)
        let yPosition = size.height * textYPositionRatio

        context.drawText(ean8.leftHalf, x: moduleWidth * Double(leftTextPosition), y: yPosition, font: font, color: barcodeLineColor)
        context.drawText(ean8.rightHalf, x: moduleWidth * Double(rightTextPosition), y: yPosition, font: font, color: barcodeLineColor)
    }
}

struct EAN8 {
    let barcode: String

    private enum Constants {
        static let quietZonePattern = "0000000000"
        static let guardPattern = "101"
        static let centerGuardPattern = "01010"
    }

    private enum Patterns {
        static let leftPatterns = ["0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011"]
        static let rightPatterns = ["1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100"]
    }

    var leftHalf: String { barcode.prefix(4).description }
    var rightHalf: String { barcode.suffix(4).description }
    var checkDigit: String {
        let digits = barcode.prefix(7).compactMap { Int(String($0)) }.reversed()
        let even = digits.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }.reduce(0, +) * 3
        let odd = digits.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }.reduce(0, +)
        return String((10 - ((even + odd) % 10)) % 10)
    }

    var barcodePattern: String {
        let leftDigits = encodeDigits(digits: leftHalf, encodingPatterns: Patterns.leftPatterns)
        let rightDigits = encodeDigits(digits: rightHalf, encodingPatterns: Patterns.rightPatterns)

        return "\(Constants.quietZonePattern)\(Constants.guardPattern)\(leftDigits)\(Constants.centerGuardPattern)\(rightDigits)\(Constants.guardPattern)\(Constants.quietZonePattern)"
    }

    var isValid: Bool {
        guard barcode.count == 8 else { return false }
        let digits = barcode.compactMap { Int(String($0)) }
        guard digits.count == 8 else { return false }
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
    EAN8View(ean8: .init(barcode: "20886509"))
        .frame(width: 200, height: 100)
}
