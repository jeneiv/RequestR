# RequestR
A lightweight tool for URLRequest Creation for Swift projects

## Purpose

**RequestR** provides a protocol-oriented, extensible way to define and build `URLRequest` objects in Swift. It enables you to describe network requests in a type-safe, modular fashion, making it easy to compose, modify, and test your networking layer.

## Installation

RequestR is distributed as a Swift Package. You can add it to your project using [Swift Package Manager](https://swift.org/package-manager/):

1. In Xcode, go to **File > Add Packages...**
2. Enter the repository URL for RequestR.
3. Select the version and add the package to your target.

Or add it directly to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/jeneiv/RequestR.git", from: "1.0.0")
]
```

Then add `"RequestR"` to your target dependencies.

## Usage

### 1. Define a Request

Conform to the `RequestDescriptor` protocol to describe your request:

```swift
import RequestR

enum MyAPI: RequestDescriptor {
    case getUser(id: String)
    
    var baseURL: URL { URL(string: "https://api.example.com")! }
    
    var path: String {
        switch self {
        case .getUser(let id): return "/users/\(id)"
        }
    }
    
    var method: Method {
        switch self {
        case .getUser: return .get
        }
    }
    
    var tasks: [any RequestModifierTask]? { nil }
    var headers: [String: String]? { nil }
}
```

### 2. Build a URLRequest

```swift
let requestDescriptor = MyAPI.getUser(id: "123")
let urlRequest = try requestDescriptor.toURLRequest()
// Use urlRequest with URLSession or any networking library
```

### 3. Add Custom Modifier Tasks (Optional)

You can create custom tasks to modify the request, such as adding a body or query parameters, by conforming to `RequestModifierTask`.

```swift
struct MyCustomTask: RequestModifierTask {
    func apply(on request: URLRequest) throws(RequestModifierTaskError) -> URLRequest {
        var req = request
        // Modify req as needed
        return req
    }
}
```

Then add it to your descriptor:

```swift
var tasks: [any RequestModifierTask]? {
    [MyCustomTask()]
}
```

## Advanced Usage

Below is a more realistic example of a single `RequestDescriptor` enum handling multiple endpoints and request types:

```swift
import RequestR

struct User: Encodable {
    let name: String
    let age: Int
}

enum MyAPI: RequestDescriptor {
    case getUser(id: String)
    case createUser(User)
    case searchUsers(query: String)
    case uploadFile(Data)
    case updateUser(id: String, user: User)

    var baseURL: URL { URL(string: "https://api.example.com")! }

    var path: String {
        switch self {
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        case .searchUsers:
            return "/users/search"
        case .uploadFile:
            return "/files/upload"
        case .updateUser(let id, _):
            return "/users/\(id)"
        }
    }

    var method: Method {
        switch self {
        case .getUser, .searchUsers:
            return .get
        case .createUser:
            return .post
        case .uploadFile:
            return .post
        case .updateUser:
            return .put
        }
    }

    var headers: [String: String]? {
        switch self {
        case .uploadFile:
            return ["Content-Type": "application/octet-stream"]
        default:
            return nil
        }
    }

    var tasks: [any RequestModifierTask]? {
        switch self {
        case .getUser:
            return nil
        case .createUser(let user):
            return [RequestJSONEncodableModifierTask(encodable: user)]
        case .searchUsers(let query):
            let params = ["q": query]
            return [RequestQueryStringModifierTask(queryItems: params.toQueryItems())]
        case .uploadFile(let data):
            return [RequestHTTPBodyModifierTask(data: data)]
        case .updateUser(_, let user):
            let query = ["notify": "true"]
            return [
                RequestQueryStringModifierTask(queryItems: query.toQueryItems()),
                RequestJSONEncodableModifierTask(encodable: user)
            ]
        }
    }
}
```

### Usage Examples

#### Get a User
```swift
let request = try MyAPI.getUser(id: "123").toURLRequest()
```

#### Create a User (JSON Body)
```swift
let newUser = User(name: "Alice", age: 30)
let request = try MyAPI.createUser(newUser).toURLRequest()
```

#### Search Users (Query Parameters)
```swift
let request = try MyAPI.searchUsers(query: "Alice").toURLRequest()
```

#### Upload a File (Raw Data)
```swift
let fileData = Data(...) // your file data here
let request = try MyAPI.uploadFile(fileData).toURLRequest()
```

#### Update a User (Multiple Modifier Tasks)
```swift
let updatedUser = User(name: "Alice", age: 31)
let request = try MyAPI.updateUser(id: "123", user: updatedUser).toURLRequest()
```

## URLSession-based Provider

RequestR includes a flexible, plugin-driven provider for executing requests using `URLSession`.

### Basic Usage

```swift
import RequestR

let provider = SessionBasedProvider<MyAPI>()

Task {
    do {
        let response = try await provider.data(for: .getUser(id: "123"))
        print("Status: \(response.statusCode)")
        print("Data: \(response.data)")
    } catch {
        print("Request failed: \(error)")
    }
}
```

### The `Response` Type

The provider returns a `Response` object:

```swift
public struct Response {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest
    public let response: HTTPURLResponse
}
```

---

## Plugins

Plugins allow you to hook into the request/response lifecycle for logging, analytics, request modification, and more.

### Plugin Protocol

```swift
public protocol Plugin {
    func prepare(_ request: URLRequest, descriptor: any RequestDescriptor) -> URLRequest
    func willSend(_ request: URLRequest, descriptor: any RequestDescriptor)
    func didReceive(_ response: Response, descriptor: any RequestDescriptor)
    func process(_ response: Response, descriptor: any RequestDescriptor) -> Response
}
```

All methods have default implementations, so you only need to override what you need.

### Example: Logging Plugin

```swift
struct LoggingPlugin: Plugin {
    func willSend(_ request: URLRequest, descriptor: any RequestDescriptor) {
        print("Sending request: \(request)")
    }
    func didReceive(_ response: Response, descriptor: any RequestDescriptor) {
        print("Received response: \(response.statusCode)")
    }
}
```

### Using Plugins

Pass plugins to the provider:

```swift
let provider = SessionBasedProvider<MyAPI>(plugins: [LoggingPlugin()])
```

Plugins will be called in order for each request.

---

# RequestRMocking
A skeleton implementation for mocking responses of URLSession tasks.

## Purpose

**RequestRMocking** provides a flexible way to mock network responses for your tests by subclassing `URLProtocol`. This allows you to simulate different server responses and errors without making real network calls, making your unit tests fast and reliable.

## Installation

Add `RequestRMocking` as a dependency in your test target via Swift Package Manager.  
Import it in your test files:

```swift
import RequestRMocking
```

## Usage

### 1. Subclass `MockURLProtocol`

Create a subclass and override the `mockResponses` property to define the responses for specific URLs:

```swift
import RequestRMocking

class HelloWorldMockURLProtocol: MockURLProtocol {
    override class var mockResponses: [String: MockURLProtocolResponse] {
        [
            "https://api.example.com/hello": .response(
                """
                {"hello": "world"}
                """.data(using: .utf8)!,
                HTTPURLResponse(
                    url: URL(string: "https://api.example.com/hello")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
            )
        ]
    }
}
```

You can also simulate errors:

```swift
class ErrorMockURLProtocol: MockURLProtocol {
    override class var mockResponses: [String: MockURLProtocolResponse] {
        [
            "https://api.example.com/fail": .error(MyCustomError())
        ]
    }
}
```

### 2. Configure URLSession to Use the Mock

In your tests, set up a `URLSession` with a configuration that uses your mock protocol:

```swift
let config = URLSessionConfiguration.ephemeral
config.protocolClasses = [HelloWorldMockURLProtocol.self]
let session = URLSession(configuration: config)
```

### 3. Use with `SessionBasedProvider`

Pass the custom session to your provider:

```swift
let provider = SessionBasedProvider<MyAPI>(session: session)
let response = try await provider.data(for: .getUser(id: "123"))
// response.data will be the mocked data
```

### Example Test (Swift Testing)

```swift
import Testing
import RequestR
import RequestRMocking

@Suite("SessionBasedProvider with Mocking")
struct SessionBasedProviderMockingTests {
    @Test("Returns mocked hello world JSON")
    func testHelloWorldResponse() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [HelloWorldMockURLProtocol.self]
        let session = URLSession(configuration: config)
        let provider = SessionBasedProvider<MyAPI>(session: session)
        let response = try await provider.data(for: .getUser(id: "123"))
        #expect(response.statusCode == 200)
        #expect(String(data: response.data, encoding: .utf8) == "{\"hello\": \"world\"}")
    }
}
```

