//
//  Gameplay.swift
//  HelloSB
//
//  Created by Benjamin Encz on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Gameplay : CCNode {

  override func onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish()
    
    self.userInteractionEnabled = true
  }

  override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
    let touchPosition = touch.locationInNode(self)
    let square = CCBReader.load("Square")
    addChild(square)
    square.position = touchPosition
  }

}