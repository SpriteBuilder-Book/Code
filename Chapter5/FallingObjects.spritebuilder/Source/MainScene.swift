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
  
  private var fallingObjects = [FallingObject]()
  private let fallingSpeed = 100.0
  private let spawnFrequency = 0.5
  private var isDraggingPot = false
  private var dragTouchOffset = ccp(0,0)
  
  
  override func onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish()
    
    self.userInteractionEnabled = true
    
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
    
    addChild(fallingObject)
  }
  
  override func update(delta: CCTime) {
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
        let fallingObjectWorldPosition = fallingObject.parent!.convertToWorldSpace(fallingObject.positionInPoints)
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
      // if object is below screen, remove it
      
      fallingObject.removeFromParent()
      let fallingObjectIndex = fallingObjects.indexOf(fallingObject)!
      fallingObjects.removeAtIndex(fallingObjectIndex)
      // play sound effect
      animationManager.runAnimationsForSequenceNamed("DropSound")
    }
  }
  
  func performCaughtStep(fallingObject:FallingObject) {
    // if the object was caught, remove it as soon as soon as it is entirely contained in the pot
    if (CGRectContainsRect(pot.catchContainer.boundingBox(), fallingObject.boundingBox())) {
      fallingObject.removeFromParent()
      let fallingObjectIndex = fallingObjects.indexOf(fallingObject)!
      fallingObjects.removeAtIndex(fallingObjectIndex)
    }
  }
  
}