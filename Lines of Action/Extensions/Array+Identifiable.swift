//
//  Array+Identifiable.swift
//  Lines of Action
//
//  Created by David Crow on 5/28/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<count {
            if self[index].id == matching.id {
                return index
            }
        }
        
        return nil
    }
}
