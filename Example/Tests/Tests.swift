// https://github.com/Quick/Quick

import Quick
import Nimble
import MeshbluHttp
import Result
import SwiftyJSON
import MeshbluBeaconKit
import OHHTTPStubs

class MockDelegate : MeshbluBeaconKitDelegate {
  
}

class MeshbluBeaconKitSpec: QuickSpec {
  override func spec() {
    var responseJSON: JSON!
    var responseError: NSError!
    var sut: MeshbluBeaconKit!
    var delegate: MockDelegate!
    
    beforeEach {
      delegate = MockDelegate()
      sut = MeshbluBeaconKit(meshbluConfig: [:], delegate: delegate)
    }

    describe(".sendLocationUpdate") {
      describe("when successful") {
        beforeEach {
          stub(isHost("meshblu-http.octoblu.com")) { _ in
            let obj = ["topic":"location_update", "devices": ["*"], "payload": ["czar":"car"]]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
          }
          waitUntil { done in
            sut.sendLocationUpdate(["czar":"car"]) { (result) in
              print(result.value)
              responseJSON = result.value
              responseError = result.error
              done()
            }
          }
        }
        
        it("should have a topic of location_payload") {
          expect(responseJSON["topic"].string) == "location_update"
        }
        
        it("should be a broadcast message") {
          expect(responseJSON["devices"].array) == ["*"]
        }
        
        it("should be a merge a custom payload into the message payload") {
          expect(responseJSON["payload"]["czar"].string) == "car"
        }
        
        it("should not have an error") {
          expect(responseError).to(beNil())
        }
      }
    }
  }
}