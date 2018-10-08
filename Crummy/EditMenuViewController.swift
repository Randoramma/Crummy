//
//  EditMenuViewController.swift
//  Crummy
//
//  Created by Josh Nagel on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//
import UIKit

class EditMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var tableView: UITableView!
  
  let crummyApiService = CrummyApiService()
  let headerViewFrame: CGRect = CGRect(x: 15, y: 0, width: 300, height: 30)
  let headerFontSize: CGFloat = 23
  let headerHeight: CGFloat = 32
  var kiddo: Kid!
  var kidList: [Kid]?
  let titleFontSize: CGFloat = 26
  let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
  let titleColor = UIColor(red: 0.060, green: 0.158, blue: 0.408, alpha: 1.000)
  var indexPaths: [IndexPath]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.titleLabel.textAlignment = .center
    self.titleLabel.textColor = self.titleColor
    self.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: self.titleFontSize)
    self.titleLabel.text = "Edit Menu"
    self.navigationItem.titleView = self.titleLabel
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.activityIndicator.startAnimating()
    self.crummyApiService.listKid { (kidList, error) -> (Void) in
      if let errorDescription = error {
        let alertController = UIAlertController(title: "An Error Occurred", message: errorDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) -> Void in
          self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      } else {
        self.kidList = kidList!
        self.tableView.reloadData()
        self.activityIndicator.stopAnimating()
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let kidCount = self.kidList?.count {
      return kidCount
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "EditMenuCell", for: indexPath) as! EditMenuTableViewCell
    cell.textLabel?.text = nil
    if let kids = self.kidList?[indexPath.row] {
      cell.textLabel!.text = kids.name
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let selectedMunchkin = self.kidList?[indexPath.row]
    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "EditKidVC") as! EditKidViewController
    viewController.selectedKid = selectedMunchkin
    self.navigationController?.pushViewController(viewController, animated: false)
  }
  
  @IBAction func addButtonPressed(_ sender: AnyObject) {
    let destinationController = storyboard?.instantiateViewController(withIdentifier: "EditKidVC") as? EditKidViewController
    destinationController?.selectedKid = nil
    
    performSegue(withIdentifier: "ShowEditKidVC", sender: EditMenuViewController.self)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    let selectedMunchkin = self.kidList?[indexPath.row]
    let id = selectedMunchkin?.kidID
    let idString = String(stringInterpolationSegment: id!)
    let name = selectedMunchkin?.name
    self.indexPaths = [indexPath]
    
    let alertController = UIAlertController(title: "Alert", message: "Seriously! Delete your own child? Eviscerate poor \(name!)?", preferredStyle: .alert)
    
    let defaultActionHandler = { (action: UIAlertAction!) -> Void in
      self.kidList?.remove(at: indexPath.row)
      tableView.deleteRows(at: self.indexPaths!, with: .automatic)
      self.crummyApiService.deleteKid(idString, completionHandler: { (error) -> (Void) in
      })
    }
    let defaultAction = UIAlertAction(title: "Delete anyway you monster!", style: .default, handler: defaultActionHandler)
    alertController.addAction(defaultAction)
    
    let cancelActionHandler = { (action:UIAlertAction!) -> Void in
      self.tableView.reloadRows(at: self.indexPaths!, with: .automatic)
      
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: cancelActionHandler)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
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
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "My Kids"
  }
}
