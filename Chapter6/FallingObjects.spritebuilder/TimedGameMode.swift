//
//  TimedGameMode.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 5/23/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

@objc(TimedGameMode)
class TimedGameMode: NSObject, GameMode {
  var timeLabel: CCLabelTTF!
  var pointsLabel: CCLabelTTF!
  
  let minPoints = 0
  let minTime = 0.0
  
  private(set) var userInterface: CCNode!
  
  private var time: CCTime = 10 {
    didSet {
    updateTimeDisplay(time)
    }
  }
  
  private var points: Int = 0 {
    didSet {
    updatePointsDisplay(points)
    }
  }
  
  override init() {
    super.init()
    
    userInterface = CCBReader.load("TimedModeUI", owner:self)
    updatePointsDisplay(points)
    updateTimeDisplay(time)
  }
  
  func updatePointsDisplay(points: Int) {
    pointsLabel.string = "Points: \(points)"
  }
  
  func updateTimeDisplay(time: CCTime) {
    timeLabel.string = "Time: \(Int(time))"
  }
  
  //MARK: Protocol conformance
  
  func gameplay(mainScene:MainScene, droppedFallingObject:FallingObject) {
    if (droppedFallingObject.type == .Good) {
      points = max(points - 1, minPoints)
    }
  }
  
  func gameplay(mainScene:MainScene, caughtFallingObject:FallingObject) {
    switch (caughtFallingObject.type) {
    case .Bad:
      points = max(points - 1, minPoints)
    case .Good:
      points += 1 }
  }
  
  func gameplayStep(mainScene: MainScene, delta: CCTime) -> GameOver {
    time -= delta
    
    return !(time > minTime)
  }
  
  func highscoreMessage() -> String {
    let pointsText = points == 1 ? "point" : "points"
    return "You have scored \(Int(points)) \(pointsText)!"
  }
  
}