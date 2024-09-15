import SwiftUI

extension GraphicsContext {
    func drawText(_ text: String, x: CGFloat, y: CGFloat, font: Font, color: Color) {
        draw(Text(text).font(font).foregroundStyle(color), at: CGPoint(x: x, y: y))
    }

    func drawBarcodeLine(at index: Int, moduleWidth: CGFloat, height: CGFloat, color: Color) {
        let barRect = CGRect(x: CGFloat(index) * moduleWidth, y: 0, width: moduleWidth, height: height)
        fill(Path(barRect), with: .color(color))
    }
}
