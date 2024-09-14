import SwiftUI

struct EAN13: View {
    let barcode: String
    
    var body: some View {
        Canvas { context, size in
            drawBarcode(context: context, size: size)
            drawText(context: context, size: size)
        }
    }

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

    private var firstTwoDigits: String { barcode.prefix(2).description }
    private var manufacturerCode: String { barcode.dropFirst(2).prefix(5).description }
    private var productCode: String { barcode.dropFirst(7).prefix(5).description }
    private var checkDigit: String {
        let digits = barcode.prefix(12).compactMap { Int(String($0)) }
        let sum = digits.enumerated().reduce(0) { sum, element in
            sum + element.1 * (element.0 % 2 == 0 ? 1 : 3)
        }
        return String((10 - (sum % 10)) % 10)
    }

    private var barcodePattern: String {
        let leftDigits = encodeLeftHalfDigits(digits: String(barcode.prefix(7)))
        let rightDigits = encodeDigits(digits: String(barcode.dropFirst(7)), encodingPatterns: Patterns.rightPatterns)

        return "\(Constants.quietZonePattern)\(Constants.guardPattern)\(leftDigits)\(Constants.centerGuardPattern)\(rightDigits)\(Constants.guardPattern)\(Constants.quietZonePattern)"
    }

    private func drawBarcode(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / 113
        let fullHeight = size.height * 0.9

        for (index, char) in barcodePattern.enumerated() where char == "1" {
            let barHeight = (index > 12 && index < 55) || (index > 59 && index < 101) ?
                fullHeight * 0.9 : fullHeight

            let barRect = CGRect(x: CGFloat(index) * moduleWidth, y: 0, width: moduleWidth, height: barHeight)
            context.fill(Path(barRect), with: .color(.black))
        }
    }

    private func drawText(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / 113
        let fontSize = size.height * 0.15
        let font = Font.system(size: fontSize).weight(.medium)
        let firstDigitX = moduleWidth * 5
        let firstDigitY = size.height * 0.9
        context.draw(Text(String(firstTwoDigits.prefix(1))).font(font), at: CGPoint(x: firstDigitX, y: firstDigitY))
        let mfgCodeX = moduleWidth * 32
        let mfgCodeY = size.height * 0.9
        context.draw(Text("\(firstTwoDigits.suffix(1))\(manufacturerCode)").font(font), at: CGPoint(x: mfgCodeX, y: mfgCodeY))
        let productCodeX = moduleWidth * 77
        let productCodeY = size.height * 0.9
        context.draw(Text("\(productCode)\(checkDigit)").font(font), at: CGPoint(x: productCodeX, y: productCodeY))
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
        EAN13(barcode: "6410405176059")
            .frame(width: 200, height: 100)
    }
}
