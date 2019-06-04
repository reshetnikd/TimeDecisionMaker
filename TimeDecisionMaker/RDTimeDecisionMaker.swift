//
//  RDTimeDecisionMaker.swift
//  TimeDecisionMaker
//
//  Created by Mikhail on 4/24/19.
//

import Foundation

class RDTimeDecisionMaker: NSObject {
    /// Main method to perform date interval calculation
    ///
    /// - Parameters:
    ///   - organizerICSPath: path to personA file with events
    ///   - attendeeICSPath: path to personB file with events
    ///   - duration: desired duration of appointment
    /// - Returns: array of available time slots, empty array if none found
    func suggestAppointments(organizerICS:String,
                             attendeeICS:String,
                             duration:TimeInterval) -> [DateInterval] {
        var appointmentsInterval:Array<DateInterval> = []
        
        let extractedTimeA = extractTimeFromEvent(from: organizerICS)
        let extractedTimeB = extractTimeFromEvent(from: attendeeICS)
        let extractDateIntervalA = createDayInterval(extractedTimeA)
        let extractDateIntervalB = createDayInterval(extractedTimeB)
        let freeTimeIntervalA = calculateFreeTimeInterval(from: extractDateIntervalA)
        let freeTimeIntervalB = calculateFreeTimeInterval(from: extractDateIntervalB)
        
        for i in freeTimeIntervalA {
            for j in freeTimeIntervalB {
                if let interval = i.intersection(with: j) {
                    if interval.duration >= duration {
                        appointmentsInterval.append(interval)
                    }
                }
            }
        }
        return appointmentsInterval
    }
    
    // Read file row by row
    func readFile(_ filePath: String) -> [String] {
        do {
            let contents = try String(contentsOfFile: filePath)
            return contents.components(separatedBy: "\r")
        } catch {
            // Contents could not be loaded
            return ["Contents could not be loaded."]
        }
    }
    
    // Search for event in row (contents)
    func searchForEvent(_ event: String, in row: String) -> String? {
        if let search = row.range(of: event, options: NSString.CompareOptions.literal, range: row.startIndex..<row.endIndex, locale: nil) {
            return String(row[search.lowerBound...]).components(separatedBy: ":").last
        } else {
            return nil
        }
    }
    
    // Extract time value from file by parametrs (DTSTART, DTEND) and return array of dates
    func extractTimeFromEvent(from file: String) -> [Date] {
        let contents = readFile(file)
        let formater = DateFormatter()
        formater.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        var index = 1
        var extractedTime = [Date]()
        for row in contents {
            if let searchStart = searchForEvent("DTSTART:", in: row) {
                extractedTime.append(formater.date(from: searchStart)!)
            }
            if let searchEnd = searchForEvent("DTEND:", in: row) {
                extractedTime.insert(formater.date(from: searchEnd)!, at: index)
                index += 2
            }
        }
        return extractedTime
    }
    
    // Create sorted DateInterval array from Date array
    func createDayInterval(_ timeData: [Date]) -> [DateInterval] {
        var extractDateInterval = [DateInterval]()
        var interval = DateInterval()
        for i in stride(from: 0, to: timeData.count, by: 2) {
            interval.start = timeData[i]
            interval.end = timeData[i+1]
            extractDateInterval.append(interval)
        }
        return extractDateInterval.sorted()
    }
    
    // Calculate free time slots for a chosen date
    func calculateFreeTimeInterval(from interval: [DateInterval]) -> [DateInterval] {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        formater.timeZone = TimeZone.current
        var freeTimeInterval = [DateInterval]()
        var allDayTimeInterval = DateInterval(start: formater.date(from: interval[0].description.components(separatedBy: " ").first!)!, duration: 24*3600)
        var tempTimeInterval = allDayTimeInterval
        for i in 0..<interval.count {
            tempTimeInterval.end = interval[i].start
            freeTimeInterval.append(tempTimeInterval)
            tempTimeInterval.start = interval[i].end
        }
        allDayTimeInterval = DateInterval(start: formater.date(from: interval[interval.count-1].description.components(separatedBy: " ").first!)!, duration: 24*3600)
        tempTimeInterval.end = allDayTimeInterval.end
        freeTimeInterval.append(tempTimeInterval)
        return freeTimeInterval
    }
}
