import Foundation

public extension Date {

    static var tomorrow: Date {
        let calendar = Calendar.current
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight) {
            return tomorrow
        }
        return today
    }

}
