//
//  Date+Helpers.swift
//  GoogleSignInApp
//
//  Created by Santhosh Srinivas on 31/12/21.
//

import Foundation

extension Date{
    func descriptiveString(dateStyle: DateFormatter.Style = .short) -> String {
        
        
        let daysBetween = self.daysBetween(date:Date())
        
        if daysBetween == 0 {
            let formatter = DateFormatter()
    //        let formatter1 = DateFormatter()
            
            formatter.timeStyle = .short
            return formatter.string(from: self)
        } else if daysBetween == 1{
            let formatter = DateFormatter()
    //        let formatter1 = DateFormatter()
            
            formatter.dateStyle = dateStyle
            return "Yesterday"
        } else if daysBetween < 5{
            let formatter = DateFormatter()
    //        let formatter1 = DateFormatter()

            formatter.dateFormat = "E dd/MM/yy"
//            let weekdayIndex = Calendar.current.component(.weekday, from: self) - 1;
//            return formatter.weekdaySymbols[weekdayIndex]
            return formatter.string(from: self)
        }
        let formatter = DateFormatter()
//        let formatter1 = DateFormatter()
        
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
    
    func descriptiveString1(dateStyle: DateFormatter.Style = .short) -> String {
        
        
        let daysBetween = self.daysBetween(date:Date())
        
        if daysBetween == 0 {
            let formatter = DateFormatter()
    //        let formatter1 = DateFormatter()
            
            formatter.dateStyle = dateStyle
            return "Today"
        } else if daysBetween == 1{
            let formatter = DateFormatter()
    //        let formatter1 = DateFormatter()
            
            formatter.dateStyle = dateStyle
            return "Yesterday"
        }else if daysBetween < 5{
            let formatter = DateFormatter()
    //        let formatter1 = DateFormatter()

            formatter.dateFormat = "E dd/MM/yy"
//            let weekdayIndex = Calendar.current.component(.weekday, from: self) - 1;
//            return formatter.weekdaySymbols[weekdayIndex]
            return formatter.string(from: self)
        }
        let formatter = DateFormatter()
//        let formatter1 = DateFormatter()
        
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
    func daysBetween(date:Date) -> Int {
        let calender = Calendar.current
        let date1 = calender.startOfDay(for: self)
        let date2 = calender.startOfDay(for: date)
        if let daysBetween = calender.dateComponents([.day], from: date1, to: date2).day {
            return daysBetween
        }
        return 0
    }
}
