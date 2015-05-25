//
//  GameMode.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 5/23/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

typealias GameOver = Bool

protocol GameMode: class {
  /// Reference to the UI node that is specfiic to this game mode
  var userInterface: CCNode! { get }
  /**
  Gets called when a falling object is dropped
  
  :param: mainScene Reference to the gameplay scene in which the event occured
  :param: droppedFallingObject Object that was dropped
  */
  func gameplay(mainScene:MainScene, droppedFallingObject:FallingObject)
  /**
  Gets called when a falling object is caught
  
  :param: mainScene Reference to the gameplay scene in which the event occured
  :param: droppedFallingObject Object that was caught
  */
  func gameplay(mainScene:MainScene, caughtFallingObject:FallingObject)
  /**
  Gets called on every update step
  
  :param: mainScene Reference to the gameplay scene in which the event occured
  :param: delta Time that has passed since last update step
  
  :returns: Returns whether game is over or not
  */
  func gameplayStep(mainScene:MainScene, delta: CCTime) -> GameOver
  
  /**
  Provides a highscore message for the current game
  
  :returns: Highscore message
  */
  func highscoreMessage() -> String
  
  /**
  Should be invoked when the receiving Game Mode should store the latest Highscore
  */
  func saveHighscore()
}