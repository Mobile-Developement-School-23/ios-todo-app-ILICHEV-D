import Foundation
import UIKit


public extension String {
    
    func colorFromHexString() -> UIColor? {
        var formattedHexString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if formattedHexString.hasPrefix("#") {
            formattedHexString.remove(at: formattedHexString.startIndex)
        }
        
        guard formattedHexString.count == 8 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: formattedHexString).scanHexInt64(&rgbValue)
        
        var red, green, blue, alpha: CGFloat
        
        red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
