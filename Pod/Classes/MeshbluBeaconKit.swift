//
//  MeshbluBeaconKit.swift
//  Pods
//
//  Created by Octoblu on 6/1/15.
//
//

import Foundation
import CoreLocation

@objc public protocol MeshbluBeaconKitDelegate {
  optional  func proximityChanged (code: Int)
  optional  func beaconEnteredRegion()
  optional  func beaconExitedRegion()
}


@objc (MeshbluBeaconKit) public class MeshbluBeaconKit: NSObject, CLLocationManagerDelegate {
  
  var lastProximity = CLProximity.Unknown
  public var uuid = ""
  var delegate: MeshbluBeaconKitDelegate?
  let locationManager = CLLocationManager()
  
  public func start(uuid: String, delegate: MeshbluBeaconKitDelegate) {
    self.uuid = uuid
    self.delegate = delegate
  
    let beaconIdentifier = "iBeaconModules.us"
    let beaconUUID:NSUUID? = NSUUID(UUIDString: self.uuid)
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
    NSLog("Something happened %i", code)
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
}