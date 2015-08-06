//
//  BrandTableView.swift
//  Barback
//
//  Created by Justin Duke on 8/5/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class BrandTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var ingredient: IngredientBase?  {
        didSet {
            dataSource = self
            delegate = self
            
            self.setNeedsDisplay()
            self.reloadData()
            
            separatorStyle = UITableViewCellSeparatorStyle.None
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = DescriptionLabel(frame: CGRect(x: 0, y: 0, width: 320, height: 60))
        label.text = "Recommended \(ingredient!.name) brands:"
        label.styleLabel()
        return label
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredient!.brands.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let cellIdentifier = "brandCell"
        let brand = ingredient!.brands[indexPath.row]
        cell = BrandCell(brand: brand,
            reuseIdentifier: cellIdentifier)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.window!.rootViewController! as! UITabBarController
        let navController = controller.viewControllers?.first as! UINavigationController
        (navController.visibleViewController! as! IngredientDetailViewController).showBrand(ingredient!.brands[indexPath.row])
        deselectRowAtIndexPath(indexPath, animated: true)
    }
}