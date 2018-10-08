//
//  LoginViewController.swift
//  Crummy
//
//  Created by Josh Nagel on 4/20/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, CreateUserViewControllerDelegate {

  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var constraintContainerCenterY: NSLayoutConstraint!
  @IBOutlet weak var constraintStatusViewCenterX: NSLayoutConstraint!
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var statusView: UIView!
  let crummyApiService = CrummyApiService()
  var bufferForSlidingLoginView: CGFloat = 70
  var animationDuration: Double = 0.2
  let animationDurationLonger: Double = 0.5
  
  var tapGestureRecognizer: UITapGestureRecognizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.usernameTextField.delegate = self
    self.passwordTextField.delegate = self
    
    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
    self.view.addGestureRecognizer(self.tapGestureRecognizer!)
  }
  
  @IBAction func loginPressed(_ sender: UIButton) {
    let username = usernameTextField.text
    let password = passwordTextField.text
    
    self.crummyApiService.postLogin(username!, password: password!, completionHandler: { (status, error) -> (Void) in
      
      if status != nil {
          self.statusView.backgroundColor = UIColor.green
          self.statusLabel.text = "Success"
          self.constraintStatusViewCenterX.constant = 0
          UIView.animate(withDuration: self.animationDurationLonger, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finshed) -> Void in
              self.performSegue(withIdentifier: "ShowHomeMenu", sender: self)
          })
      } else {
        self.statusView.backgroundColor = UIColor.red
        self.statusLabel.text = "Error creating user"
        self.constraintStatusViewCenterX.constant = 0
        UIView.animate(withDuration: self.animationDurationLonger, animations: { () -> Void in
          self.view.layoutIfNeeded()
        })
      }
    })
  }
  
    @objc func dismissKeyboard() {
    self.usernameTextField.resignFirstResponder()
    self.passwordTextField.resignFirstResponder()
  }
  
  //MARK:
  //MARK: UITextFieldDelegate
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.constraintContainerCenterY.constant += bufferForSlidingLoginView
    UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
        self.constraintContainerCenterY.constant -= self.bufferForSlidingLoginView
    UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.usernameTextField.resignFirstResponder()
    if textField == usernameTextField {
      self.passwordTextField.becomeFirstResponder()
    } else {
      self.passwordTextField.resignFirstResponder()
    }
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == usernameTextField {
      if string.validForUsername() {
        return true
      } else {
        return false
      }
    }
    return true
  }
  
  func getUsernameFromRegister(_ username: String) {
    self.usernameTextField.text = username
  }
  
  //MARK:
  //MARK: prepareForSegue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "Register" {
      self.constraintStatusViewCenterX.constant = 600
      UIView.animate(withDuration: self.animationDurationLonger, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
      let destinationController = segue.destination as! UINavigationController
    let createUser = destinationController.viewControllers[0] as! CreateUserViewController
      createUser.delegate = self
    }
  }
}
