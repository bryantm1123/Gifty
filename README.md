# Gifty
Gifty is a simple gif browser connected to the [Giphy /trending API](https://developers.giphy.com/docs/api/endpoint#trending). Browse gifs and tap your favorites to see them in full screen.

<img src="https://github.com/bryantm1123/Gifty/blob/screenshots/Screenshots/GiftyBrowser.PNG" width="207" height="448"><img src="https://github.com/bryantm1123/Gifty/blob/screenshots/Screenshots/GiftyDetail.PNG" width="207" height="448">

## Architecture
My chosen architecture for this project is Model-View-Presenter.
* ["iOS Swift MVP Architecture"](https://saad-eloulladi.medium.com/ios-swift-mvp-architecture-pattern-a2b0c2d310a3)
* ["Implement MVP in Swift 5"](https://betterprogramming.pub/implement-a-model-view-presenter-architecture-in-swift-5-dfa21bbb8e0b)

In this architecture, we'll have a model layer that is updated by a service, a presentation layer that uses the service to reach the model and transforms it into a presentable format for the view layer, and the view layer which is responsible for displaying our transformed model. Similar to MVVM, the view controller is considered part of the view layer and should contain no model logic or service interaction. Instead, that responsibility is shifted to the Presenter.

The implementation in this project makes use of a delegate to communicate the result of the Presenter to the view layer. If communication were required from the view layer to the Presenter, such as in the case a user entered text on a text field for example, a delegate could also be used to transmit the updated text back through the Presenter and on to the model.

This delegate pattern of object communication serves a similar function to data binding and observables in MVVM. 

As this is a fairly simple project, with limited user input, and simple navigation, I opted for MVP to acheive desired code separation, and for the simplicity of implementating the delegate communication pattern. 

## Dependencies
* [Cocoapods](https://cocoapods.org)
* [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) (Tracked by the repo)
* An API key, which can be obtained by [registering an app with Giphy.](https://developers.giphy.com/dashboard/?create=true)

## Requirements
To successfully connect to the API, place your API key in the included [APIConfig.xcconfig](https://github.com/bryantm1123/Gifty/blob/master/Gifty/APIConfig.xcconfig) file, in the API_KEY field:

`API_KEY = {YOUR_API_KEY_GOES_HERE}`

