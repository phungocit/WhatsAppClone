//
//  Date+.swift
//  WhatsAppClone
//
//  Created by Foo Tran on 4/14/24.
//

import Foundation

extension Date {
    /// if today: 3:30 PM
    /// if yesterday returns Yesterday
    /// 02/15/24
    var dayOrTimeRepresentation: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedDate = dateFormatter.string(from: self)
            return formattedDate

        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: self)
        }
    }

    /// 3:30 PM
    var formatToTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let formattedTime = dateFormatter.string(from: self)
        return formattedTime
    }

    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        }
        if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }
        if isCurrentWeek {
            return toString(format: "EEEE") // Monday
        }
        if isCurrentYear {
            return toString(format: "EEE, MMM d") // "Mon, Feb 10"
        }
        return toString(format: "MMM dd, yyyy") // "Mon, Feb 10, 2000"
    }

    func isSameDay(as otherDay: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDay)
    }

    private var isCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekday)
    }

    private var isCurrentYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
}
