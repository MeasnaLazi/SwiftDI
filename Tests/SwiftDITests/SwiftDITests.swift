import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftDIMacros)
import SwiftDIMacros

let testMacros: [String: Macro.Type] = [
    "ApplicationDI" : ApplicationDIMacros.self,
    "ComponentDI" : ComponentDIMacros.self,
    "InjectClass": InjectClassMaros.self
    
]
#endif

final class SwiftDITests: XCTestCase {
    
//    func testMacro() throws {
//        #if canImport(SwiftDIMacros)
//        assertMacroExpansion(
//            """
//            #stringify(a + b)
//            """,
//            expandedSource: """
//            (a + b, "a + b")
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//
//    func testMacroWithStringLiteral() throws {
//        #if canImport(SwiftDIMacros)
//        assertMacroExpansion(
//            #"""
//            #stringify("Hello, \(name)")
//            """#,
//            expandedSource: #"""
//            ("Hello, \(name)", #""Hello, \(name)""#)
//            """#,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
    
    func testMacroApplicationDI() {
        assertMacroExpansion(
            """
            @ApplicationDI("SwiftDITests.SwiftDITests")
            class Application {
            }
            """,
            expandedSource:"""
            
            class Application {
            }
            """,
            macros: testMacros)
    }
    
    func testInjectClass() {
        assertMacroExpansion(
            """
            class Application {
                @InjectClass
                var test: TestService?
            }
            """,
            expandedSource:"""
            
            class Application {
                var test: TestService = {
            
                }
            }
            """,
            macros: testMacros)
    }
    
    func testMacroComponentDI() {
        assertMacroExpansion(
            """
            @ComponentDI()
            class Service {
            }
            """,
            expandedSource:"""
            
            class Service {
            
                required init() {
                }
            }
            
            extension Service: InitializerDI {
                static func createInstace() -> InitializerDI {
                     return self.init()
                }
            }
            """,
            macros: testMacros)
    }
    
    func testMacroComponentDIWithVariable() {
        assertMacroExpansion(
            """
            @ComponentDI()
            class Service {
                private let age: Int = 0
                let id: Int
                private var name: String
                var gender: String = "male"
                var node: String?
            }
            """,
            expandedSource:"""
            
            class Service {
                private let age: Int = 0
                let id: Int
                private var name: String
                var gender: String = "male"
                var node: String?
            
                required init(age: Int, id: Int, name: String, gender: String, node: String?) {
                    self.age = age
                    self.id = id
                    self.name = name
                    self.gender = gender
                    self.node = node
                }
            }
            
            extension Service: InitializerDI {
                static func createInstace() -> InitializerDI {
                    let age: Int = 0
                    let id: Int = 0
                    let name: String = ""
                    let gender: String = "male"
                    let node: String? = nil
            
                    return self.init(age: age, id: id, name: name, gender: gender, node: node)
                }
            }
            """,
            macros: testMacros)
    }
}