//
//  HomeViewController.swift
//  Crummy
//
//  Created by Josh Nagel on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var buttonContainerView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  let kidNumberHeight: CGFloat = 100
  let doneButtonHeight: CGFloat = 30.0
  let astheticSpacing : CGFloat = 8.0
  let phoneInterval : TimeInterval = 0.4
  let crummyApiService = CrummyApiService()
  var phoneMenuContainer : UIView!
  let titleColor = UIColor(red: 0.060, green: 0.158, blue: 0.408, alpha: 1.000)
  let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
  let titleSize: CGFloat = 26
  var kidCount: CGFloat = 0.0
  var kids = [Kid]()
  let blurViewTag = 99
  let animationDuration: Double = 0.3
  
  let phonePopoverAC = UIAlertController(title: "PhoneList", message: "Select a number to dial.", preferredStyle: UIAlertControllerStyle.actionSheet)
  // find the Nib in the bundle.
  let phoneNib = UINib(nibName: "PhoneCellContainerView", bundle: Bundle.main)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.navigationItem.hidesBackButton = true
    self.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: self.titleSize)
    self.titleLabel.textAlignment = .center
    self.titleLabel.textColor = self.titleColor
    titleLabel.text = "Home"
    self.navigationItem.titleView = self.titleLabel
    let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backButton
    
    let navBarImage = UIImage(named: "CrummyNavBar")
    self.navigationController!.navigationBar.setBackgroundImage(navBarImage, for: .default)
    
    let buttonBar = UIColor(patternImage: UIImage(named: "ContainerViewBar")!)
    self.buttonContainerView.backgroundColor = buttonBar
    
    self.activityIndicator.startAnimating()
    self.crummyApiService.listKid { (kidList, error) -> (Void) in
      if let errorDescription = error {
        let alertController = UIAlertController(title: "An Error Occurred", message: errorDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) -> Void in
          self.dismiss(animated: trvar completion: nil)
        var        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      } else {
        self.kids = kidList!
        self.collectionView.reloadData()
        self.activityIndicator.stopAnimating()
      }
    }
  }
  
  func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.appWillResign), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.appBecameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }
  
  func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }

  
  func appWillResign() {
    if self.phoneMenuContainer != nil {
      let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
      let blurView = UIVisualEffectView(effect: blurEffect)
      blurView.tag = self.blurViewTag
      blurView.frame = self.view.frame
      self.phoneMenuContainer.addSubview(blurView)
    }
  }
  
  func appBecameActive() {
    if self.phoneMenuContainer != nil {
      let blurView = self.phoneMenuContainer.viewWithTag(self.blurViewTag)
      UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
        blurView?.removeFromSuperview()
      })
    }
  }
  
  @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: "crummyToken")
    defaults.synchronize()
    let storyBoard = self.navigationController?.storyboard
    let login = storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
    self.present(login, animated: true, completion: nil)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return kids.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCollectionViewCell
    cell.nameLabel.text = kids[indexPath.row].name
    cell.kidImageView.layer.cornerRadius = cell.kidImageView.frame.height / 2
    cell.kidImageView.layer.masksToBounds = true
    cell.kidImageView.layer.borderWidth = 8
    cell.kidImageView.layer.borderColor = UIColor(patternImage: UIImage(named: "ImageViewBorder")!).cgColor
    let kid = self.kids[indexPath.row]
    let image = self.loadImage(kid)
    if image != nil {
      cell.kidImageView.image = self.loadImage(kid)
    } else {
      cell.kidImageView.image = UIImage(named: "PersonPlaceholderImage")
    }
    
    return cell
  }
  
  //MARK:
  //MARK: Load Image
  
  func loadImage(_ kid: Kid) -> UIImage? {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectoryPath = paths[0] 
    let filePath = documentsDirectoryPath.stringByAppendingPathComponent("appData")
    if FileManager.default.fileExists(atPath: filePath) {
      let savedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [String: AnyObject]
      let customImageLocation = "kid_photo_\(kid.kidID)"
      if let imageData = savedData[customImageLocation] as? Data {
        return UIImage(data: imageData)
      }
    }
    return nil
  }
  
    //MARK:
  //MARK: prepareForSegue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowEditMenu" {
      let destinationController = segue.destination as? EditMenuViewController
      destinationController?.kidList = self.kids
    } else if segue.identifier == "ShowEvents" {
      let destinationController = segue.destination as? EventsViewController
      let indexPath = self.collectionView.indexPathsForSelectedItems?.first as! IndexPath
      let kid = self.kids[indexPath.row]
      destinationController?.kidId = "\(kid.kidID)"
      destinationController?.kidName = kid.name
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.crummyApiService.listKid { (kidList, error) -> (Void) in
      if let errorDescription = error {
        let alertController = UIAlertController(title: "An Error Occurred", message: errorDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) -> Void in
          self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      } else {
        self.kids = kidList!
        self.collectionView.reloadData()
      }
    }
  }
    
  //MARK:
  //MARK: - popover VC.
  
  @IBAction func phoneButtonPressed(_ sender: AnyObject) {
    // adding table view properties for the phone table view popover.
    if kids.count == 0 {
      kidCount = 0
    } else {
      kidCount = CGFloat(kids.count)
    }
    
    

    let phoneMenuViewAndDoneHeight: CGFloat = ((kidCount * kidNumberHeight) + doneButtonHeight + astheticSpacing)
    // add the phone menu container
    phoneMenuContainer = UIView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: phoneMenuViewAndDoneHeight))
    phoneMenuContainer.backgroundColor = UIColor.lightGray
    self.view.addSubview(phoneMenuContainer)
    
    // adding the phone menu view
    let phoneMenuViewHeight: CGFloat =  CGFloat(kidCount * kidNumberHeight)
    let phoneMenuView = UITableView(frame: CGRect(x: 0, y: doneButtonHeight + astheticSpacing, width: phoneMenuContainer.frame.width, height: phoneMenuViewHeight))
    phoneMenuView.register(phoneNib, forCellReuseIdentifier: "phoneCell")
    phoneMenuContainer.addSubview(phoneMenuView)
    phoneMenuView.delegate = self
    phoneMenuView.dataSource = self
    
    let phoneCloser = UIButton(frame: CGRect(x: 0, y: astheticSpacing, width: phoneMenuContainer.frame.width, height: doneButtonHeight))
    phoneCloser.setTitle("Done", for: UIControlState())
    phoneCloser.setTitleColor(UIColor.white, for: UIControlState())
    phoneCloser.center.x = self.view.center.x
    phoneCloser.addTarget(self, action: #selector(HomeViewController.phoneCloserPressed(_:)), for: UIControlEvents.touchUpInside)
    phoneMenuContainer.addSubview(phoneCloser)
    _ = Bundle.main.loadNibNamed("PhoneCellContainerView", owner: self, options: nil)
    UIView.animate(withDuration: phoneInterval, animations: { () -> Void in
      self.phoneMenuContainer.frame.origin.y = self.view.frame.height - phoneMenuViewAndDoneHeight
    })
  } // phoneButtonPressed
  
  func phoneCloserPressed(_ sender: AnyObject) {
    let kidCount = CGFloat(kids.count)
    let phoneMenuViewAndDoneHeight: CGFloat = ((self.view.frame.height) - (kidCount * kidNumberHeight) - doneButtonHeight)
    UIView.animate(withDuration: phoneInterval, animations: { () -> Void in
      self.phoneMenuContainer.frame.origin.y = self.view.frame.height + phoneMenuViewAndDoneHeight
    })
  } // phoneCloserPressed
  
  //MARK:
  //MARK: - TableView VC
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath) as! PhoneTableViewCell
    cell.Name.text = kids[indexPath.row].name
    cell.InsuranceID.text = kids[indexPath.row].insuranceId
    
    ///// NEds to be kidslist.
    if let thephone = kids[indexPath.row].nursePhone {
      cell.Phone.text = thephone
    } else {
      cell.Phone.text = "no phone number"
    }
    
    
    return cell
  } // cellForRowAtIndexPath
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return kids.count
  } // numberOfRowsInSection
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let nursePhone = self.kids[indexPath.row].nursePhone {
      UIApplication.shared.openURL(URL(string: "telprompt://\(nursePhone)")!)
    }
  } // didSelectRowAtIndexPath
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
}
