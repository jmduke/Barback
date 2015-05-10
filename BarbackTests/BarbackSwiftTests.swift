//
//  BarbackSwiftTests.swift
//  BarbackSwiftTests
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Nimble
import UIKit
import XCTest
import Parse
import Barback

class BarbackSwiftTests: XCTestCase {
    
    var privateKeys: NSDictionary = {
        let keychain = NSBundle.mainBundle().pathForResource("PrivateKeys", ofType: "plist")
        return NSDictionary(contentsOfFile: keychain!)!
        }()
    
    override func setUp() {
        super.setUp()
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        let parseApplicationId = privateKeys["parseApplicationId"]! as! String
        let parseClientKey = privateKeys["parseClientKey"]! as! String
        Parse.setApplicationId(parseApplicationId, clientKey: parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground([:], block: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMeasurement() {
        let metricConversions = [
            (0, ""),
            (2.5, "2.5 cl"),
            (3, "3.0 cl")]
        
        for conversion in metricConversions {
            expect(Measurement.Metric.stringFromMetric(conversion.0)).to(equal(conversion.1))
        }
        
        let imperialConversions = [
            (0, ""),
            (1, "⅓ oz"),
            (1.5, "½ oz"),
            (2, "⅔ oz"),
            (3, "1 oz"),
            (4, "1 ⅓ oz"),
            (4.5, "1 ½ oz"),
            (5, "1 ⅔ oz"),
            (6, "2 oz")]
        
        for conversion in imperialConversions {
            expect(Measurement.Imperial.stringFromMetric(conversion.0)).to(equal(conversion.1))
        }
    }
    
    func testIsFirstTimeAppLaunched() {
        expect(isFirstTimeAppLaunched()).to(beTrue())
        setFirstTimeAppLaunched()
        expect(isFirstTimeAppLaunched()).to(beFalse())
        
        expect(isAppSyncedThisLaunch()).to(beFalse())
        setAppSyncedThisLaunch()
        expect(isAppSyncedThisLaunch()).to(beTrue())
    }
    
    func testGarnish() {
        let simpleGarnish = Garnish(rawGarnish: "Cherry")
        expect(simpleGarnish.base!).to(equal(GarnishBase.Cherry))
        
        let typedGarnish = Garnish(rawGarnish: "Lemon twist")
        expect(typedGarnish.type!).to(equal(GarnishType.Twist))
        expect(typedGarnish.base!).to(equal(GarnishBase.Lemon))
        expect(typedGarnish.amount).to(equal(1))
        
        let complexGarnish = Garnish(rawGarnish: "2 orange slice")
        expect(complexGarnish.amount).to(equal(2))
        expect(complexGarnish.base!).to(equal(GarnishBase.Orange))
        expect(complexGarnish.type!).to(equal(GarnishType.Slice))
        
        
    }
    
}
