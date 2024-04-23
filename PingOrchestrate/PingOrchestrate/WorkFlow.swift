//
//  SampleRequest.swift
//  PingOrchestrate
//
//  Created by jey periyasamy on 4/24/24.
//

import Foundation

extension WorkFlow {
    public static func config(block: (WorkflowConfig) -> Void) -> WorkFlow {
        let workFlowConfig = WorkflowConfig()
        block(workFlowConfig)
        return WorkFlow(config: workFlowConfig)
    }
}

public enum ModuleKeys: String {
    case customHeader = "customHeader"
    case nosession = "nosession"
    case forceAuth = "forceAuth"
}


public class WorkFlow {
    let workFlowConfig: WorkflowConfig
    
    let context = Context()
    
    let request = Request()
    
    let httpclient = URLSession.shared
    
    private let lock = NSLock()
    
    private var started = false
    
    // state
    
    var initFunctions = [() async -> Void]()
    var startFunctions = [(FlowContext, Request) async -> Request]()
    var nextFunctions = [(FlowContext, Request) async -> Request]()
    var responseFunctions = [(FlowContext, Response) async -> Void]()
    var nodeFunctions = [(FlowContext, Node) async -> Node]()
    var successFunctions = [(FlowContext, Success) async -> Success]()
    var signOffFunctions = [(Request) async -> Request]()
    
    var transformFunction: (FlowContext, Response) async -> Node = { _, _ in Empty() }
    
    
    init(config: WorkflowConfig) {
        self.workFlowConfig = config
        self.workFlowConfig.register(workFlow: self)
    }
    
    
    private func initialize() async {
        if !started {
            for initBlock in initFunctions {
                await initBlock()
            }
            started = true
        }
    }
    
    func start(request: Request) async -> Node {
        await initialize()
        let context = FlowContext(context: context)
        var req = request
        for startBlock in startFunctions {
            req = await startBlock(context, req)
        }
        let response = await send(context, request: req)
        return await next(context, await transformFunction(context, response))
    }
    
    func start() async -> Node {
        return await start(request: Request())
    }
    
    private func send(_ context: FlowContext, request: Request) async -> Response {
        let urlRequest = request.urlRequest
        let (data, response) = try! await URLSession.shared.data(for: urlRequest)
        let resp = Response(data: data, response: response)
        for responseBlock in responseFunctions {
            await responseBlock(context, resp)
        }
        return resp
    }
    
    private func send(_ request: Request) async -> Response {
        let urlRequest = request.urlRequest
        let (data, response) = try! await URLSession.shared.data(for: urlRequest)
        return Response(data: data, response: response)
    }
    
    func next(_ context: FlowContext, _ node: Node) async -> Node {
        if let success = node as? Success {
            var result = success
            for successBlock in successFunctions {
                result = await successBlock(context, result)
            }
            return result
        } else {
            return node
        }
    }
    
    func next(_ context: FlowContext, _ current: Connector) async -> Node {
        let initialRequest = current.asRequest()
        var request = initialRequest
        for nextBlock in nextFunctions {
            request = await nextBlock(context, request)
        }
        let initialNode = await transformFunction(context, await send(context, request: request))
        var node = initialNode
        for nodeBlock in nodeFunctions {
            node = await nodeBlock(context, node)
        }
        return node
    }
    
    func signOff() async -> Response {
        await initialize()
        var request = Request()
        for signOffBlock in signOffFunctions {
            request = await signOffBlock(request)
        }
        return await send(request)
    }
    
    
    private func response(context: FlowContext, response: Response) async throws {
        for function in responseFunctions {
            await function(context, response)
        }
    }
    
}


public class FlowContext {
    let flowContext: Context
    
    init(context: Context) {
        self.flowContext = context
    }
    
    // need to move the corresponding functions here
}

// MARK: - Context
public class  Context {
    private var map: [String: Any] = [:]
    
    // Initialize the Context with an empty dictionary or a pre-existing one
    public init(_ map: [String: Any] = [:]) {
        self.map = map
    }
    
    
    subscript<T>(key: String) -> T? {
        get { return map[key] as? T }
        set { map[key] = newValue }
    }
}


public class WorkflowConfig {
    
    // this needs to be Module name  private var modules: [Module: ModuleRegistry] = [:]
    
   // let cache = NSCache<Module<Any>, ModuleRegistry<Any>>()
    
    var modules: [String: any ModuleRegistryProtocol] = [:]
    
    public var debug = false
    public var timeout = 0
    
    
    public func module<T>(block: Module<T>,
                          name: String,
                          config: @escaping (T) -> (Void) = { _ in }) {
        modules[name] = ModuleRegistry(module: block.setup, config: configValue(initalValue: block.config, nextValue: config) )
    }
    
    private func configValue<T>(initalValue: @escaping () -> (T), nextValue: @escaping (T) -> (Void)) -> T {
        let initConfig = initalValue()
        nextValue(initConfig)
        return initConfig
    }
    
    public func register(workFlow: WorkFlow) {
        modules.forEach {
            $0.value.register(workflow: workFlow)
        }
    }
}

protocol ModuleRegistryProtocol {
    associatedtype Element
    var config: Element { get }
    var moduleValue: (Setup<Element>) -> (Void) { get }
    func register(workflow: WorkFlow)
}



public class ModuleRegistry<T>: ModuleRegistryProtocol {
    typealias Element = T
    
    let moduleValue: (Setup<T>) -> (Void)
    let config: T
    
    public init(module: @escaping (Setup<T>) -> (Void), config: T) {
        self.moduleValue = module
        self.config = config
    }
    
    func register(workflow: WorkFlow) {
        let setup = Setup(workflow: workflow, config: self.config)
        moduleValue(setup)
    }
}


public class Module<T> {
    public var setup: (Setup<T>) -> (Void)
    public var config: () -> (T)
    
    init( config: @escaping () -> (T), type: @escaping (Setup<T>) -> (Void)) {
        self.setup = type
        self.config = config
    }
    
    public static func of(config: @escaping (() -> (T)) = {} , block: @escaping (Setup<T>) -> (Void)) -> Module<T> {
        return Module<T>(config: config, type: block)
    }
    
}

// Setup class for configuring workflow operations
public class Setup<ModuleConfig> {
    let workflow: WorkFlow
    let context: Context
    let config: ModuleConfig
    
    public init(workflow: WorkFlow, context: Context = Context(), config: ModuleConfig) {
        self.workflow = workflow
        self.context = context
        self.config = config
    }
    
    func initialize(block: @escaping () async -> Void) {
        workflow.initFunctions.append(block)
    }
    
    func start(block: @escaping (FlowContext, Request) async -> Request) {
        workflow.startFunctions.append(block)
    }
    
    func next(block: @escaping (FlowContext, Request) async -> Request) {
        workflow.nextFunctions.append(block)
    }
    
    func response(block: @escaping (FlowContext, Response) async -> Void) {
        workflow.responseFunctions.append(block)
    }
    
    func nodeReceived(block: @escaping (FlowContext, Node) async -> Node) {
        workflow.nodeFunctions.append(block)
    }
    
    func success(block: @escaping (FlowContext, Success) async -> Success) {
        workflow.successFunctions.append(block)
    }
    
    func transform(block: @escaping (FlowContext, Response) async -> Node) {
        workflow.transformFunction = block
    }
    
    func signOff(block: @escaping (Request) async -> Request) {
        workflow.signOffFunctions.append(block)
    }
}
