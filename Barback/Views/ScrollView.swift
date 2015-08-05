//
//  ScrollView.swift
//  Barback
//
//  Created by Justin Duke on 11/19/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class ScrollView : UIScrollView {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Color.Background.toUIColor()
    }

}