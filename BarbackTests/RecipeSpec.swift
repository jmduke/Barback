//
//  RecipeSpec.swift
//  Barback
//
//  Created by Justin Duke on 5/10/15.
//  Copyright (c) 2015 Justin Duke. All rights reserved.
//

import Foundation
import Barback
import UIKit
import Nimble
import Quick
import RealmSwift

class RecipeSpec: QuickSpec {

    override func spec() {

        describe("a recipe") {
            
            var recipe: Recipe!
            beforeEach {
                recipe = Recipe.all().filter({ $0.name == "Manhattan" }).first
            }
            
            it("should have an abv") {
                expect(recipe.abv).to(beCloseTo(30.0, within: 10.0))
            }
            
            it("should have a similar recipe or two") {
                expect(recipe.similarRecipes(2).count).to(beGreaterThan(0.0))
            }
            
            it("can be favorited") {
                do {
                    let realm = try Realm()
                    realm.write {
                        recipe.isFavorited = true
                        expect(Recipe.favorites()).to(contain(recipe))
                    }
                } catch { }
            }
            
        }
        
        describe("all recipes") {
            let recipes = Recipe.all()
            
            it("should have non-zero ABVs") {
                for recipe in recipes {
                    expect(recipe.abv).to(beGreaterThan(0.0))
                }
            }
            
            it("should have at least two ingredients") {
                for recipe in recipes {
                    expect(recipe.ingredients.count).to(beGreaterThan(1.0))
                }
            }
        }
    }

}
