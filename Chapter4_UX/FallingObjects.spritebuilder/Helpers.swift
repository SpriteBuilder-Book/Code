//
//  Helpers.swift
//  FallingObjects
//
//  Created by Benjamin Encz on 1/18/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

/*
Generates a random number with upper bound of provided value.
Truncates upper bound to 32-Bit values.
*/
func randomInteger(var maximum: Int) -> Int {
  if maximum > Int(Int32.max) {
    maximum = Int(Int32.max)
  }
  
  return Int(arc4random_uniform(
    UInt32(maximum)
    ))
}

extension String {
  func pluralize(n: CCTime) -> String {
    return self.pluralize(Int(n))
  }
  
  func pluralize(n: Int) -> String {
    return n == 1 ? self : "\(self)s"
  }
}