//
//  Category.swift
//  toodoo
//
//  Created by Lucy Wang on 6/27/18.
//  Copyright © 2018 Lucy Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
