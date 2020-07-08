//
//  Array+Only.swift
//  Lines of Action
//
//  Created by David Crow on 5/28/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
