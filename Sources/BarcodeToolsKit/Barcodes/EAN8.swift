import SwiftUI

struct EAN8: View {
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
        static let leftPatterns = ["0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011"]
        static let rightPatterns = ["1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100"]
    }

    private var leftHalf: String { barcode.prefix(4).description }
    private var rightHalf: String { barcode.suffix(4).description }
    private var checkDigit: String {
        let digits = barcode.prefix(7).compactMap { Int(String($0)) }.reversed()
        let even = digits.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }.reduce(0, +) * 3
        let odd = digits.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }.reduce(0, +)
        return String((10 - ((even + odd) % 10)) % 10)
    }

    private var barcodePattern: String {
        let leftDigits = encodeDigits(digits: leftHalf, encodingPatterns: Patterns.leftPatterns)
        let rightDigits = encodeDigits(digits: rightHalf, encodingPatterns: Patterns.rightPatterns)

        return "\(Constants.quietZonePattern)\(Constants.guardPattern)\(leftDigits)\(Constants.centerGuardPattern)\(rightDigits)\(Constants.guardPattern)\(Constants.quietZonePattern)"
    }

    private func drawBarcode(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / 85
        let fullHeight = size.height * 0.9

        for (index, char) in barcodePattern.enumerated() where char == "1" {
            let barHeight = (index > 12 && index < 41) || (index > 45 && index < 74) ?
                fullHeight * 0.9 : fullHeight

            let barRect = CGRect(x: CGFloat(index) * moduleWidth, y: 0, width: moduleWidth, height: barHeight)
            context.fill(Path(barRect), with: .color(.black))
        }
    }

    private func drawText(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / 85
        let fontSize = size.height * 0.15
        let font = Font.system(size: fontSize).weight(.medium)
        let leftHalfX = moduleWidth * 24
        let leftHalfY = size.height * 0.9
        context.draw(Text(leftHalf).font(font), at: CGPoint(x: leftHalfX, y: leftHalfY))
        let rightHalfX = moduleWidth * 55
        let rightHalfY = size.height * 0.9
        context.draw(Text(rightHalf).font(font), at: CGPoint(x: rightHalfX, y: rightHalfY))
    }

    private func encodeDigits(digits: String, encodingPatterns: [String]) -> String {
        digits.compactMap { Int(String($0)).flatMap { encodingPatterns[$0] } }.joined()
    }
}

#Preview {
    EAN8(barcode: "20886509")
        .frame(width: 200, height: 100)
}
