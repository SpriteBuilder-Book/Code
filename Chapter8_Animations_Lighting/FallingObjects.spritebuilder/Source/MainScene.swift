//
//  MainScene.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 11/01/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

class MainScene: CCNode {

  weak var pot: Pot!
  weak var gameOverPopUpHighscoreLabel: CCLabelTTF!
  weak var effectNode: CCEffectNode!
  
  private var fallingObjects = [FallingObject]()
  private let fallingSpeed = 100.0
  private let spawnFrequency = 0.5
  private var isDraggingPot = false
  private var dragTouchOffset = ccp(0,0)
  private var gameEnded = false
  
  var selectedGameMode:GameModeSelection = .Endless {
    didSet {
      switch (selectedGameMode) {
      case .Endless:
        gameMode = EndlessGameMode()
      case .Timed:
        gameMode = TimedGameMode()
      }
      
      self.addChild(gameMode?.userInterface)
      gameMode?.userInterface.zOrder = DrawingOrder.ScoreBoard.rawValue
    }
  }
  
  enum DrawingOrder: Int {
    case GameplayElements
    case ScoreBoard
    case GameOverPopup
  }
  
  enum GameModeSelection: Int {
    case Endless
    case Timed
  }
  
  var gameMode:GameMode?
    
  override func onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish()
    
    userInteractionEnabled = true
    pot.zOrder = DrawingOrder.GameplayElements.rawValue
    
    // spawn objects with defined frequency
    schedule("spawnObject", interval: spawnFrequency)
  }
  
  func spawnObject() {
    let randomNumber = randomInteger(2)
    
    let fallingObjectType = FallingObject.FallingObjectType(rawValue:randomNumber)!
    let fallingObject = FallingObject(type:fallingObjectType)
    
    // add all spawning objects to an array
    fallingObjects.append(fallingObject)
    
    // spawn all objects at top of screen and at a random x position within scene bounds
    let xSpawnRange = Int(contentSizeInPoints.width - CGRectGetMaxX(fallingObject.boundingBox()))
    let spawnPosition = ccp(CGFloat(randomInteger(xSpawnRange)), contentSizeInPoints.height)
    fallingObject.position = spawnPosition
    fallingObject.zOrder = DrawingOrder.GameplayElements.rawValue
    
    effectNode.addChild(fallingObject)
  }

  func gameOver() {
    gameEnded = true
    userInteractionEnabled = false
    isDraggingPot = false
    gameMode?.saveHighscore()
    presentGameOverPopup()
  }
  
  //MARK: Update Loop
  
  override func update(delta: CCTime) {
    if (gameEnded) {
      return
    }
    
    // use classic for loop so that we can remove objects while iterating over the array
    for (var i = 0; i < fallingObjects.count; i++) {
      let fallingObject = fallingObjects[i]
      // let the object fall with a constant speed
      fallingObject.position = ccp(
        fallingObject.position.x,fallingObject.position.y - CGFloat(fallingSpeed * delta)
      )
    
      switch fallingObject.fallingState {
        case .Falling:
          performFallingStep(fallingObject)
        case .Missed:
          performMissedStep(fallingObject)
        case .Caught:
          performCaughtStep(fallingObject)
      }
    }
      
    let isGameOver = gameMode?.gameplayStep(self, delta: delta)
    if let isGameOver = isGameOver {
      if (isGameOver) {
        self.gameOver()
      }
    }
  }
  
  //MARK: Touch Handling
  
  override func touchBegan(touch: CCTouch, withEvent event: CCTouchEvent) {
    if (CGRectContainsPoint(pot.boundingBox(), touch.locationInNode(self))) {
      isDraggingPot = true
      dragTouchOffset = ccpSub(pot.anchorPointInPoints, touch.locationInNode(pot))
    }
  }
  
  override func touchMoved(touch: CCTouch, withEvent event: CCTouchEvent) {
    if (!isDraggingPot) {
      return
    }
    
    var newPosition = touch.locationInNode(self)
    // apply touch offset
    newPosition = ccpAdd(newPosition, dragTouchOffset);
    // ensure constant y position
    newPosition = ccp(newPosition.x, pot.positionInPoints.y);
    // apply new position to pot
    pot.positionInPoints = newPosition;
  }
  
  //MARK: Steps
  
  func performFallingStep(fallingObject:FallingObject) {
    let containerWorldBoundingBox = CGRectApplyAffineTransform(
      pot.catchContainer.boundingBox(), pot.nodeToParentTransform()
    );
    
    let yPositionInCatchContainer = CGRectGetMinY(fallingObject.boundingBox()) < CGRectGetMaxY(containerWorldBoundingBox)
    let xPositionLargerThanLeftEdge = CGRectGetMinX(fallingObject.boundingBox()) > CGRectGetMinX(containerWorldBoundingBox)
    let xPositionSmallerThanRightEdge = CGRectGetMaxX(fallingObject.boundingBox()) < CGRectGetMaxX(containerWorldBoundingBox)
    
    // check if falling object is inside catching pot, trigger this when object reaches top of pot
    if (yPositionInCatchContainer) {
      if (xPositionLargerThanLeftEdge && xPositionSmallerThanRightEdge) {
        // caught the object
        let fallingObjectWorldPosition = fallingObject.parent.convertToWorldSpace(fallingObject.positionInPoints)
        fallingObject.removeFromParent()
        fallingObject.positionInPoints = pot.convertToNodeSpace(fallingObjectWorldPosition)
        pot.addChild(fallingObject)
        fallingObject.fallingState = .Caught
        fallingObject.zOrder = Pot.DrawingOrder.FallingObject.rawValue
      } else {
        fallingObject.fallingState = .Missed
      }
    }
  }
  
  func performMissedStep(fallingObject:FallingObject) {
    // check if falling object is below the screen boundary
    if (CGRectGetMaxY(fallingObject.boundingBox()) < CGRectGetMinY(boundingBox())) {
      gameMode?.gameplay(self, droppedFallingObject:fallingObject)
      // if object is below screen, remove it
      fallingObject.removeFromParent()
      let fallingObjectIndex = find(fallingObjects, fallingObject)!
      fallingObjects.removeAtIndex(fallingObjectIndex)
      // play sound effect
      animationManager.runAnimationsForSequenceNamed("DropSound")
    }
  }
  
  func performCaughtStep(fallingObject:FallingObject) {
    // if the object was caught, remove it as soon as soon as it is entirely contained in the pot
    if (CGRectContainsRect(pot.catchContainer.boundingBox(), fallingObject.boundingBox())) {
      gameMode?.gameplay(self, caughtFallingObject: fallingObject)
      fallingObject.removeFromParent()
      let fallingObjectIndex = find(fallingObjects, fallingObject)!
      fallingObjects.removeAtIndex(fallingObjectIndex)
      
      if (fallingObject.type == .Good) {
        let particleEffect = CCBReader.load("CaughtParticleEffect") as! CCParticleSystem
        particleEffect.autoRemoveOnFinish = true
        particleEffect.positionType = CCPositionType(
          xUnit: .Normalized,
          yUnit: .Points,
          corner: .TopLeft
        )
        particleEffect.position = ccp(0.5, 20)
        pot.potTop.addChild(particleEffect)
        pot.animationManager.runAnimationsForSequenceNamed("CatchAnimation", tweenDuration: 0.1)
      } else if (fallingObject.type == .Bad) {
        pot.animationManager.runAnimationsForSequenceNamed("CatchNegativeAnimation", tweenDuration: 0.1)
      }
    }
  }
  
  //MARK: Game Over Popup
  
  func presentGameOverPopup() {
    let gameOverPopup = CCBReader.load("GameOverPopup", owner:self)
    
    // workaround because CCPositionTypeNormalized cannot be used at the moment
    // https://github.com/spritebuilder/SpriteBuilder/issues/1346
    gameOverPopup.positionType = CCPositionType(
      xUnit: .Normalized,
      yUnit: .Normalized,
      corner: .BottomLeft
    )
    
    gameOverPopup.position = ccp(0.5, 0.5)
    gameOverPopup.zOrder = DrawingOrder.GameOverPopup.rawValue
    
    gameOverPopUpHighscoreLabel.string = gameMode?.highscoreMessage()
    
    addChild(gameOverPopup)
  }
  
  func backToMenu() {
    let startScene = CCBReader.loadAsScene("StartScene")
    let transition = CCTransition(crossFadeWithDuration: 0.7)
    CCDirector.sharedDirector().replaceScene(startScene, withTransition: transition)
  }
  
  func playAgain() {
    let mainSceneContainer = CCBReader.loadAsScene("MainScene")
    let mainScene = mainSceneContainer.children[0] as! MainScene
    mainScene.selectedGameMode = selectedGameMode
    let transition = CCTransition(crossFadeWithDuration: 0.7)
    CCDirector.sharedDirector().replaceScene(mainSceneContainer, withTransition: transition)
  }
  
}