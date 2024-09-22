import SwiftUI

extension GraphicsContext {
    func drawText(_ text: String, x: Double, y: Double, fontSize: Double, color: Color) {
        draw(Text(text).font(Font.system(size: fontSize).weight(.medium)).foregroundStyle(color), at: CGPoint(x: x, y: y))
    }

    func drawBarcodeLine(at index: Int, width: Double, height: Double, color: Color) {
        let barRect = CGRect(x: Double(index) * width, y: 0, width: width, height: height)
        fill(Path(barRect), with: .color(color))
    }
}
