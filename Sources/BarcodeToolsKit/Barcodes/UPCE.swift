import SwiftUI

public struct UPCE: Sendable, CustomStringConvertible {
    public let barcode: String

    public init?(barcode: String) {
        let trimmedBarcode = barcode.trimmedAndSpaceless
        guard trimmedBarcode.count == 8,
              trimmedBarcode.isAllNumbers,
              Self.isValid(barcode: trimmedBarcode)
        else {
            return nil
        }
        self.barcode = trimmedBarcode
    }

    private static func isValid(barcode: String) -> Bool {
        guard barcode.count == 8,
              let firstDigit = barcode.first,
              let lastDigit = barcode.last,
              Int(String(firstDigit)) != nil,
              Int(String(lastDigit)) != nil
        else {
            return false
        }

        let middleDigits = barcode.dropFirst().dropLast()
        return middleDigits.allSatisfy { $0.isNumber }
    }

    private let eanCodeA = ["0001101", "0011001", "0010011", "0111101", "0100011",
                            "0110001", "0101111", "0111011", "0110111", "0001011"]
    private let eanCodeB = ["0100111", "0110011", "0011011", "0100001", "0011101",
                            "0111001", "0000101", "0010001", "0001001", "0010111"]
    private let upcECode0 = ["bbbaaa", "bbabaa", "bbaaba", "bbaaab", "babbaa",
                             "baabba", "baaabb", "bababa", "babaab", "baabab"]
    private let upcECode1 = ["aaabbb", "aababb", "aabbab", "aabbba", "abaabb",
                             "abbaab", "abbbaa", "ababab", "ababba", "abbaba"]

    var barcodePattern: String {
        let numberSystem = Int(String(barcode.first!))!
        let checkDigit = Int(String(barcode.last!))!
        let dataDigits = String(barcode.dropFirst().dropLast())
        let encodingPattern = numberSystem == 0 ? upcECode0[checkDigit] : upcECode1[checkDigit]
        var encodedResult = "101"
        for (index, patternChar) in encodingPattern.enumerated() {
            let digit = Int(String(dataDigits[dataDigits.index(dataDigits.startIndex, offsetBy: index)]))!
            encodedResult += patternChar == "a" ? eanCodeA[digit] : eanCodeB[digit]
        }
        encodedResult += "010101"
        return encodedResult
    }

    public var description: String {
        String(interpolatingUPCE: self)
    }

    var numberSystemDigit: String { barcode.prefix(1).description }
    var dataDigits: String { barcode.dropFirst().dropLast().description }
    var checkDigit: String { barcode.suffix(1).description }

    @MainActor
    public var view: some View {
        UPCEView(upce: self)
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: UPCE) {
        appendLiteral(value.numberSystemDigit)
        appendLiteral(" ")
        appendLiteral(value.dataDigits)
        appendLiteral(" ")
        appendLiteral(value.checkDigit)
    }
}

extension String {
    init(interpolatingUPCE value: UPCE) {
        self.init(stringInterpolation: .init(literalCapacity: 10, interpolationCount: 1))
        append(contentsOf: "\(value)")
    }
}

struct UPCEView: View {
    @Environment(\.barcodeLineColor) private var barcodeLineColor
    @Environment(\.barcodeStyle) private var barcodeStyle

    private let standardBarHeightRatio = 0.8
    private let guardBarHeightRatio = 1.15
    private let quietZoneWidth = 9
    private let fontSizeRatio = 0.15
    private let textYPositionRatio = 0.9
    private let outerTextYPositionRatio = 0.87
    private let totalModules = 51
    private let leftmostTextPosition = 4
    private let middleTextPosition = 24
    private let rightmostTextPosition = 47

    private var barcodeShowNumbers: Bool {
        barcodeStyle == .default
    }

    let upce: UPCE

    var body: some View {
        Canvas { context, size in
            drawBarcode(context: context, canvasSize: size)
            if barcodeShowNumbers {
                drawText(context: context, size: size)
            }
        }
    }

    private func drawBarcode(context: GraphicsContext, canvasSize: CGSize) {
        let totalModuleCount = upce.barcodePattern.count + 2 * quietZoneWidth
        let moduleWidth = canvasSize.width / Double(totalModuleCount)
        let barHeight = barcodeShowNumbers ? canvasSize.height * standardBarHeightRatio : canvasSize.height
        for (index, value) in upce.barcodePattern.enumerated() where value == "1" {
            let isGuardBar = index < 3 || index >= upce.barcodePattern.count - 6
            let currentBarHeight = barcodeShowNumbers && isGuardBar ? barHeight * guardBarHeightRatio : barHeight
            context.drawBarcodeLine(at: quietZoneWidth + index + 1, width: moduleWidth, height: currentBarHeight, color: barcodeLineColor)
        }
    }

    private func drawText(context: GraphicsContext, size: CGSize) {
        let moduleWidth = size.width / Double(totalModules)
        let fontSize = size.height * fontSizeRatio
        let innerYPosition = size.height * textYPositionRatio
        let outerYPosition = size.height * outerTextYPositionRatio
        context.drawText(String(upce.barcode.prefix(1)),
                         x: moduleWidth * Double(leftmostTextPosition),
                         y: outerYPosition,
                         fontSize: fontSize,
                         color: barcodeLineColor)
        context.drawText(String(upce.barcode.dropFirst().dropLast()),
                         x: moduleWidth * Double(middleTextPosition),
                         y: innerYPosition,
                         fontSize: fontSize,
                         color: barcodeLineColor)
        context.drawText(String(upce.barcode.suffix(1)),
                         x: moduleWidth * Double(rightmostTextPosition),
                         y: outerYPosition,
                         fontSize: fontSize,
                         color: barcodeLineColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        UPCEView(upce: .init(barcode: "04252614")!)
            .frame(width: 150, height: 100)
            .barcodeStyle(.default)
        UPCEView(upce: .init(barcode: "04252614")!)
            .frame(width: 150, height: 100)
            .barcodeStyle(.plain)
    }
}
