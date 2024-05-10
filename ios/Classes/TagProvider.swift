//
//  TagProvider.swift
//  hypersdkflutter
//
//  Created by Harsh Garg on 10/05/24.
//

import Foundation

class TagProvider {

    static func getNewTag() -> Int {
        return Int(arc4random_uniform(UInt32.max))
    }
}
