#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Get full list.
target.frontMostApp().mainWindow().tableViews()["Sorry, we can't get you recipes until you connect to the internet!"].elements()[0].tapWithOptions({tapOffset:{x:0.40, y:0.54}});
target.delay(0.5);
captureLocalizedScreenshot("Check out tons of great recipes");

// Get recipe detail.
target.frontMostApp().mainWindow().tableViews()[0].cells()["Manhattan"].tapWithOptions({tapOffset:{x:0.62, y:0.39}});
target.frontMostApp().mainWindow().tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tap();
target.delay(0.5);
captureLocalizedScreenshot("Get ingredients, directions, and fun facts");

// Get search page.
target.frontMostApp().tabBar().buttons()["Search"].tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tableViews()[0].cells()["Gin"].tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tableViews()[0].searchBars()[0].tap();
target.delay(0.5);
captureLocalizedScreenshot("Search for exactly what you're in the mood for");
target.frontMostApp().mainWindow().tableViews()[0].cells()["Gin + Lemon juice"].tap();
target.delay(0.5);

// Get favorites.
target.frontMostApp().tabBar().buttons()["Favorites"].tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tap();
target.delay(0.5);
target.frontMostApp().mainWindow().tap();
target.delay(0.5);
captureLocalizedScreenshot("Keep track of your favorites");

// Get shopping list.
target.frontMostApp().mainWindow().tableViews()[0].cells()["Shopping List"].tap();
target.delay(0.5);
captureLocalizedScreenshot("Figure out what you need to buy");