import SwiftUI

public struct AmplitudeSpectrumView: View {
    let magnitudes: [Magnitude]
    let range: Range<Int>
    let hue: Double?

    public init(magnitudes: [Magnitude], range: Range<Int>?, rms: Float?) {
        self.magnitudes = magnitudes
        self.range = range ?? magnitudes.indices
        if let rms {
            let _hue = min(Double(rms), 0) + 0.5
            hue = _hue < 1.0 ? _hue : _hue - 1.0
        } else {
            hue = nil
        }
    }

    public var body: some View {
        Canvas { context, size in
            let unit = size.width / CGFloat(range.count)
            let color = if let hue {
                Color(hue: hue, saturation: 0.7, brightness: 0.8)
            } else {
                Color.primary
            }
            range.forEach { index in
                let x = unit * CGFloat(index)
                let h = size.height * CGFloat(magnitudes[index].value)
                let y = 0.5 * (size.height - h)
                let path = Path(
                    roundedRect: CGRect(x: x, y: y, width: 3, height: h),
                    cornerRadius: 1.5
                )
                context.fill(path, with: .color(color))
            }
        }
    }
}

#Preview {
    AmplitudeSpectrumView(magnitudes: [], range: nil, rms: nil)
}
