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
                expect(recipe.similarRecipes().count).to(beGreaterThan(0.0))
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
            
            it("has ingredients which have bases") {
                let ingredients = recipe.ingredients
                expect(ingredients.count).to(equal(3))
                ingredients.map({
                    expect($0.base).toNot(beNil())
                })
            }
            
            it("can be exported to html") {
                let html = recipe.htmlString
                expect(html).to(contain(recipe.name))
                
                var transformer = Markdown()
                let markdownInformation = transformer.transform(recipe.information)
                expect(html).to(contain(markdownInformation))
                expect(html).to(contain(recipe.directions))
                for ingredient in recipe.ingredients {
                    expect(html).to(contain(ingredient.base?.name ?? ""
                        ))
                }
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
            
            // This can technically fail sometimes, but meh.
            it("can be reduced to a random one") {
                var randomRecipes: [Recipe] = []
                for _ in 0...3 {
                    let recipe = Recipe.random()
                    expect(randomRecipes).toNot(contain(recipe))
                    randomRecipes.append(recipe)
                }
            }
        }
    }

}
