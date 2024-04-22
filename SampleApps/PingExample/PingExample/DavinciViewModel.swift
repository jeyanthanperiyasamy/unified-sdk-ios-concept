//
//  DavinciViewModel.swift
//  PingExample
//
//  Created by jey periyasamy on 4/22/24.
//

import Foundation
import PingOrchestrate
class DavinciViewModel {
    
    func setup() {
        let nosession = Module.of(block: { setup in
            setup.next { request in
                request.url = "htttp://andy"
                return request
            }
            
            setup.next { request in
                request.url = "htttp://andy"
                return request
            }
        })
        
//        Davinci.config { config in
//            config.module(block: <#T##Module<T>#>, name: <#T##String#>)
//        }
    }
    
}
