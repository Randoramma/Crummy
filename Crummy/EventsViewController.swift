//
//  EventsViewController.swift
//  Crummy
//
//  Created by Josh Nagel on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:
    //MARK: Outlets and Variables
    
    @IBOutlet weak var constraintButtonViewContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintDatePickerCenterX: NSLayoutConstraint!
    @IBOutlet weak var constraintToolbarCenterX: NSLayoutConstraint!
    @IBOutlet weak var temperatureButton: UIButton!
    @IBOutlet weak var medicationButton: UIButton!
    @IBOutlet weak var symptomButton: UIButton!
    @IBOutlet weak var measurementButton: UIButton!
    @IBOutlet weak var symptomsDoneButton: UIButton!
    @IBOutlet weak var measurementsDoneButton: UIButton!
    @IBOutlet weak var temperatureDoneButton: UIButton!
    @IBOutlet weak var medicationDoneButton: UIButton!
    @IBOutlet weak var symptomsTextField: UITextField!
    @IBOutlet weak var measurementsHeightTextField: UITextField!
    @IBOutlet weak var measurementWeightTextField: UITextField!
    @IBOutlet weak var temperatureTextField: UITextField!
    @IBOutlet weak var medicationTextField: UITextField!
    @IBOutlet weak var eventTypeContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let crummyApiService = CrummyApiService()
    let medicationContainerViewHeight: CGFloat = 75
    let measurementsContainerViewHeight: CGFloat = 96
    let symptomsContainerViewHeight: CGFloat = 75
    let temperatureContainerViewHeight: CGFloat = 86
    let medicationCellHeight: CGFloat = 56
    let measurementCellHeight: CGFloat = 92
    let symptomsCellHeight: CGFloat = 55
    let temperatureCellHeight: CGFloat = 53
    let eventTypeContainerHeight: CGFloat = 75
    let toolBarHeight: CGFloat = 50
    let headerHeight: CGFloat = 32
    let rowSelectedBorderSize: CGFloat = 3
    let animationDuration: Double = 0.2
    let longerAnimationDuration: Double = 0.4
    let headerViewFrame: CGRect = CGRect(x: 15, y: 0, width: 300, height: 30)
    let titleFontSize: CGFloat = 20
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
    let headerFontSize: CGFloat = 23
    let titleColor = UIColor(red: 0.060, green: 0.158, blue: 0.408, alpha: 1.000)
    let eventTypeConstraintBuffer: CGFloat = 600
    let kid = Kid()
    let dateFormatter = DateFormatter()
    let kidId: String? = nil
    let kidName: String? = nil
    
    var currentCellHeight: CGFloat = 0
    var currentContainerViewHeight: CGFloat = 0
    var constraintContainerViewBottom: NSLayoutConstraint?
    var currentTextField: UITextField?
    var keyboardHeight: CGFloat = 0
    var selectedType: EventType?
    var currentContainerView: UIView?
    var sections = [[Event]]()
    var currentCellY: CGFloat?
    var contentOffsetChangeAmount: CGFloat?
    var currentEvent: Event?
    var allEvents = [Event]()
    var currentCell: UITableViewCell?
    var currentFilterType: EventType?
    
    //MARK:
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.dataSource = self
        self.constraintDatePickerCenterX.constant = -self.view.frame.width
        self.constraintToolbarCenterX.constant = -self.view.frame.width
        
        let containerBarColor = UIColor(patternImage: UIImage(named: "ContainerViewBar")!)
        self.eventTypeContainerView.backgroundColor = containerBarColor
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = self.titleColor
        self.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: self.titleFontSize)
        self.titleLabel.text = "Events - \(self.kidName!)"
        self.navigationItem.titleView = self.titleLabel
        
        var cellNib = UINib(nibName: "MedicationTableViewCell", bundle: Bundle.main)
        self.tableView.register(cellNib, forCellReuseIdentifier: "MedicationCell")
        cellNib = UINib(nibName: "MeasurementsTableViewCell", bundle: Bundle.main)
        self.tableView.register(cellNib, forCellReuseIdentifier: "MeasurementCell")
        cellNib = UINib(nibName: "TemperatureTableViewCell", bundle: Bundle.main)
        self.tableView.register(cellNib, forCellReuseIdentifier: "TemperatureCell")
        cellNib = UINib(nibName: "SymptomsTableViewCell", bundle: Bundle.main)
        self.tableView.register(cellNib, forCellReuseIdentifier: "SymptomCell")
        
        self.getEventsByType(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    //MARK:
    //MARK: Custom Methods
    
    func getEventsByType(_ type: EventType?) {
        self.activityIndicator.startAnimating()
        self.crummyApiService.getEvents(self.kidId!, completionHandler: { (events, error) -> (Void) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                self.presentErrorAlert(error!)
            } else {
                if let eventType = type {
                    self.titleLabel.text = "\(eventType.filterDisplayValue()) - \(self.kidName!)"
                    self.currentFilterType = eventType
                    if !events!.isEmpty {
                        var filteredEvents = [Event]()
                        for event in events! {
                            if event.type == eventType {
                                filteredEvents.append(event)
                            }
                        }
                        self.kid.events = filteredEvents
                    }
                } else {
                    self.kid.events = events!
                    self.titleLabel.text = "Events - \(self.kidName!)"
                    self.currentFilterType = nil
                }
                self.getSections(true)
                self.tableView.reloadData()
            }
        })
    }
    
    func presentErrorAlert(_ error: String?) {
        let alertController = UIAlertController(title: "An Error Occurred", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func eventTypePressed(_ sender: UIButton) {
        self.constraintButtonViewContainerBottom.constant += self.eventTypeContainerHeight
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        if sender == self.medicationButton {
            self.selectedType = EventType.medication
            let medicationView = Bundle.main.loadNibNamed("MedicationContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = medicationView
            medicationView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(medicationView)
            self.view.addConstraint(NSLayoutConstraint(item: medicationView, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: medicationView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            self.constraintContainerViewBottom =  NSLayoutConstraint(item: medicationView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constraintContainerViewBottom!)
            medicationView.addConstraint(NSLayoutConstraint(item: medicationView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: self.medicationContainerViewHeight))
            self.medicationTextField.delegate = self
        } else if sender == self.measurementButton {
            self.selectedType = EventType.measurement
            let measurementView = Bundle.main.loadNibNamed("MeasurementsContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = measurementView
            self.view.addSubview(measurementView)
            measurementView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: measurementView, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: measurementView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            self.constraintContainerViewBottom =  NSLayoutConstraint(item: measurementView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constraintContainerViewBottom!)
            measurementView.addConstraint(NSLayoutConstraint(item: measurementView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: self.measurementsContainerViewHeight))
            self.measurementsHeightTextField.delegate = self
            self.measurementWeightTextField.delegate = self
        } else if sender == self.symptomButton {
            self.selectedType = EventType.symptom
            let symptomsView = Bundle.main.loadNibNamed("SymptomsContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = symptomsView
            self.view.addSubview(symptomsView)
            symptomsView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: symptomsView, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: symptomsView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            self.constraintContainerViewBottom =  NSLayoutConstraint(item: symptomsView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constraintContainerViewBottom!)
            symptomsView.addConstraint(NSLayoutConstraint(item: symptomsView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: self.symptomsContainerViewHeight))
            self.symptomsTextField.delegate = self
        } else if sender == self.temperatureButton {
            self.selectedType = EventType.temperature
            let temperatureView = Bundle.main.loadNibNamed("TemperatureContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = temperatureView
            self.view.addSubview(temperatureView)
            temperatureView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: temperatureView, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: temperatureView, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            self.constraintContainerViewBottom =  NSLayoutConstraint(item: temperatureView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constraintContainerViewBottom!)
            temperatureView.addConstraint(NSLayoutConstraint(item: temperatureView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: self.temperatureContainerViewHeight))
            self.temperatureTextField.delegate = self
        }
        let containerBarColor = UIColor(patternImage: UIImage(named: "ContainerViewBar")!)
        self.currentContainerView!.backgroundColor = containerBarColor
    }
    
    
    func dismissKeyboard() {
        if self.medicationTextField != nil && self.medicationTextField.isFirstResponder {
            self.medicationTextField.resignFirstResponder()
        } else if self.measurementsHeightTextField != nil && measurementsHeightTextField.isFirstResponder {
            self.measurementsHeightTextField.resignFirstResponder()
        } else if self.symptomsTextField != nil && symptomsTextField.isFirstResponder {
            self.symptomsTextField.resignFirstResponder()
        } else if self.temperatureTextField != nil && temperatureTextField.isFirstResponder {
            self.temperatureTextField.resignFirstResponder()
        }
        self.constraintContainerViewBottom!.constant = 0
        self.tableView.isUserInteractionEnabled = true
        self.selectedType = nil
    }
    
    func dismissKeyboard(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.constraintContainerViewBottom!.constant = 0
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.tableView.isUserInteractionEnabled = true
        self.selectedType = nil
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardHeight = keyboardSize.height
                self.constraintContainerViewBottom?.constant = -self.keyboardHeight
                UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
        if currentEvent != nil {
            _ = self.view.frame.height
            let cellBottomY = currentCellY! + self.currentCellHeight
            let visibleView = self.view.frame.height - self.keyboardHeight
            if cellBottomY > visibleView - self.currentContainerViewHeight {
                self.contentOffsetChangeAmount = cellBottomY - visibleView + self.currentContainerViewHeight
                self.animateTableViewOffset(false)
            }
        }
    }
    
    func animateTableViewOffset(_ toOriginalOffset: Bool) {
        if toOriginalOffset {
            self.tableView.contentOffset.y = self.tableView.contentOffset.y - self.contentOffsetChangeAmount!
        } else {
            self.tableView.contentOffset.y = self.tableView.contentOffset.y + self.contentOffsetChangeAmount!
        }
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func duplicatePressed(_ sender: UIButton) {
        if self.currentCell != nil {
            return
        }
        
        if let contentView = sender.superview,
            let cell = contentView.superview as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            let section = self.sections[indexPath.section]
            let eventToDuplicate = section[indexPath.row]
            let newEvent = Event(id: nil, type: eventToDuplicate.type, temperature: eventToDuplicate.temperature, medication: eventToDuplicate.medication, height: eventToDuplicate.height, weight: eventToDuplicate.weight, symptom: eventToDuplicate.symptom, date: Date())
            self.createOrUpdateEvent(newEvent)
        }
    }
    
    func createOrUpdateEvent(_ event: Event) {
        if event.id != nil {
            self.getSections(false)
            self.tableView.reloadData()
            self.crummyApiService.editEvent(self.kidId!, event: event) { (event, error) -> (Void) in
                if error != nil {
                    self.presentErrorAlert(error!)
                }
            }
        } else {
            self.crummyApiService.createEvent(self.kidId!, event: event) { (eventId, error) -> (Void) in
                if error != nil {
                    self.presentErrorAlert(error!)
                } else {
                    if let id = eventId {
                        event.id = id
                    }
                }
            }
            if self.currentFilterType == event.type || self.currentFilterType == nil {
                if self.allEvents.count > 0 {
                    self.sections[0].insert(event, at: 0)
                } else {
                    self.sections.append([event])
                }
                self.getSections(false)
                self.tableView.reloadData()
            }
        }
    }
    
    func getSections(_ isOnLoad: Bool) {
        if isOnLoad {
            self.allEvents = self.kid.events
        } else {
            self.allEvents = self.sections.flatMap{ $0 }
        }
        self.allEvents.sorted(by: { $0.date.compare($1.date as Date) == ComparisonResult.orderedDescending })
        self.sections.removeAll(keepingCapacity: false)
        self.sections = [[Event]]()
        var checkedEvents = [Event]()
        for event in self.allEvents {
            let date = event.date
            let cal = Calendar.current
            let yearComponent = cal.component(Calendar.Component.year, from: date)
            let monthComponent = cal.component(Calendar.Component.month, from: date)
            let dayComponent = cal.component(Calendar.Component.day, from: date)
            if checkedEvents.isEmpty {
                self.sections.append([event])
                checkedEvents.append(event)
            } else {
                let lastCheckedEvent = checkedEvents.last
                checkedEvents.append(event)
                let checkedYearComponent = cal.component(Calendar.Component.year, from: lastCheckedEvent!.date)
                let checkedMonthComponent = cal.component(Calendar.Component.month, from: lastCheckedEvent!.date)
                let checkedDayComponent = cal.component(Calendar.Component.day, from: lastCheckedEvent!.date)
                
                if yearComponent == checkedYearComponent && monthComponent == checkedMonthComponent && dayComponent == checkedDayComponent {
                    self.sections[sections.count - 1].append(event)
                } else {
                    self.sections.append([event])
                }
            }
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton?) {
        self.currentContainerView?.removeFromSuperview()
        self.currentContainerView = nil
        self.constraintButtonViewContainerBottom.constant = 0
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.currentEvent = nil
        self.tableView.isUserInteractionEnabled = true
        if let cell = currentCell {
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.borderWidth = 0
            cell.isSelected = false
            self.currentCell = nil
        }
        if self.contentOffsetChangeAmount != nil {
            self.animateTableViewOffset(true)
            self.contentOffsetChangeAmount = nil
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let event: Event
        if self.medicationDoneButton != nil && sender == self.medicationDoneButton {
            self.medicationTextField.resignFirstResponder()
            if !(self.medicationTextField.text?.isEmpty)! {
                if let updateEvent = self.currentEvent {
                    event = updateEvent
                    event.medication = medicationTextField.text
                } else {
                    event = Event(id: nil, type: EventType.medication, temperature: nil, medication: self.medicationTextField.text, height: nil, weight: nil, symptom: nil, date: Date())
                }
                self.createOrUpdateEvent(event)
            }
            self.medicationTextField.text = nil
        } else if self.measurementsDoneButton != nil && sender == self.measurementsDoneButton {
            self.measurementsHeightTextField.resignFirstResponder()
            self.measurementWeightTextField.resignFirstResponder()
            if let height : String = self.measurementsHeightTextField.text {
                if let weight: String = self.measurementWeightTextField.text {
                    if let updatedEvent = self.currentEvent {
                        event = updatedEvent
                        event.height = height
                        event.weight = weight
                    } else {
                        event = Event(id: nil, type: EventType.measurement, temperature: nil, medication: nil, height: height, weight:  weight, symptom: nil, date: Date())
                    }
                    self.createOrUpdateEvent(event)
                }
            }

            self.measurementsHeightTextField.text = nil
            self.measurementWeightTextField.text = nil
        } else if self.symptomsDoneButton != nil && sender == self.symptomsDoneButton {
            self.symptomsTextField.resignFirstResponder()
            if !(self.symptomsTextField.text?.isEmpty)! {
                if let updatedEvent = self.currentEvent {
                    event = updatedEvent
                    event.symptom = self.symptomsTextField.text
                } else {
                    event = Event(id: nil, type: EventType.symptom, temperature: nil, medication: nil, height: nil, weight: nil, symptom: self.symptomsTextField.text, date: Date())
                }
                self.createOrUpdateEvent(event)
            }
            self.symptomsTextField.text = nil
        } else if self.temperatureDoneButton != nil && sender == self.temperatureDoneButton {
            self.temperatureTextField.resignFirstResponder()
            if !(self.temperatureTextField.text?.isEmpty)! {
                if let updateEvent = self.currentEvent {
                    event = updateEvent
                    event.temperature = self.temperatureTextField.text
                } else {
                    event = Event(id: nil, type: EventType.temperature, temperature: self.temperatureTextField.text, medication: nil, height: nil, weight: nil, symptom: nil, date: Date())
                }
                self.createOrUpdateEvent(event)
            }
            self.temperatureTextField.text = nil
        }
        self.constraintButtonViewContainerBottom.constant = 0
        self.eventTypeContainerView.alpha = 0
        self.currentContainerView?.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.eventTypeContainerView.alpha = 1
            self.view.layoutIfNeeded()
        })
        self.tableView.isUserInteractionEnabled = true
        self.currentEvent = nil
        if let cell = currentCell {
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.borderWidth = 0
            self.currentCell = nil
        }
        self.currentContainerView = nil
        if self.contentOffsetChangeAmount != nil {
            self.animateTableViewOffset(true)
            self.contentOffsetChangeAmount = nil
        }
    }
    
    func showDatePicker(_ button: UIButton) {
        if self.currentCell != nil {
            return
        }
        self.tableView.isUserInteractionEnabled = false
        self.eventTypeContainerView.isUserInteractionEnabled = false
        if let contentView = button.superview,
            let cell = contentView.superview as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            let section = indexPath.section
            let event = self.sections[section][indexPath.row]
            self.currentEvent = event
            self.datePicker.date = event.date as Date
            self.datePicker.frame.height + self.view.frame.height
            self.constraintDatePickerCenterX.constant = 0
            self.constraintToolbarCenterX.constant = 0
            UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.datePicker.backgroundColor = UIColor.white
            })
        }
    }
    
    @IBAction func doneDatePicker(_ sender: UIBarButtonItem) {
        if let event = self.currentEvent {
            if event.date as Date != self.datePicker.date {
                event.date = self.datePicker.date
                self.getSections(false)
                self.tableView.reloadData()
                self.createOrUpdateEvent(event)
            }
            self.tableView.isUserInteractionEnabled = true
            self.eventTypeContainerView.isUserInteractionEnabled = true
            self.constraintDatePickerCenterX.constant = -self.view.frame.width
            self.constraintToolbarCenterX.constant = -self.view.frame.width
            UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.datePicker.backgroundColor = UIColor.white
            })
        }
        self.currentEvent = nil
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Filter By Type", message: nil, preferredStyle: .actionSheet)
        let allFilterAction = UIAlertAction(title: "All Events", style: .default) { (action) -> Void in
            self.getEventsByType(nil)
        }
        alertController.addAction(allFilterAction)
        let medFilterAction = UIAlertAction(title: EventType.medication.filterDisplayValue(), style: .default) { (action) -> Void in
            self.getEventsByType(EventType.medication)
        }
        alertController.addAction(medFilterAction)
        let measurementFilterAction = UIAlertAction(title: EventType.measurement.filterDisplayValue(), style: .default) { (action) -> Void in
            self.getEventsByType(EventType.measurement)
        }
        alertController.addAction(measurementFilterAction)
        let symptomFilterAction = UIAlertAction(title: EventType.symptom.filterDisplayValue(), style: .default) { (action) -> Void in
            self.getEventsByType(EventType.symptom)
        }
        alertController.addAction(symptomFilterAction)
        let temperatureFilterAction = UIAlertAction(title: EventType.temperature.filterDisplayValue(), style: .default) { (action) -> Void in
            self.getEventsByType(EventType.temperature)
        }
        alertController.addAction(temperatureFilterAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK:
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.dismissKeyboard(textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.measurementsHeightTextField != nil && (textField == self.measurementsHeightTextField ||
            textField == self.measurementWeightTextField) &&
            self.constraintContainerViewBottom?.constant == 0 {
            self.constraintContainerViewBottom?.constant = -self.keyboardHeight
            UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.measurementsHeightTextField != nil && textField == self.measurementsHeightTextField {
            self.measurementWeightTextField.becomeFirstResponder()
            return false
        } else {
            self.dismissKeyboard(textField)
            
            if self.contentOffsetChangeAmount != nil {
                self.tableView.contentOffset.y -= self.contentOffsetChangeAmount!
                UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
            self.contentOffsetChangeAmount != nil
            
            self.currentContainerView?.removeFromSuperview()
            self.constraintButtonViewContainerBottom.constant = 0
            UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            if let cell = currentCell {
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
                cell.contentView.layer.borderWidth = 0
                cell.isSelected = false
                self.currentCell = nil
            }
            self.tableView.isUserInteractionEnabled = true
            return true
        }
    }
    
    func doneNumberPadPressed(_ barButton: UIBarButtonItem) {
        self.currentTextField!.resignFirstResponder()
        if self.contentOffsetChangeAmount != nil {
            self.tableView.contentOffset.y -= self.contentOffsetChangeAmount!
            UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        self.contentOffsetChangeAmount = nil
        
    }
    
    func enteredTextField(_ textField: UITextField) {
        if let contentView = textField.superview,
            let cell = contentView.superview as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell)
        {
            let rectOfCellInTableView = tableView.rectForRow(at: indexPath)
            let rectOfCellInSuperview = tableView.convert(rectOfCellInTableView, to: self.view)
            self.currentCellY = rectOfCellInSuperview.origin.y
            textField.delegate = self
            self.currentTextField = textField
            let section = self.sections[indexPath.section]
            let eventType = section[indexPath.row].type
            if eventType == EventType.measurement || eventType == EventType.temperature {
                if eventType == EventType.measurement {
                    self.currentCellHeight = self.measurementCellHeight
                } else {
                    self.currentCellHeight = self.temperatureCellHeight
                }
                let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.toolBarHeight))
                toolBar.barStyle = UIBarStyle.default
                let doneBarButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(EventsViewController.doneNumberPadPressed(_:)))
                toolBar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),doneBarButton]
                toolBar.sizeToFit()
                textField.inputAccessoryView = toolBar
            } else if eventType == EventType.symptom {
                self.currentCellHeight = self.symptomsCellHeight
            } else {
                self.currentCellHeight = self.medicationCellHeight
            }
        }
    }
    
    //MARK:
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        self.dateFormatter.dateFormat = "hh:mm a"
        let event = section[indexPath.row]
        if event.type == EventType.medication {
            let medicationCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for: indexPath) as! MedicationTableViewCell
            medicationCell.medicationLabel.text = nil
            medicationCell.timeButton.setTitle(nil, for: UIControlState())
            medicationCell.medicationLabel.text = event.medication
            medicationCell.timeButton.setTitle(self.dateFormatter.string(from: event.date as Date), for: UIControlState())
            medicationCell.timeButton.addTarget(self, action: #selector(EventsViewController.showDatePicker(_:)), for: UIControlEvents.touchUpInside)
            medicationCell.duplicateButton.addTarget(self, action: #selector(EventsViewController.duplicatePressed(_:)), for: UIControlEvents.touchUpInside)
            return medicationCell
        } else if event.type == EventType.measurement {
            let measurementCell = tableView.dequeueReusableCell(withIdentifier: "MeasurementCell", for: indexPath) as! MeasurementTableViewCell
            measurementCell.heightLabel.text = nil
            measurementCell.weightLabel.text = nil
            measurementCell.timeButton.setTitle(nil, for: UIControlState())
            measurementCell.weightLabel.text = event.weight
            measurementCell.heightLabel.text = event.height
            measurementCell.timeButton.setTitle(self.dateFormatter.string(from: event.date as Date), for: UIControlState())
            measurementCell.timeButton.addTarget(self, action: #selector(EventsViewController.showDatePicker(_:)), for: UIControlEvents.touchUpInside)
            measurementCell.duplicateButton.addTarget(self, action: #selector(EventsViewController.duplicatePressed(_:)), for: UIControlEvents.touchUpInside)
            return measurementCell
        } else if event.type == EventType.symptom {
            let symptomCell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell", for: indexPath) as! SymptomsTableViewCell
            symptomCell.symptomsLabel.text = nil
            symptomCell.timeButton.setTitle(nil, for: UIControlState())
            symptomCell.symptomsLabel.text = event.symptom
            symptomCell.timeButton.setTitle(self.dateFormatter.string(from: event.date as Date), for: UIControlState())
            symptomCell.timeButton.addTarget(self, action: #selector(EventsViewController.showDatePicker(_:)), for: UIControlEvents.touchUpInside)
            symptomCell.duplicateButton.addTarget(self, action: #selector(EventsViewController.duplicatePressed(_:)), for: UIControlEvents.touchUpInside)
            return symptomCell
        } else {
            let temperatureCell = tableView.dequeueReusableCell(withIdentifier: "TemperatureCell", for: indexPath) as! TemperatureTableViewCell
            temperatureCell.temperatureLabel.text = nil
            temperatureCell.timeButton.setTitle(nil, for: UIControlState())
            temperatureCell.temperatureLabel.text = event.temperature
            temperatureCell.timeButton.setTitle(self.dateFormatter.string(from: event.date as Date), for: UIControlState())
            temperatureCell.timeButton.addTarget(self, action: #selector(EventsViewController.showDatePicker(_:)), for: UIControlEvents.touchUpInside)
            temperatureCell.duplicateButton.addTarget(self, action: #selector(EventsViewController.duplicatePressed(_:)), for: UIControlEvents.touchUpInside)
            return temperatureCell
        }
    }
    
    //MARK:
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        let event = section[indexPath.row]
        if event.type == EventType.medication {
            return self.medicationCellHeight
        } else if event.type == EventType.measurement {
            return self.measurementCellHeight
        } else if event.type == EventType.symptom {
            return self.symptomsCellHeight
        } else {
            return self.temperatureCellHeight
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        
        let cal = Calendar.current
        let dateForSection = cal.startOfDay(for: section.first!.date as Date)
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: Calendar.Component.day, value: -1, to: today)
        if today == dateForSection {
            return "Today"
        } else if yesterday == dateForSection {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM dd"
            let dateStr = dateFormatter.string(from: dateForSection)
            return dateStr
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let currentSection = indexPath.section
        self.crummyApiService.deleteEvent(self.kidId!, eventId: self.sections[currentSection][indexPath.row].id!) { (eventId, error) -> (Void) in
            if error != nil {
                self.presentErrorAlert(error!)
            }
        }
        var section = self.sections[indexPath.section]
        section.remove(at: indexPath.row)
        self.sections[indexPath.section] = section
        let indexPaths = [indexPath]
        
        if section.count < 1 {
            self.sections.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.left)
        } else {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) {
            currentCell.contentView.layer.borderColor = UIColor.clear.cgColor
            currentCell.contentView.layer.borderWidth = 0
            self.currentCell = nil
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.menuButtonPressed(nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) {
            if currentCell == self.currentCell {
                self.tableView(tableView, didDeselectRowAt: indexPath)
                if self.contentOffsetChangeAmount != nil {
                    self.animateTableViewOffset(true)
                    self.contentOffsetChangeAmount = nil
                }
                return
            }
            currentCell.contentView.layer.borderColor = UIColor.red.cgColor
            currentCell.contentView.layer.borderWidth = self.rowSelectedBorderSize
            self.currentCell = currentCell
            let rectOfCellInTableView = tableView.rectForRow(at: indexPath)
            let rectOfCellInSuperview = tableView.convert(rectOfCellInTableView, to: self.view)
            self.currentCellY = rectOfCellInSuperview.origin.y
        }
        if currentContainerView != nil {
            self.currentContainerView!.removeFromSuperview()
            self.constraintButtonViewContainerBottom.constant = 0
            UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        let currentSection = indexPath.section
        let event = self.sections[currentSection][indexPath.row]
        self.currentEvent = event
        self.constraintButtonViewContainerBottom.constant += self.eventTypeContainerHeight
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        if event.type == EventType.medication {
            self.selectedType = EventType.medication
            let medicationView = Bundle.main.loadNibNamed("MedicationContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = medicationView
            self.currentContainerViewHeight = medicationContainerViewHeight
            self.constraintContainerViewBottom = NSLayoutConstraint(item: medicationView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.currentContainerViewHeight = self.medicationContainerViewHeight
            self.medicationTextField.delegate = self
            self.medicationTextField.text = event.medication
            self.currentCellHeight = self.medicationCellHeight
            self.medicationTextField.becomeFirstResponder()
        } else if event.type == EventType.measurement {
            self.selectedType = EventType.measurement
            let measurementView = Bundle.main.loadNibNamed("MeasurementsContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = measurementView
            self.currentContainerViewHeight = measurementsContainerViewHeight
            self.constraintContainerViewBottom = NSLayoutConstraint(item: measurementView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.currentContainerViewHeight = self.measurementsContainerViewHeight
            self.measurementsHeightTextField.delegate = self
            self.measurementWeightTextField.delegate = self
            self.measurementsHeightTextField.text = event.height
            self.measurementWeightTextField.text = event.weight
            self.currentCellHeight = self.measurementCellHeight
            self.measurementsHeightTextField.becomeFirstResponder()
        } else if event.type == EventType.symptom {
            self.selectedType = EventType.symptom
            let symptomsView = Bundle.main.loadNibNamed("SymptomsContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = symptomsView
            self.currentContainerViewHeight = self.symptomsContainerViewHeight
            self.constraintContainerViewBottom = NSLayoutConstraint(item: symptomsView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.symptomsTextField.delegate = self
            self.symptomsTextField.text = event.symptom
            self.currentCellHeight = self.symptomsCellHeight
            self.symptomsTextField.becomeFirstResponder()
        } else if event.type == EventType.temperature {
            self.selectedType = EventType.temperature
            let temperatureView = Bundle.main.loadNibNamed("TemperatureContainerView", owner: self, options: nil)?.first as! UIView
            self.currentContainerView = temperatureView
            self.currentContainerViewHeight = temperatureContainerViewHeight
            self.constraintContainerViewBottom = NSLayoutConstraint(item: temperatureView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            self.currentContainerViewHeight = self.temperatureContainerViewHeight
            self.temperatureTextField.delegate = self
            self.temperatureTextField.text = event.temperature
            self.currentCellHeight = self.temperatureCellHeight
            self.temperatureTextField.becomeFirstResponder()
        }
        self.currentContainerView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.currentContainerView!)
        let constraintTrailing = NSLayoutConstraint(item: self.currentContainerView!, attribute: NSLayoutAttribute.trailing, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: self.eventTypeConstraintBuffer)
        self.view.addConstraint(constraintTrailing)
        let constraintLeading = NSLayoutConstraint(item: self.currentContainerView!, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -self.eventTypeConstraintBuffer)
        self.view.addConstraint(constraintLeading)
        self.view.addConstraint(self.constraintContainerViewBottom!)
        self.currentContainerView!.addConstraint(NSLayoutConstraint(item: self.currentContainerView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: self.currentContainerViewHeight))
        self.view.layoutIfNeeded()
        constraintTrailing.constant = 0
        constraintLeading.constant = 0
        self.currentContainerView!.alpha = 0
        UIView.animate(withDuration: self.longerAnimationDuration, animations: { () -> Void in
            self.currentContainerView!.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CustomHeaderView(width: self.view.frame.width)
        let headerLabel = UILabel(frame: self.headerViewFrame)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "HelveticaNeue-Light", size: self.headerFontSize)
        view.addSubview(headerLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
}
