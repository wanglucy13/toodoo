//
//  ItemModel.swift
//  toodoo
//
//  Created by Lucy Wang on 6/27/18.
//  Copyright © 2018 Lucy Wang. All rights reserved.
//

import Foundation

class ItemModel : Codable { // item type is able to encode itself into plist or json
    // item must only have standard data types
    var title : String = ""
    var done : Bool = false
}
