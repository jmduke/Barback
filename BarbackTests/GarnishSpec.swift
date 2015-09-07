import Foundation
import Barback
import UIKit
import Nimble

import Quick

//// 2 cherry
//Orange slice, cherry
//3 orange slice
//cherry
//olive
//Lemon peel, olive
//0.5 orange slice
//Cherry, pineapple slice

class GarnishSpec: QuickSpec {
    
    override func spec() {

        describe("a garnish") {
            it("can be basic") {
                let rawGarnish = "cherry"
                let garnish = Garnish(rawGarnish: rawGarnish)
                expect(garnish.amount).to(equal(1))
                expect(garnish.type).to(beNil())
                expect(garnish.base).to(equal(GarnishBase.Cherry))
            }
            
            it("can be complex") {
                let rawGarnish = "Orange slice"
                let garnish = Garnish(rawGarnish: rawGarnish)
                expect(garnish.amount).to(equal(1))
                expect(garnish.type).to(equal(GarnishType.Slice))
                expect(garnish.base).to(equal(GarnishBase.Orange))
            }
            
            it("can be multiple and complex") {
                let rawGarnish = "3 Orange slice"
                let garnish = Garnish(rawGarnish: rawGarnish)
                expect(garnish.amount).to(equal(3))
                expect(garnish.type).to(equal(GarnishType.Slice))
                expect(garnish.base).to(equal(GarnishBase.Orange))
            }
            
            it("can be multiple") {
                let rawGarnish = "2 cherry"
                let garnish = Garnish(rawGarnish: rawGarnish)
                expect(garnish.amount).to(equal(2))
                expect(garnish.type).to(beNil())
                expect(garnish.base).to(equal(GarnishBase.Cherry))
            }
        }
    }
}