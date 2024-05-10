//
//  TagProvider.swift
//  hypersdkflutter
//
//  Created by Harsh Garg on 10/05/24.
//

import Foundation

class TagProvider {
    private static var currentTag = 5000

    static func getNewTag() -> Int {
        currentTag += 1
        return currentTag
    }
}
