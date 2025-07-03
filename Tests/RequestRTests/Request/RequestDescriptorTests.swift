//
//  Test.swift
//  RequestR
//
//  Created by Viktor Jenei on 2025. 06. 26..
//

import Foundation
import Testing
@testable import RequestR

// MARK: - Test Cases

@Suite(
    "Tests of RequestDescriptor",
    .tags(.requestDescriptorTests)
)
struct RequestDescriptorTests {
    
    @Test("Testing a plain request with host, path and method")
    func plainGetRequestTest() throws {
        let sut = TestRequestDescriptor.plainGETRequest
        
        let resultReqest = try sut.toURLRequest()
        #expect(resultReqest.url?.absoluteString == "https://example.com/requestPath")
        #expect(resultReqest.url?.pathComponents.last == "requestPath")
        #expect(resultReqest.httpMethod == "GET")
    }
    
    @Test("Testing a plain request with host, path, method and header array")
    func testPutRequestWithHeaders() throws {
        let sut = TestRequestDescriptor.putRequestWithHeaders

        let resultReqest = try sut.toURLRequest()
        #expect(resultReqest.url?.absoluteString == "https://example.com/pathComponenet1/pathComponenet2")
        #expect(resultReqest.url?.pathComponents.dropFirst() == ["pathComponenet1", "pathComponenet2"])
        #expect(resultReqest.httpMethod == "PUT")
        #expect(resultReqest.allHTTPHeaderFields == ["Authorization": "Bearer some_token"])
    }

    @Test("Testing the execution of RequestModifierTasks")
    func testRequestModifierTasksExecution() throws {
        var modifierTaskExecuted = false
        let sut = TestRequestDescriptor.postRequestWithModifierTask {
            modifierTaskExecuted = true
        }

        let resultReqest = try sut.toURLRequest()
        #expect(resultReqest.url?.absoluteString == "https://somewhere.net/")
        #expect(resultReqest.url?.pathComponents.last == "/")
        #expect(resultReqest.httpMethod == "POST")
        #expect(modifierTaskExecuted)
    }
}

// MARK: - Additional Code

fileprivate enum TestRequestDescriptor {
    case plainGETRequest
    case putRequestWithHeaders
    case postRequestWithModifierTask(modifierTaskClosure: () -> Void)
}

extension TestRequestDescriptor: RequestDescriptor {
    var baseURL: URL {
        switch self {
        case .plainGETRequest, .putRequestWithHeaders:
            URL(string: "https://example.com")!
        case .postRequestWithModifierTask:
            URL(string: "https://somewhere.net")!
        }
    }

    var path: String {
        switch self {
        case .plainGETRequest:
            "/requestPath"
        case .putRequestWithHeaders:
            "/pathComponenet1/pathComponenet2"
        default:
            ""
        }
    }

    var method: RequestR.Method {
        switch self {
        case .plainGETRequest:
            .get
        case .putRequestWithHeaders:
            .put
        case .postRequestWithModifierTask:
                .post
        }
    }
    
    var tasks: [any RequestModifierTask]? {
        switch self {
        case .plainGETRequest, .putRequestWithHeaders:
            nil
        case .postRequestWithModifierTask(let modifierTaskClosure):
            [MockRequestModifierTask(applyExecutionClosure: modifierTaskClosure)]
        }
    }

    var headers: [String: String]? {
        switch self {
        case .plainGETRequest, .postRequestWithModifierTask:
            nil
        case .putRequestWithHeaders:
            ["Authorization": "Bearer some_token"]
        }
    }
}

fileprivate class MockRequestModifierTask: RequestModifierTask {
    var applyExecutionClosure: () -> Void

    init(applyExecutionClosure: @escaping () -> Void) {
        self.applyExecutionClosure = applyExecutionClosure
    }

    func apply(on request: URLRequest) throws(RequestModifierTaskError) -> URLRequest {
        applyExecutionClosure()
        return request
    }
}
