//
//  MainScene.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 11/01/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

class MainScene: CCNode {
  private var fallingObjects = [FallingObject]()
  
  private let fallingSpeed = 100.0
  private let spawnFrequency = 0.5
  
  
  override func onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinish()
    
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
      
      // check if falling object is below the screen boundary
      if (CGRectGetMaxY(fallingObject.boundingBox()) < CGRectGetMinY(boundingBox())) {
        // if object is below screen, remove it
        fallingObject.removeFromParent()
        fallingObjects.removeAtIndex(i)
        // play sound effect
        animationManager.runAnimationsForSequenceNamed("DropSound")
      } else {
        // else, let the object fall with a constant speed
        fallingObject.position = ccp(
          fallingObject.position.x,
          fallingObject.position.y - CGFloat(fallingSpeed * delta)
        )
      }
    }
  }
  
}