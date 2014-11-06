target = UIATarget.localTarget();

numberOfRecipes = target.frontMostApp().mainWindow().tableViews()[0].cells().length;
for (var i = 0; i < numberOfRecipes; i++) {
    target.frontMostApp().mainWindow().tableViews()[0].cells()[i].tap();
    
    numberOfIngredients = target.frontMostApp().mainWindow().scrollViews()[0].tableViews()[0].cells().length;
    
    for (var j = 0; j < numberOfIngredients; j++) {
        target.frontMostApp().mainWindow().scrollViews()[0].tableViews()[0].cells()[j].tap();
        target.frontMostApp().navigationBar().leftButton().tap();
    }
    
    target.frontMostApp().navigationBar().leftButton().tap();
}


