import Foundation

public class Davinci {
    public static func config(block: (WorkflowConfig) -> Void) -> WorkFlow {
        let workFlowConfig = WorkflowConfig()
        block(workFlowConfig)
        return WorkFlow(config: workFlowConfig)
    }
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
    
    func start(request: Request) async {
        do {
            for block in start {
                try await block(request)
            }
        }
        catch {
            
        }
    }
}


public class WorkflowConfig {
    
    // this needs to be Module name  private var modules: [Module: ModuleRegistry] = [:]
    private var modules: [String: ModuleRegistry] = [:]
    
    public var debug = false
    public var timeout = 0
    
    
    public func module(block: Module, name: String) {
        modules[name] = ModuleRegistry(module: block.setup)
    }
    
    public func register(workFlow: WorkFlow) {
        modules.forEach {
            $0.value.register(workflow: workFlow)
        }
    }
}

public class ModuleRegistry {
    
    let moduleValue: (Setup) -> (Void)
    
    public init(module: @escaping (Setup) -> (Void)) {
        moduleValue = module
    }
    
    func register(workflow: WorkFlow) {
        let setup = Setup(flow: workflow)
        moduleValue(setup)
    }
}


public class Module {
    public var setup: (Setup) -> (Void)
    
    init(type: @escaping (Setup) -> (Void)) {
        self.setup = type
    }
    
    static func of(block: @escaping (Setup) -> (Void)) -> Module {
        return Module(type: block)
    }
    
}

public class Setup {
     
    var workflow: WorkFlow
    
    init(flow: WorkFlow) {
        self.workflow = flow
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
    func url(url: String) {
        
    }
}
    
public class Node {
    
}

public class Response {
    
}

public class Success {
    
}


//typealias FlowRequest = (Flow, Request) -> Request

//typealias BlockType = (Flow) -> (Request) -> Request
