import SwiftUI

struct EAN13View: View {
    @Environment(\.barcodeLineColor) private var barcodeLineColor

    private let fullHeightRatio = 0.9
    private let guardBarHeightRatio = 0.9
    private let textYPositionRatio = 0.9
    private let fontSizeRatio = 0.15
    private let totalModules = 113
    private let firstDigitPosition = 5
    private let leftTextPosition = 32
    private let rightTextPosition = 77
    private let guardBarStartIndex = 12
    private let guardBarEndIndex = 55
    private let guardBarSecondStartIndex = 59
    private let guardBarSecondEndIndex = 101

    let ean13: EAN13

    var body: some View {
        Canvas { context, size in
            drawBarcode(context: context, size: size)
            drawText(context: context, size: size)
        }
    }

    private func drawBarcode(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fullHeight = size.height * fullHeightRatio

        for (index, char) in ean13.barcodePattern.enumerated() where char == "1" {
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

        context.drawText(String(ean13.firstTwoDigits.prefix(1)), x: moduleWidth * Double(firstDigitPosition), y: yPosition, font: font, color: barcodeLineColor)
        context.drawText("\(ean13.firstTwoDigits.suffix(1))\(ean13.manufacturerCode)", x: moduleWidth * Double(leftTextPosition), y: yPosition, font: font, color: barcodeLineColor)
        context.drawText("\(ean13.productCode)\(ean13.checkDigit)", x: moduleWidth * Double(rightTextPosition), y: yPosition, font: font, color: barcodeLineColor)
    }
}

struct EAN13 {
    let barcode: String

    private enum Constants {
        static let quietZonePattern = "0000000000"
        static let guardPattern = "101"
        static let centerGuardPattern = "01010"
    }

    private enum Patterns {
        static let leftOddPatterns = ["0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011"]
        static let leftEvenPatterns = ["0100111", "0110011", "0011011", "0100001", "0011101", "0111001", "0000101", "0010001", "0001001", "0010111"]
        static let rightPatterns = ["1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100"]
        static let firstDigitEncodings = ["OOOOOO", "OOEOEE", "OOEEOE", "OOEEEO", "OEOOEE", "OEEOOE", "OEEEOO", "OEOEOE", "OEOEEO", "OEEOEO"]
    }

    var firstTwoDigits: String { barcode.prefix(2).description }
    var manufacturerCode: String { barcode.dropFirst(2).prefix(5).description }
    var productCode: String { barcode.dropFirst(7).prefix(5).description }
    var checkDigit: String {
        let digits = barcode.prefix(12).compactMap { Int(String($0)) }
        let sum = digits.enumerated().reduce(0) { sum, element in
            sum + element.1 * (element.0 % 2 == 0 ? 1 : 3)
        }
        return String((10 - (sum % 10)) % 10)
    }

    var barcodePattern: String {
        let leftDigits = encodeLeftHalfDigits(digits: String(barcode.prefix(7)))
        let rightDigits = encodeDigits(digits: String(barcode.dropFirst(7)), encodingPatterns: Patterns.rightPatterns)

        return "\(Constants.quietZonePattern)\(Constants.guardPattern)\(leftDigits)\(Constants.centerGuardPattern)\(rightDigits)\(Constants.guardPattern)\(Constants.quietZonePattern)"
    }

    var isValid: Bool {
        guard barcode.count == 13 else { return false }
        let digits = barcode.compactMap { Int(String($0)) }
        guard digits.count == 13 else { return false }
        guard let checkDigit = digits.last else { return false }
        let sum = digits
            .dropLast()
            .enumerated()
            .reduce(0) { total, curr in
                total + (curr.element * (curr.offset.isMultiple(of: 2) ? 1 : 3))
            }
        let calculatedCheckDigit = (10 - (sum % 10)) % 10
        return checkDigit == calculatedCheckDigit
    }

    private func encodeLeftHalfDigits(digits: String) -> String {
        let encoding = Patterns.firstDigitEncodings[Int(firstTwoDigits.prefix(1)) ?? 0]
        return digits.dropFirst().enumerated().map { index, digit in
            let digitInt = Int(String(digit)) ?? 0
            return encoding[encoding.index(encoding.startIndex, offsetBy: index)] == "E" ?
                Patterns.leftEvenPatterns[digitInt] : Patterns.leftOddPatterns[digitInt]
        }.joined()
    }

    private func encodeDigits(digits: String, encodingPatterns: [String]) -> String {
        digits.compactMap { Int(String($0)).flatMap { encodingPatterns[$0] } }.joined()
    }
}

#Preview {
    VStack(spacing: 20) {
        EAN13View(ean13: .init(barcode: "6410405176059"))
            .frame(width: 200, height: 100)
    }
}
