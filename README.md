# foodtruck-ios-app
------

This is a iOS client for [SF-Food-Truck](https://github.com/chenpighead/SF-Food-Truck) project.

Go check `MapViewController.swift` for most of the front-end logic, API server calls, and data processing / presentation.

Note that the complete project, source code, dependencies are zipped in one zip file: **[Download](https://drive.google.com/file/d/1aE4PK3nAIneN9K7FPMN2viSpl0nFm_4i/view?usp=sharing)**

I separate `MapViewController.swift` file in this repo is just for review purpose.

## Setting up your environment

This project is developed by Swift under Xcode 10.1 (Xcode 9.3 compatible mode) with macOS 10.13.6.

To avoid any potential issue from Xcode simulator, the development process (debug / test) is directly on a device (iPhone 7 plus), so any iPhone with iOS >= 12.1 should work.

I use [CocoaPods](https://cocoapods.org/) to manage Swift dependencies:

* [Google Maps SDK for iOS](https://developers.google.com/maps/documentation/ios-sdk/intro) for Map View
* [Alamofire](https://github.com/Alamofire/Alamofire) for HTTP Networking
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) for JSON handling

## Downloading and building

1. [Download](https://drive.google.com/file/d/1aE4PK3nAIneN9K7FPMN2viSpl0nFm_4i/view?usp=sharing) the zip file and unzip it
2. Open `Uber Food Truck.xcworkspace`
3. In Xcode, go to ***Uber Food Truck -> General -> Signing*** to add a valid developer Team
4. Connect to an iPhone device (with USB)
5. In Xcode, click `Build and Run` button
6. On iPhone, go to ***Settings -> General -> Device Management*** to trust the developer

## Running

* Initial view will center at Uber HQ. All the food trucks are shown on the map without filtering

* Tap on the marker to show more information about the food truck

* Search for specific food truck (or food name) through the search bar on the top
```
ex. coffee
```

* Search for specific food truck (or food name) plus a trailing 'nearby' keyword
```
ex. coffee nearby
```
* Note that we haven't support getCurrentLocation() from the mobile client, so this feature would return results nearby Uber HQ for now

## Discussion

- **Why choosing mobile app instead of web for front-end presentation?**
  - Due to the user scenario, users would be more likely use this service on a mobile app.
  - According to my background, developing a web client might be the fastest way, but just really not a good fit for this specific application.
  - Did thought about using webview for all platforms, but the performance is known to be worse than the native mobile.
- **Why not using React Native?**
  - I'm new to React Native, so due to the time constraint, I'd better to pick a stack that is more likely to develop a workable solution in a very short time.
- **Why choosing iOS over Android?**
  - I'm a iPhone user, so that's the only device I have.
  - No bias or opinion for which of the two mobile stacks, actually I'm new to both stacks.

## Future work

#### Feature Development

- UI/UX improvement
- Route, route to the food truck
- Subscription / Notification, notify user with their favorite food trucks' up-to-date info
- Order in advance
  - Extra page for user to order foods in advance, then pay and retrive food in person later
  - Extra page for food truck owner to update the information (open/close, dish menu) and accept order

#### Engineering and Code Quality

- Testing: improve test coverage, introduce test framework, automatic testing, security issues
- Developing: introduce version control for the whole project

