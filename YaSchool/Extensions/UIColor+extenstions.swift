import UIKit

public extension UIColor {

    var hexString: String {
        let components = self.cgColor.components
        let red = Float(components?[0] ?? 0.0)
        let green = Float(components?[1] ?? 0.0)
        let blue = Float(components?[2] ?? 0.0)
        let alpha = Float(components?[3] ?? 1.0)

        return String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(red * 255),
            lroundf(green * 255),
            lroundf(blue * 255),
            lroundf(alpha * 255)
        )
    }

}
