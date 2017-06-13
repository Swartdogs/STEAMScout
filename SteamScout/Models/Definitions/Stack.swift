//
//  Stack.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/19/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

struct Stack<Element> {
    fileprivate var items = [Element]()
    fileprivate var limit:Int
    
    init(limit:Int) {
        self.limit = limit
    }
    
    mutating func push(_ item:Element) {
        if items.count == limit {
            items.removeFirst()
        }
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    func peek() -> Element? {
        return items.last
    }
    
    func size() -> Int {
        return items.count
    }
    
    mutating func clearAll() {
        items.removeAll()
    }
}
