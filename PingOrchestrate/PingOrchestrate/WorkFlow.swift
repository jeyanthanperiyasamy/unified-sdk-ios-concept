import Foundation

public class Davinci {
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
    
    let request = Request()
    
    // state
    
    var next: [(Request) async throws -> Request] = []
    var start: [(Request) async throws -> Request] = []
    var response: [(ResponseState) async throws -> (Void)] = []
    var initialize: [() async throws -> (Void)] = []
    var signOff: [(Request) async throws -> (Request)] = []
    var node: [(Node) async throws -> Node] = []
    var success: [(Success) async throws -> Success] = []
    
    var transform: (ResponseState) async throws -> Node = { _ in EmptyState() }
    
    var flowcontext:[String: Any] = [:]
    
    init(config: WorkflowConfig) {
        self.workFlowConfig = config
        self.workFlowConfig.register(workFlow: self)
    }
    
    func start() async {
        await start(request: request)
    }
    
    
    private func start(request: Request) async {
        
         flowcontext = [:]
        
        do {
            var updatedRequest = request
            for block in next {
                updatedRequest = try await block(updatedRequest)
            }
            
            let result = await RestClient.shared.invoke(request: updatedRequest)
            print(result)
            
        }
        catch {
            
        }
    }
}

public class FlowContext {
    let flowcontext: [String: Any] = [:]
    
    // need to move the corresponding functions here
}

public class WorkFlowContext {
    let workFlowContext: [String: Any] = [:]
    
    // need to move the corresponding functions here
}


public class WorkflowConfig {
    
    // this needs to be Module name  private var modules: [Module: ModuleRegistry] = [:]
     var modules: [String: any ModuleRegistryProtocol] = [:]
    
    public var debug = false
    public var timeout = 0
    
    
    public func module<T>(block: Module<T>, 
                          name: String,
                          config: @escaping (T) -> (Void) = { _ in }) {
        modules[name] = ModuleRegistry(module: block.setup, config: configValue(initalValue: block.config, nextValue: config))
    }
    
    private func configValue<T>(initalValue: T, nextValue: @escaping (T) -> (Void)) -> ((T) -> (Void)) {
        nextValue(initalValue)
        return { initalValue in }
    }
    
    public func register(workFlow: WorkFlow) {
        modules.forEach {
            $0.value.register(workflow: workFlow)
        }
    }
}

protocol ModuleRegistryProtocol {
    associatedtype Element
    var config: (Element) -> (Void) { get }
    var moduleValue: (Setup<Element>) -> (Void) { get }
    func register(workflow: WorkFlow)
}

public class ModuleRegistry<T>: ModuleRegistryProtocol {
    typealias Element = T
        
    let moduleValue: (Setup<T>) -> (Void)
    let config: (T) -> (Void)
    
    public init(module: @escaping (Setup<T>) -> (Void), config: @escaping (T) -> (Void)) {
        self.moduleValue = module
        self.config = config
    }
    
    func register(workflow: WorkFlow) {
        let setup = Setup(flow: workflow, config: self.config)
        moduleValue(setup)
    }
}


public class Module<T> {
    public var setup: (Setup<T>) -> (Void)
    public var config: T
    
     init( config: T, type: @escaping (Setup<T>) -> (Void)) {
        self.setup = type
        self.config = config
    }
    
    public static func of(config: T = Void.self, block: @escaping (Setup<T>) -> (Void)) -> Module<T> {
        return Module<T>(config: config, type: block)
    }
    
}

public class Setup<T> {
     
    var workflow: WorkFlow
    var config: (T) -> (Void)
    
    public init(flow: WorkFlow, config: @escaping (T) -> (Void)) {
        self.workflow = flow
        self.config = config
    }
    
    public func next(block: @escaping (Request) async throws -> Request) {
        workflow.next.append(block)
    }
    
    public func start(block: @escaping (Request) async throws -> Request) {
        workflow.start.append(block)
    }
    
    public func response(block: @escaping (ResponseState) async throws -> Void) {
        workflow.response.append(block)
    }
    
    public func nodeReceived(block: @escaping (Node) async throws -> Node) {
        workflow.node.append(block)
    }
    
    public func success(block: @escaping (Success) async throws -> Success) {
        workflow.success.append(block)
    }
    
    public func transform(block: @escaping (ResponseState) async throws -> Node) {
        workflow.transform = block
    }
    
    public func signOff(block: @escaping (Request) async throws -> Request) {
        workflow.signOff.append(block)
    }
    
    public func initialize(block: @escaping () async throws -> (Void)) {
        workflow.initialize.append(block)
    }

}


public class Orchestrator {
    func execute(request: Request) -> Request {
        return request
    }
}


public protocol Node {}

public class EmptyState: Node {}
public class ResponseState: Node {}
public class ErrorState: Node {}
public class Connector: Node {}
public class Success: Node {}
