import Foundation
import Barback
import UIKit
import Nimble

import Quick

class SourceSpec: QuickSpec {

    override func spec() {

        var source: Source!

        describe("an online source") {
            
            beforeEach {
                source = Source(rawSource: "Boozenerds")
            }
            
            it("should have a type of site") {
                expect(source.type).to(equal(SourceType.Site))
            }
            
            it("should link to the correct site") {
                expect(source.prose()).to(contain("boozenerds.com"))
            }
            
            it("should mention being online") {
                expect(source.prose()).to(contain("online"))
            }
        }

        describe("a book source") {
            
            beforeEach {
                source = Source(rawSource: "The Fine Art of Mixing Drinks")
            }
            
            it("should have a type of book") {
                expect(source.type).to(equal(SourceType.Book))
            }
            
            it("should link to amazon") {
                expect(source.prose()).to(contain("amazon.com"))
            }
            
            it("should have a referral code") {
                expect(source.prose()).to(contain("barback-20"))
            }
            
            it("should mention being a book") {
                expect(source.prose()).to(contain("first appeared"))
            }
        }
    }

}
