//
//  BrandTableView.swift
//  Barback
//
//  Created by Justin Duke on 8/5/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class BrandTableView: RealmObjectTableView {
    
    var ingredient: IngredientBase?  {
        didSet {
            self.initialize()
        }
    }
    
    override func textForHeaderInSection() -> String {
        return "Recommended \(ingredient!.name) brands"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredient!.brands.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "brandCell"
        let brand = ingredient!.sortedBrands[indexPath.row]
        cell = BrandCell(brand: brand,
            reuseIdentifier: cellIdentifier)
        return cell!
    }
}