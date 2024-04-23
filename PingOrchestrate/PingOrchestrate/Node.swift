//
//  SampleRequest.swift
//  PingOrchestrate
//
//  Created by jey periyasamy on 4/24/24.
//

protocol Storage {
    associatedtype Value
    func get() -> Value?
    mutating func save(_ value: Value)
    mutating func delete()
}

struct MemoryStorage<Value>: Storage {
    private var value: Value?
    
    func get() -> Value? {
        return value
    }
    
    mutating func save(_ value: Value) {
        self.value = value
    }
    
    mutating func delete() {
        value = nil
    }
}


protocol Node {}

struct Empty: Node {}

struct ErrorType: Node {}

class Connector: Node {
    let context: FlowContext
    let workflow: WorkFlow
    let input: JsonObject
    let callbacks: [Callback]
    
    init(context: FlowContext, workflow: WorkFlow, input: JsonObject, callbacks: [Callback]) {
        self.context = context
        self.workflow = workflow
        self.input = input
        self.callbacks = callbacks
    }
    
    func asRequest() -> Request {
        fatalError("Must be overridden in subclass")
    }
    
    func next() async -> Node {
        return await workflow.next(context, self)
    }
}

struct Success: Node {
    let session: Session
}

protocol Failure: Node {
    func message() -> String
    func raw() -> String
}

// MARK: - Callback
protocol Callback {
    func asJson() -> JsonObject
}

// MARK: - Session
protocol Session {
    func value() -> String
}

struct EmptySession: Session {
    func value() -> String {
        return ""
    }
}

// MARK: - Helpers
struct JsonObject: Codable {}
