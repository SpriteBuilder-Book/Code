//
//  Pot.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 5/23/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

class Pot: CCNode {
  
  weak var catchContainer: CCNode!
  weak var potTop: CCNode!
  weak var potBottom: CCNode!
  
  enum DrawingOrder: Int {
    case PotTop
    case FallingObject
    case PotBottom
  }
  
  func didLoadFromCCB() {
    potBottom.zOrder = DrawingOrder.PotBottom.rawValue
    potTop.zOrder = DrawingOrder.PotTop.rawValue
  }
  
}