//
//  ViewController.swift
//  TimeDecisionMaker
//
//  Created by Mikhail on 4/24/19.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DateTimePickerDelegate {
    
    @IBOutlet weak var appointmentView: UITableView!
    @IBOutlet weak var availabilityView: UITableView!
    
    let orgPath = Bundle.main.path(forResource: "A", ofType: "ics")!
    let attendeePath = Bundle.main.path(forResource: "B", ofType: "ics")!
    let decisionMaker = RDTimeDecisionMaker()
    let appointmentCellReuseIdentifier = "appointmentCell"
    let availabilityCellReuseIdentifier = "availabilityCell"
    
    var appointmentInterval = [DateInterval]()
    var availabilityIntervalForA = [DateInterval]()
    var availabilityIntervalForB = [DateInterval]()
    
    // Number of sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == appointmentView {
            return 1
        } else if tableView == availabilityView {
            return 2
        }
        return Int()
    }
    
    // Number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == appointmentView {
            return self.appointmentInterval.count
        } else if tableView == availabilityView && section == 0 {
            return self.availabilityIntervalForA.count
        } else if tableView == availabilityView && section == 1 {
            return self.availabilityIntervalForB.count
        }
        return Int()
    }
    
    // Header for each section in table view
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == appointmentView {
            return "Appointment time slots: \(self.appointmentInterval.count)"
        } else if tableView == availabilityView && section == 0 {
            return "Availability time slots for person A: "
        } else if tableView == availabilityView && section == 1 {
            return "Availability time slots for person B: "
        }
        return String()
    }
    
    // Create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone.current
        
        if tableView == appointmentView,
            let cell:TableViewAppointmentCell = self.appointmentView.dequeueReusableCell(withIdentifier: appointmentCellReuseIdentifier) as? TableViewAppointmentCell {
            let startDate = formatter.date(from: self.appointmentInterval[indexPath.row].start.description)
            let endDate = formatter.date(from: self.appointmentInterval[indexPath.row].end.description)
            cell.startTimeLabel.text = "From: " + (startDate?.description(with: locale))!
            cell.endTimeLabel.text = "To: " + (endDate?.description(with: locale))!
            
            return cell
        } else if tableView == availabilityView && indexPath.section == 0,
            let cell:TableViewAvailabilityCell = self.availabilityView.dequeueReusableCell(withIdentifier: availabilityCellReuseIdentifier) as? TableViewAvailabilityCell {
            let date = formatter.date(from: self.availabilityIntervalForA[indexPath.row].start.description)
            cell.avalabilityLabel.text = date?.description(with: locale)
            
            return cell
        } else if tableView == availabilityView && indexPath.section == 1,
            let cell:TableViewAvailabilityCell = self.availabilityView.dequeueReusableCell(withIdentifier: availabilityCellReuseIdentifier) as? TableViewAvailabilityCell {
            let date = formatter.date(from: self.availabilityIntervalForB[indexPath.row].start.description)
            cell.avalabilityLabel.text = date?.description(with: locale)
            
            return cell
        }
        return UITableViewCell()
    }
    
    // Method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == appointmentView {
            let alertController = UIAlertController(title: "Appointment", message: "You chose appointment with interval from \(self.appointmentInterval[indexPath.row].start.description(with: Locale(identifier: "en_US"))) to \(self.appointmentInterval[indexPath.row].end.description(with: Locale(identifier: "en_US"))).", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appointmentView.delegate = self
        appointmentView.dataSource = self
        availabilityView.delegate = self
        availabilityView.dataSource = self
        appointmentView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func showDateTimePicker(sender: AnyObject) {
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 120)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 120)
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        
        picker.dateFormat = "dd/MM/YYYY"
        picker.includeTimer = true
        picker.includeMonth = true // if true the month shows at bottom of date cell
        picker.highlightColor = UIColor(red: 41.0/255.0, green: 122.0/255.0, blue: 230.0/255.0, alpha: 1)
        picker.doneButtonTitle = "Suggest Apointment"
        picker.doneBackgroundColor = UIColor(red: 252.0/255.0, green: 182.0/255.0, blue: 36.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYYMMdd"
            self.title = formatter.string(from: date)
            self.appointmentInterval = self.decisionMaker.suggestAppointments(organizerICS: self.orgPath, attendeeICS: self.attendeePath, date: self.title!, duration: picker.timerView.countDownDuration)
            
            self.availabilityIntervalForA = self.decisionMaker.personAvailability(ICS: self.orgPath, date: self.title!)
            self.availabilityIntervalForB = self.decisionMaker.personAvailability(ICS: self.attendeePath, date: self.title!)
            
            self.appointmentView.reloadData()
            self.availabilityView.reloadData()
        }
        picker.delegate = self
        picker.show()
    }
    
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
        title = picker.selectedDateString
    }


}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
