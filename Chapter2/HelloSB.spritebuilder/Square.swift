//
//  Square.swift
//  HelloSB
//
//  Created by Benjamin Encz on 4/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Square : CCNode {
  
  weak var colorNode : CCNodeColor!
  
  override func onEnter() {
    super.onEnter()
    
    let red = Float(arc4random_uniform(256)) / 255.0
    let green = Float(arc4random_uniform(256)) / 255.0
    let blue = Float(arc4random_uniform(256)) / 255.0
    
    colorNode.color = CCColor(red: red, green: green, blue: blue)

    let rotate = CCActionRotateBy(duration: 2.0, angle: 360.0)
    let repeatRotation = CCActionRepeatForever(action: rotate)

    runAction(repeatRotation)
  }
  
}