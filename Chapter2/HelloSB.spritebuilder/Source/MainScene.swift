//
//  MainScene.swift
//  HelloSB
//
//  Created by Benjamin Encz on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class MainScene: CCNode {
  
  func startGame() {
    let gameplayScene = CCBReader.loadAsScene("Gameplay")
    let transition = CCTransition(fadeWithDuration: 1.0)
  
    CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
  }
  
}