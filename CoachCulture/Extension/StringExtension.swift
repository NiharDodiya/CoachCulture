
import Foundation

extension String {
    func getDateWithFormate(formate: String, timezone: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        //formatter.locale = .current
        formatter.timeZone = TimeZone(abbreviation: timezone)
        
        if let returnDate = formatter.date(from: self){
            return returnDate
        }else{
            return Date()
        }
    }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
