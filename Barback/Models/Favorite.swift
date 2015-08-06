//
//  Favorite.swift
//  Barback
//
//  Created by Justin Duke on 4/16/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import RealmSwift

public class Favorite: Object {

    var recipe: Recipe?

    public class func all() -> [Favorite] {
        do {
            return try Realm().objects(Favorite).map({ $0 })
        } catch {
            print("\(error)")
            return []
        }    }
}