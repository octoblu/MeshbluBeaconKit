import Foundation
import enum Result.Result
import Alamofire
import SwiftyJSON

public class MeshbluHttpRequester {
  let host : String
  let port : Int
  var manager : Alamofire.Manager
  var username : String?
  var password : String?
  var bearer : String?

  public init(host : String, port : Int){
    self.host = host
    self.port = port
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    self.manager = Alamofire.Manager(configuration: configuration)
  }

  public convenience init(){
    self.init(host: "meshblu-http.octoblu.com", port: 443)
  }

  public convenience init(meshbluConfig: [String: AnyObject]){
    self.init(host: "example", port: 1)
  }

  public func setCredentials(username : String, password : String) {
    self.username = username
    self.password = password
  }

  public func setCredentials(bearer : String) {
    self.bearer = bearer
  }

  private func getRequest(method: String, path : String, parameters : [String: AnyObject]) -> Request{
    let urlComponent = NSURLComponents()
    urlComponent.port = self.port
    urlComponent.host = self.host
    urlComponent.scheme = urlComponent.port == 443 ? "https" : "http"
    urlComponent.path = path
    if method == "GET" && parameters.count > 0 {
      var queryItems: [NSURLQueryItem] = []
      for (key, value) in parameters {
        queryItems.append(NSURLQueryItem(name: key, value: value as? String))
      }
      urlComponent.queryItems = queryItems
    }
    let url = urlComponent.string!
    var request: Request
    var headers : [String: String] = [:]
    if username != nil && password != nil {
      let credentialData = "\(username!):\(password!)".dataUsingEncoding(NSUTF8StringEncoding)!
      let base64Credentials = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      headers.updateValue("Basic \(base64Credentials)", forKey: "Authorization")
    }
    if bearer != nil {
      headers.updateValue("Bearer \(bearer)", forKey: "Authorization")
    }

    switch method {
    case "DELETE":
      request = self.manager.request(.DELETE, url, parameters: parameters, encoding: .JSON, headers: headers)
    case "POST":
      request = self.manager.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers)
    case "GET":
      request = self.manager.request(.GET, url, encoding: .JSON, headers: headers)
    case "PUT":
      request = self.manager.request(.PUT, url, parameters: parameters, encoding: .JSON, headers: headers)
    case "PATCH":
      request = self.manager.request(.PATCH, url, parameters: parameters, encoding: .JSON, headers: headers)
    default:
      request = self.manager.request(.GET, url, parameters: parameters, encoding: .JSON, headers: headers)
    }

    return request
  }
 
  private func handleResult(response: Alamofire.Response<AnyObject, NSError>, handler: (Result<JSON, NSError>) -> ()){
    if response.result.isFailure {
      let error = NSError(domain: "com.octoblu.meshblu", code: 500, userInfo: [NSLocalizedFailureReasonErrorKey: "\(response.result.error!)"])
      handler(Result(error: error))
      return
    }
    let json = JSON(response.result.value!)
    handler(Result(value: json))
  }

  public func delete(path : String, parameters : [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.getRequest("DELETE", path: path, parameters: parameters).responseJSON { response in
      self.handleResult(response, handler: handler)
    }
  }

  public func get(path : String, parameters : [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.getRequest("GET", path: path, parameters: parameters).responseJSON { response in
      self.handleResult(response, handler: handler)
    }
  }

  public func patch(path : String, parameters : [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.getRequest("PATCH", path: path, parameters: parameters).responseJSON { response in
      self.handleResult(response, handler: handler)
    }
  }

  public func post(path : String, parameters : [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.getRequest("POST", path: path, parameters: parameters).responseJSON { response in
      self.handleResult(response, handler: handler)
    }
  }

  public func put(path : String, parameters : [String: AnyObject], handler: (Result<JSON, NSError>) -> ()){
    self.getRequest("PUT", path: path, parameters: parameters).responseJSON { response in
      self.handleResult(response, handler: handler)
    }
  }
}
