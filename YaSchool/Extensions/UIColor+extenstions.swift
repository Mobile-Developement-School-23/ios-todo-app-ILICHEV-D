import UIKit

public extension UIColor {
    
    var hexString: String {
        let components = self.cgColor.components
        let r = Float(components?[0] ?? 0.0)
        let g = Float(components?[1] ?? 0.0)
        let b = Float(components?[2] ?? 0.0)
        let a = Float(components?[3] ?? 1.0)
        
        return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    }
    
}

