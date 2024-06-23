import SwiftUI

public struct AmplitudeSpectrumView: View {
    let shapeType: ShapeType
    let magnitudes: [Magnitude]
    let range: Range<Int>
    let hue: Double?

    public init(shapeType: ShapeType, magnitudes: [Magnitude], range: Range<Int>?, rms: Float?) {
        self.shapeType = shapeType
        self.magnitudes = magnitudes
        self.range = range ?? magnitudes.indices
        if let rms {
            hue = modf(min(Double(rms), 1.0) + 0.5).1
        } else {
            hue = nil
        }
    }

    public var body: some View {
        Canvas { context, size in
            let color = if let hue {
                Color(hue: hue, saturation: 0.7, brightness: 0.8)
            } else {
                Color.primary
            }
            switch shapeType {
            case .straight:
                let unit = size.width / CGFloat(range.count)
                let width = 0.8 * unit
                let radius = 0.5 * width
                range.forEach { index in
                    let x = unit * CGFloat(index)
                    let height = size.height * CGFloat(magnitudes[index].value)
                    let y = 0.5 * (size.height - height)
                    let path = Path(
                        roundedRect: CGRect(x: x, y: y, width: width, height: height),
                        cornerRadius: radius
                    )
                    context.fill(path, with: .color(color))
                }
            case .ring:
                let center = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)
                let radius = min(size.width, size.height) / 3.0
                let width = 1.6 * CGFloat.pi * radius / CGFloat(range.count)
                let strokeStyle = StrokeStyle(lineWidth: width, lineCap: .round)
                range.forEach { index in
                    let phi = 2.0 * CGFloat.pi * CGFloat(index) / CGFloat(range.count)
                    let radius2 = CGFloat(1.0 + 0.5 * magnitudes[index].value) * radius
                    var path = Path()
                    path.move(to: CGPoint(
                        x: center.x + radius * cos(phi),
                        y: center.y + radius * sin(phi)
                    ))
                    path.addLine(to: CGPoint(
                        x: center.x + radius2 * cos(phi),
                        y: center.y + radius2 * sin(phi)
                    ))
                    context.stroke(path, with: .color(color), style: strokeStyle)
                }
            }
        }
    }
}

#Preview {
    AmplitudeSpectrumView(shapeType: .straight, magnitudes: [], range: nil, rms: nil)
}
