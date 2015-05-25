//
//  StartScene.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 5/23/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

class StartScene: CCNode {
  
  weak var scrollView: CCScrollView!
  weak var playButton: CCButton!
  
  var selectedGameMode: MainScene.GameModeSelection = .Endless
  
  //MARK: Initialization
  
  func didLoadFromCCB() {
    scrollView.delegate = self
  }
  
  //MARK: Button Callbacks
  
  func playButtonPressed() {
    scrollView.userInteractionEnabled = false
    animationManager.runAnimationsForSequenceNamed("StartGameplay")
  }
  
  //MARK: Animation Callbacks
  
  func transitionAnimationComplete() {
    let scene = CCBReader.loadAsScene("MainScene")
    let gameplay = scene.children[0] as! MainScene
    
    gameplay.selectedGameMode = selectedGameMode
    let transition = CCTransition(crossFadeWithDuration: 0.7)
    CCDirector.sharedDirector().replaceScene(scene, withTransition: transition)
  }
  
}

extension StartScene: CCScrollViewDelegate {
    
  func scrollViewWillBeginDragging(scrollView: CCScrollView) {
    playButton.enabled = false
  }

  func scrollViewDidEndDecelerating(scrollView: CCScrollView) {
    playButton.enabled = true
    selectedGameMode = MainScene.GameModeSelection(rawValue: Int(scrollView.horizontalPage))!
  }
    
}