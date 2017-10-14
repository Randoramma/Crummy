//
//  CustomHeaderView.swift
//  Crummy
//
//  Created by Josh Nagel on 4/24/15.
//  Copyright (c) 2015 CF. All rights reserved.
//

import UIKit

class CustomHeaderView: UIView {

  var width: CGFloat!
  
   convenience init() {
    self.init()
  }
  
  init(width: CGFloat) {
    self.width = width
    super.init(frame: CGRect(x: 0, y: 0, width: self.width, height: 32))
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }

  override func draw(_ rect: CGRect) {
    //// General Declarations
    guard let context = UIGraphicsGetCurrentContext() else {return}
    
    //// Color Declarations
    let color = UIColor(red: 0.048, green: 0.264, blue: 0.541, alpha: 1.000)
    let shadowColor = UIColor(red: 0.539, green: 0.532, blue: 0.532, alpha: 1.000)
    let gradient2Color = UIColor(red: 0.060, green: 0.158, blue: 0.408, alpha: 1.000)
    let colorArray = [color.cgColor, gradient2Color.cgColor] as CFArray
    //// Gradient Declarations
    guard let gradient2 = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colorArray, locations: [0,1]) else {return}
    
    //// Shadow Declarations
    let shadow = NSShadow()
    shadow.shadowColor = shadowColor
    shadow.shadowOffset = CGSize(width: 0.1, height: -0.1)
    shadow.shadowBlurRadius = 5
    
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.width, height: 32))
    context.saveGState()
    rectanglePath.addClip()
    context.drawLinearGradient(gradient2, start: CGPoint(x: 300, y: -0), end: CGPoint(x: 300, y: 32), options: CGGradientDrawingOptions(rawValue: 0))
    context.restoreGState()
    
    ////// Rectangle Inner Shadow
    context.saveGState()
    context.clip(to: rectanglePath.bounds)
    context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0)
    context.setAlpha((shadow.shadowColor as! UIColor).cgColor.alpha)
    context.beginTransparencyLayer(auxiliaryInfo: nil)
    let rectangleOpaqueShadow = (shadow.shadowColor as! UIColor).withAlphaComponent(1)
    context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: rectangleOpaqueShadow.cgColor)
    context.setBlendMode(CGBlendMode.sourceOut)
    context.beginTransparencyLayer(auxiliaryInfo: nil)
    
    rectangleOpaqueShadow.setFill()
    rectanglePath.fill()
    
    context.endTransparencyLayer()
    context.endTransparencyLayer()
    context.restoreGState()
  }
}

extension UIColor {
  func blendedColorWithFraction(_ fraction: CGFloat, ofColor color: UIColor) -> UIColor {
    var r1: CGFloat = 1.0, g1: CGFloat = 1.0, b1: CGFloat = 1.0, a1: CGFloat = 1.0
    var r2: CGFloat = 1.0, g2: CGFloat = 1.0, b2: CGFloat = 1.0, a2: CGFloat = 1.0
    
    self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    
    return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
      green: g1 * (1 - fraction) + g2 * fraction,
      blue: b1 * (1 - fraction) + b2 * fraction,
      alpha: a1 * (1 - fraction) + a2 * fraction);
  }
}
