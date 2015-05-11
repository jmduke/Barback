//
//  BrandCell.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

class BrandCell: StyledCell {
    
    init(brand: Brand, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Value1,
            reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = brand.name
        detailTextLabel?.text = brand.detailDescription
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

}