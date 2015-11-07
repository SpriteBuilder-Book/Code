//
//  EndlessGameMode.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 5/23/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

@objc(EndlessGameMode)
class EndlessGameMode: NSObject, GameMode {
  
  var healthBar: CCNode!
  var survivedLabel: CCLabelTTF!
  
  private(set) var userInterface: CCNode!
  private let minHealth = 0
  private let maxHealth = 10
  
  private var health:Int = 10 {
    didSet {
    let newScale = Float(health) / Float(maxHealth)
    let scaleAction = CCActionScaleTo.actionWithDuration(0.2, scaleX: newScale,
    scaleY: 1.0) as! CCAction
    
    healthBar.stopAllActions()
    healthBar.runAction(scaleAction)
    }
  }
  
  private var survivalTime: CCTime = 0.0 {
      didSet {
    survivedLabel.string = "Survived: \(Int(survivalTime))"
      }
  }
  
  override init() {
    super.init()
    
    userInterface = CCBReader.load("EndlessModeUI", owner:self)
  }
  
  //MARK: Protocol conformance
  
  func gameplay(mainScene:MainScene, droppedFallingObject:FallingObject) {
    if (droppedFallingObject.type == .Good) {
      health = max(health - 1, minHealth)
    }
  }
  
  func gameplay(mainScene:MainScene, caughtFallingObject:FallingObject) {
    switch (caughtFallingObject.type) {
    case .Bad:
      health = max(health - 1, minHealth)
    case .Good:
      health = min(health + 1, maxHealth)
    }
  }
  
  func gameplayStep(mainScene: MainScene, delta: CCTime) -> GameOver {
    survivalTime += delta
    
    return (health <= minHealth)
  }
  
  func highscoreMessage() -> String {
    let secondsText = Int(survivalTime) == 1 ? "second" : "seconds"
    
    return "You have survived \(Int(survivalTime)) \(secondsText)!"
  }

}