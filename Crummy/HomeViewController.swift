//
//  HomeViewController.swift
//  Crummy
//
//  Created by Josh Nagel on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var people = [Person(theName: "Josh", theDOB: NSDate(), theInsuranceID: "130831", theConsultantPhone: "8010380024"), Person(theName: "Randy", theDOB: NSDate(), theInsuranceID: "244553", theConsultantPhone: "4200244244"), Person(theName: "Ed", theDOB: NSDate(), theInsuranceID: "43988305", theConsultantPhone: "94835553")]
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.dataSource = self
  }
  
  //MARK:
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return people.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCollectionViewCell
    cell.nameLabel.text = people[indexPath.row].name
    cell.personImageView.image = UIImage(named: "PersonPlaceholderImage")
    
    return cell
  }
}
