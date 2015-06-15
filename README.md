# MeshbluBeaconKit

[![CI Status](http://img.shields.io/travis/Sqrt of Octoblu/MeshbluBeaconKit.svg?style=flat)](https://travis-ci.org/Sqrt of Octoblu/MeshbluBeaconKit)
[![Version](https://img.shields.io/cocoapods/v/MeshbluBeaconKit.svg?style=flat)](http://cocoapods.org/pods/MeshbluBeaconKit)
[![License](https://img.shields.io/cocoapods/l/MeshbluBeaconKit.svg?style=flat)](http://cocoapods.org/pods/MeshbluBeaconKit)
[![Platform](https://img.shields.io/cocoapods/p/MeshbluBeaconKit.svg?style=flat)](http://cocoapods.org/pods/MeshbluBeaconKit)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MeshbluBeaconKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MeshbluBeaconKit"
```

## Usage

Check [BeaconBlu-iOS](https://github.com/octoblu/BeaconBlu-iOS) for example usage.


1. Import the library

```swift
import MeshbluBeaconKit
```

1. Extend MeshbluBeaconKitDelegate in the AppDelegate

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, MeshbluBeaconKitDelegate
```

1. Instantiate MeshbluBeaconKit in AppDelegate

```swift
var meshbluConfig = Dictionary<String, AnyObject>()
let settings = NSUserDefaults.standardUserDefaults()

meshbluConfig["uuid"] = settings.stringForKey("uuid")
meshbluConfig["token"] = settings.stringForKey("token")

self.meshbluBeaconKit = MeshbluBeaconKit(meshbluConfig: meshbluConfig)
meshbluBeaconKit.start("CF593B78-DA79-4077-ABA3-940085DF45CA", delegate: self)
```

1. Add Extension after AppDelegate

```swift
extension AppDelegate: MeshbluBeaconKitDelegate {

  func getMainControler() -> ViewController {
    let viewController:ViewController = window!.rootViewController as! ViewController
    return viewController
  }

  func updateMainViewWithMessage(message: String){
    let viewController = getMainControler()
    println("Message is \(message)")
  }

  func proximityChanged(response: [String: AnyObject]) {
    var message = ""
    let proximity = response["proximity"] as! [String: AnyObject]
    switch(proximity["code"] as! Int) {
    case 3:
      message = "Far away from beacon"
    case 2:
      message = "You are near the beacon"
    case 1:
      message = "Immediate proximity to beacon"
    case 0:
      message = "No beacons are nearby"
    default:
      message = "No beacons are nearby"
    }

    let viewController = getMainControler()
    self.updateMainViewWithMessage(message)
    self.meshbluBeaconKit.sendLocationUpdate(response) {
      (result) -> () in
    }
  }

  func meshbluBeaconIsUnregistered() {
    self.meshbluBeaconKit.register()
  }

  func meshbluBeaconRegistrationSuccess(device: [String: AnyObject]) {
    let settings = NSUserDefaults.standardUserDefaults()
    let uuid = device["uuid"] as! String
    let token = device["token"] as! String

    settings.setObject(uuid, forKey: "uuid")
    settings.setObject(token, forKey: "token")
  }

  func beaconEnteredRegion() {
    self.updateMainViewWithMessage("Beacon Entered Region")
  }

  func beaconExitedRegion() {
    self.updateMainViewWithMessage("Beacon Exitied Region")
  }

}
```

## Author

Octoblu, support@octoblu.com

## License

MeshbluBeaconKit is available under the MIT license. See the LICENSE file for more info.
