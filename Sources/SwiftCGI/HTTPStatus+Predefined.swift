// Copyright 2015 Tony Allevato
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/// Pre-defined named status codes from the HTTP specification.
public extension HTTPStatus {

  // Informational 1xx codes.
  public static let Continue = HTTPStatus(code: 100)
  public static let SwitchingProtocols = HTTPStatus(code: 101)

  // Successful 2xx codes
  public static let OK = HTTPStatus(code: 200)
  public static let Created = HTTPStatus(code: 201)
  public static let Accepted = HTTPStatus(code: 202)
  public static let NonAuthoritativeInformation = HTTPStatus(code: 203)
  public static let NoContent = HTTPStatus(code: 204)

  // Redirection 3xx codes.
  public static let MultipleChoices = HTTPStatus(code: 300)
  public static let MovedPermanently = HTTPStatus(code: 301)
  public static let Found = HTTPStatus(code: 302)
  public static let SeeOther = HTTPStatus(code: 303)
  public static let NotModified = HTTPStatus(code: 304)
  public static let UseProxy = HTTPStatus(code: 305)
  public static let TemporaryRedirect = HTTPStatus(code: 307)

  // Client error 4xx codes.
  public static let BadRequest = HTTPStatus(code: 400)
  public static let Unauthorized = HTTPStatus(code: 401)
  public static let PaymentRequired = HTTPStatus(code: 402)
  public static let Forbidden = HTTPStatus(code: 403)
  public static let NotFound = HTTPStatus(code: 404)
  public static let MethodNotAllowed = HTTPStatus(code: 405)
  public static let NotAcceptable = HTTPStatus(code: 406)
  public static let ProxyAuthenticationRequired = HTTPStatus(code: 407)
  public static let RequestTimeout = HTTPStatus(code: 408)
  public static let Conflict = HTTPStatus(code: 409)
  public static let Gone = HTTPStatus(code: 410)
  public static let LengthRequired = HTTPStatus(code: 411)
  public static let PreconditionFailed = HTTPStatus(code: 412)
  public static let RequestEntityTooLarge = HTTPStatus(code: 413)
  public static let RequestURITooLong = HTTPStatus(code: 414)
  public static let UnsupportedMediaType = HTTPStatus(code: 415)
  public static let RequestedRangeNotSatisfiable = HTTPStatus(code: 416)
  public static let ExpectationFailed = HTTPStatus(code: 417)

  // Server error 5xx codes.
  public static let InternalServerError = HTTPStatus(code: 500)
  public static let NotImplemented = HTTPStatus(code: 501)
  public static let BadGateway = HTTPStatus(code: 502)
  public static let ServiceUnavailable = HTTPStatus(code: 503)
  public static let GatewayTimeout = HTTPStatus(code: 504)
  public static let HTTPVersionNotSupported = HTTPStatus(code: 505)
}
