//
//  MeshbluKit.swift
//  Pods
//
//  Created by Octoblu on 6/1/15.
//
//

import Foundation
import enum Result.Result
import Alamofire
import SwiftyJSON

public class MeshbluHttp {
  var httpRequester : MeshbluHttpRequester
  var meshbluConfig : [String: AnyObject] = [:]

  public init(meshbluConfig: [String: AnyObject]) {
    self.meshbluConfig = meshbluConfig
    self.httpRequester = MeshbluHttpRequester()
  }

  public init(requester: MeshbluHttpRequester) {
    self.httpRequester = requester
  }

  public func isNotRegistered() -> Bool {
    return self.meshbluConfig["uuid"] == nil
  }

  public func setCredentials(uuid: String, token: String) {
    self.meshbluConfig.updateValue(uuid, forKey: "uuid")
    self.meshbluConfig.updateValue(token, forKey: "token")
    self.httpRequester.setCredentials(uuid, password: token)
  }

  public func claimDevice(uuid: String, handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.put("/claimdevice/\(uuid)", parameters: [:]) {
      (result) -> () in

      handler(result)
    }
  }

  public func deleteDevice(uuid: String, handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.delete("/devices/\(uuid)", parameters: [:]) {
      (result) -> () in

      handler(result)
    }
  }

  public func devices(options: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.get("/v2/devices", parameters: options) {
      (result) -> () in

      handler(result)
    }
  }

  public func generateToken(uuid: String, handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.post("/devices/\(uuid)/tokens", parameters: [:]) {
      (result) -> () in

      handler(result)
    }
  }

  public func getPublicKey(uuid: String, handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.get("/devices/\(uuid)/publickey", parameters: [:]) {
      (result) -> () in

      handler(result)
    }
  }

  public func register(device: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    print(device)
    self.httpRequester.post("/devices", parameters: device) {
      (result) -> () in

      handler(result)
    }
  }

  public func resetToken(uuid: String, handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.post("/devices/\(uuid)/token", parameters: [:]) {
      (result) -> () in

      handler(result)
    }
  }

  public func message(message: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.post("/messages", parameters: message) {
      (result) -> () in

      handler(result)
    }
  }

  public func update(uuid: String, properties: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.patch("/v2/devices/\(uuid)", parameters: properties) {
      (result) -> () in

      handler(result)
    }
  }

  public func update(properties: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    let uuid = self.meshbluConfig["uuid"] as! String
    update(uuid, properties: properties, handler: handler);
  }

  public func updateDangerously(uuid: String, properties: [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.put("/v2/devices/\(uuid)", parameters: properties) {
      (result) -> () in

      handler(result)
    }
  }

  public func whoami(handler: (Result<JSON, NSError>) -> ()){
    self.httpRequester.get("/v2/whoami", parameters: [:]) {
      (result) -> () in

      handler(result)
    }
  }

}
