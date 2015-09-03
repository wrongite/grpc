/*
 *
 * Copyright 2015, Google Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let RemoteHost = "grpc-test.sandbox.google.com"

    let request = RMTSimpleRequest()
    request.responseSize = 10
    request.fillUsername = true
    request.fillOauthScope = true

    // Example gRPC call using a generated proto client library:

    let service = RMTTestService(host: RemoteHost)
    service.unaryCallWithRequest(request) { (response: RMTSimpleResponse?, error: NSError?) in
      if let response = response {
        NSLog("Finished successfully with response:\n\(response)")
      } else {
        NSLog("Finished with error: \(error!)")
      }
    }

    // Same example call using the generic gRPC client library:

    let method = ProtoMethod(package: "grpc.testing", service: "TestService", method: "UnaryCall")

    let requestsWriter = GRXWriter(value: request.data())

    let call = GRPCCall(host: RemoteHost, path: method.HTTPPath, requestsWriter: requestsWriter)

    let responsesWriteable = GRXWriteable { (value: AnyObject?, error: NSError?) in
      if let value = value as? NSData {
        NSLog("Received response:\n\(RMTSimpleResponse(data: value, error: nil))")
      } else {
        NSLog("Finished with error: \(error!)")
      }
    }

    call.startWithWriteable(responsesWriteable)
  }
}