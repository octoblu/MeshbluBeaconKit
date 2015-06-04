//
//  MeshbluBeaconKit.swift
//  Pods
//
//  Created by Octoblu on 6/1/15.
//
//

import Foundation
import CoreLocation
import MeshbluKit
import SwiftyJSON
import Result
import Dollar

@objc public protocol MeshbluBeaconKitDelegate {
  optional  func proximityChanged (code: Int)
  optional  func beaconEnteredRegion()
  optional  func beaconExitedRegion()
  optional  func meshbluBeaconIsUnregistered()
  optional  func meshbluBeaconRegistrationSuccess(device: [String: AnyObject])
  optional  func meshbluBeaconRegistrationFailure(error: NSError)
}

@objc (MeshbluBeaconKit) public class MeshbluBeaconKit: NSObject, CLLocationManagerDelegate {
  
  var lastProximity = CLProximity.Unknown
  public var beaconUuid = ""
  public var meshbluConfig : [String: AnyObject]?
  var meshbluHttp : MeshbluHttp?
  var delegate: MeshbluBeaconKitDelegate?
  let locationManager = CLLocationManager()
  
  public init(meshbluConfig: [String: AnyObject]) {
    self.meshbluConfig = meshbluConfig
    self.meshbluHttp = MeshbluHttp(meshbluConfig: meshbluConfig)
    super.init()
  }
  
  public init(meshbluHttp: MeshbluHttp) {
    self.meshbluConfig = [:]
    self.meshbluHttp = meshbluHttp
    super.init()
  }
  
  public func start(beaconUuid: String, delegate: MeshbluBeaconKitDelegate) {
    self.beaconUuid = beaconUuid
    self.delegate = delegate
    
    let beaconIdentifier = "iBeaconModules.us"
    let beaconUUID:NSUUID? = NSUUID(UUIDString: self.beaconUuid)
    let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID:beaconUUID, identifier: beaconIdentifier)
    
    if(locationManager.respondsToSelector("requestAlwaysAuthorization")) {
      if CLLocationManager.authorizationStatus() == .NotDetermined {
        locationManager.requestAlwaysAuthorization()
      }
    }
    
    locationManager.delegate = self
    locationManager.pausesLocationUpdatesAutomatically = false
    
    locationManager.startMonitoringForRegion(beaconRegion)
    locationManager.startRangingBeaconsInRegion(beaconRegion)
    if CLLocationManager.locationServicesEnabled() {
      locationManager.startUpdatingLocation()
    }
    
    if (self.meshbluConfig!["uuid"] == nil) {
      self.delegate?.meshbluBeaconIsUnregistered!()
    }
  }
  
  public func register() {
    let device = ["type": "device:beacon-blu", "online" : "true"]
    
    self.meshbluHttp!.register(device) { (result) -> () in
      switch result {
      case let .Failure(error):
        self.delegate?.meshbluBeaconRegistrationFailure!(result.error!)
      case let .Success(success):
        let json = success.value
        var data = Dictionary<String, AnyObject>()
        data["uuid"] = json["uuid"].stringValue
        data["token"] = json["token"].stringValue
        self.delegate?.meshbluBeaconRegistrationSuccess!(data)
      }
    }
  }
  
  public func locationManager(manager: CLLocationManager!, didRangeBeacons beacons:[AnyObject]!, inRegion region: CLBeaconRegion!) {
    var code: Int = -1
    if(beacons.count > 0) {
      let nearestBeacon:CLBeacon = beacons[0] as! CLBeacon
      
      if(nearestBeacon.proximity == lastProximity) {
        return;
      }
      lastProximity = nearestBeacon.proximity;
      
      switch nearestBeacon.proximity {
      case CLProximity.Far:
        code = 3
      case CLProximity.Near:
        code = 2
      case CLProximity.Immediate:
        code = 1
      case CLProximity.Unknown:
        code = 0
      }
    } else {
      
      if(lastProximity == CLProximity.Unknown) {
        return;
      }
      
      code = 0
      lastProximity = CLProximity.Unknown
    }
    
    self.delegate?.proximityChanged!(code)
  }
  
  public func locationManager(manager: CLLocationManager!,
    didChangeAuthorizationStatus status: CLAuthorizationStatus)
  {
    if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
      manager.startUpdatingLocation()
    }
  }
  
  public func locationManager(manager: CLLocationManager!,
    didEnterRegion region: CLRegion!) {
      manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
      manager.startUpdatingLocation()
      
      self.delegate?.beaconEnteredRegion!()
  }
  
  public func locationManager(manager: CLLocationManager!,
    didExitRegion region: CLRegion!) {
      manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
      manager.stopUpdatingLocation()
      
      self.delegate?.beaconExitedRegion!()
  }
  
  public func sendLocationUpdate(payload: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    var message = Dictionary<String, AnyObject>()
    var code = 0
    var proximity = "Unknown"
    
    switch lastProximity {
    case CLProximity.Far:
      code = 3
      proximity = "Far"
    case CLProximity.Near:
      code = 2
      proximity = "Near"
    case CLProximity.Immediate:
      code = 1
      proximity = "Immediate"
    case CLProximity.Unknown:
      code = 0
      proximity = "Unknown"
    }
    
    let defaultPayload : [String: AnyObject] = [
      "proximity" : proximity,
      "code" : code
    ]
    
    var newPayload : [String: AnyObject] = $.merge(payload, defaultPayload)
    message["payload"] = newPayload
    message["devices"] = ["*"]
    message["topic"] = "location_update"
    
    self.meshbluHttp!.message(message) {
      (result) -> () in
      handler(result)
      NSLog("Message Sent: \(message)")
    }
  }
}