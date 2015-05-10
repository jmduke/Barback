//
//  AmountMeasurement.swift
//  Barback
//
//  Created by Justin Duke on 5/6/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation

public enum Measurement {
    case Imperial
    case Metric
    
    func stringFromMetric(metricAmount: NSNumber) -> String {
        if metricAmount.intValue == 0 {
            return ""
        }
        
        switch self {
            case .Metric:
                return "\(metricAmount.floatValue) cl"
            case .Imperial:
                let rawOunceCount = metricAmount.floatValue / 3
                let ounceString = rawOunceCount < 1 ? "" : "\(Int(rawOunceCount)) "
                let remainder = metricAmount.floatValue % 3
                var remainderString: String = ""
                switch remainder {
                case 1:
                    remainderString = "⅓ "
                case 1.5:
                    remainderString = "½ "
                case 2:
                    remainderString = "⅔ "
                default:
                    remainderString = ""
                }
                return "\(ounceString)\(remainderString)oz"
        }
    }
}