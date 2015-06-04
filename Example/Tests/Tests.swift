// https://github.com/Quick/Quick

import Quick
import Nimble
import MeshbluKit
import Result
import SwiftyJSON
import MeshbluBeaconKit

class MeshbluBeaconKitSpec: QuickSpec {
  override func spec() {
    class MockMeshbluHttp : MeshbluHttp {
      var messageResponse : Result<JSON, NSError>!
      
      init() {
        super.init(meshbluConfig: [:])
      }
      
      override private func message(payload: [String : AnyObject], handler: (Result<JSON, NSError>) -> ()) {
        handler(Result(value: JSON(payload)))
      }
    }
    
    describe(".sendLocationUpdate") {
      var mockMeshbluHttp: MockMeshbluHttp!
      var responseJSON: JSON!
      var responseError: NSError!
      var sut: MeshbluBeaconKit!
      
      beforeEach {
        mockMeshbluHttp = MockMeshbluHttp()
        sut = MeshbluBeaconKit(meshbluHttp: mockMeshbluHttp)
      }
      
      describe("when successful") {
        beforeEach {
          waitUntil { done in
            sut.sendLocationUpdate(["czar":"car"]) { (result) in
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
      }
    }
  }
}
