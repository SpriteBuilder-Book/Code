//
//  FallingObject.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 11/01/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

class FallingObject: CCSprite {

  enum FallingObjectType: Int {
    case Good
    case Bad
  }
  
  enum FallingObjectState {
    case Falling
    case Caught
    case Missed
  }
  
  private class var imageNames:ImageNames {
    struct ClassConstantWrapper {
      static let instance = ImageNames()
    }
    return ClassConstantWrapper.instance
  }
  
  private struct ImageNames {
    var good: [String]
    var bad: [String]
    
    init () {
      let path = NSBundle.mainBundle().pathForResource("FallingObjectImages", ofType: "plist")!
      let imageDictionary:Dictionary = NSDictionary(contentsOfFile: path)! as! [String : AnyObject]
      good = imageDictionary["FallingObjectTypeGoodImages"] as! [String]
      bad = imageDictionary["FallingObjectTypeBadImages"] as! [String]
    }
  }
  
  private(set) var type:FallingObjectType
  var fallingState = FallingObjectState.Falling
  
  init(type: FallingObjectType) {
    self.type = type

    var imageName:String? = nil
    
    if (type == .Good) {
      let randomIndex = randomInteger(FallingObject.imageNames.good.count)
      imageName = FallingObject.imageNames.good[randomIndex]
    } else if (type == .Bad) {
      let randomIndex = randomInteger(FallingObject.imageNames.bad.count)
      imageName = FallingObject.imageNames.bad[randomIndex]
    }
        
    let spriteFrame = CCSpriteFrame(imageNamed:imageName)
    super.init(texture: spriteFrame.texture, rect: spriteFrame.rect, rotated: false)
    
    anchorPoint = ccp(0,0)
    
    effect = CCEffectLighting()
    
    let imageNameSplit = imageName!.characters.split { $0 == "." }
    let imageNameFirstPart = imageNameSplit[0]
    let normalMapName = "\(imageNameFirstPart)_NRM.png"
    
    normalMapSpriteFrame = CCSpriteFrame(imageNamed: normalMapName)
  }
  
}
