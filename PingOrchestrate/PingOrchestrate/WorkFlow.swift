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
    var response: [(Response) async throws -> (Void)] = []
    var initialize: [() async throws -> (Void)] = []
    var signOff: [(Request) async throws -> (Request)] = []
    var node: [(Node) async throws -> Node] = []
    var success: [(Success) async throws -> Success] = []
    var transform: [(Response) async throws -> Response] = []
    
    init(config: WorkflowConfig) {
        self.workFlowConfig = config
        self.workFlowConfig.register(workFlow: self)
    }
    
    func start() async {
        await start(request: request)
    }
    
    
    private func start(request: Request) async {
        do {
            
            var updatedRequest = request
            for block in next {
                updatedRequest = try await block(updatedRequest)
            }
            print("")
            
        }
        catch {
            
        }
    }
}


public class WorkflowConfig {
    
    // this needs to be Module name  private var modules: [Module: ModuleRegistry] = [:]
    private var modules: [String: any ModuleRegistryProtocol] = [:]
    
    public var debug = false
    public var timeout = 0
    
    
    public func module<T>(block: Module<T>, 
                          name: String,
                          config: T = Void.self) {
        modules[name] = ModuleRegistry(module: block.setup, config: config)
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
    
    static func of(config: T = Void.self, block: @escaping (Setup<T>) -> (Void)) -> Module {
        return Module<T>(config: config, type: block)
    }
    
}

public class Setup<T> {
     
    var workflow: WorkFlow
    var config: T
    
    init(flow: WorkFlow, config: T) {
        self.workflow = flow
        self.config = config
    }
    
    func next(block: @escaping (Request) async throws -> Request) {
        workflow.next.append(block)
    }
    
    func start(block: @escaping (Request) async throws -> Request) {
        workflow.start.append(block)
    }
    
    func response(block: @escaping (Response) async throws -> Void) {
        workflow.response.append(block)
    }
    
    func nodeReceived(block: @escaping (Node) async throws -> Node) {
        workflow.node.append(block)
    }
    
    func success(block: @escaping (Success) async throws -> Success) {
        workflow.success.append(block)
    }
    
    func transform(block: @escaping (Response) async throws -> Response) {
        workflow.transform.append(block)
    }
    
    func signOff(block: @escaping (Request) async throws -> Request) {
        workflow.signOff.append(block)
    }
    
    func initialize(block: @escaping () async throws -> (Void)) {
        workflow.initialize.append(block)
    }

}


public class Orchestrator {
    func execute(request: Request) -> Request {
        return request
    }
}


public class Request {
    
    var urlValue: String? = nil
    
    func url(url: String) {
        self.urlValue = url
    }
}
    
public class Node {
    
}

public class Response {
    
}

public class Success {
    
}
