import NIO
import GRPC
import Foundation

public class HealthProvider : Grpc_Health_V1_HealthProvider {
    
    public typealias Status = Grpc_Health_V1_HealthCheckResponse.ServingStatus
    
    class Observer<T> {
        let observe: (T) -> Void
        init(_ observe: @escaping (T) -> Void) {
            self.observe = observe
        }
    }
    
    private var services : [String: Status] = [:]
    private var observerMapping : [String: [Observer<String>]] = [:]
    private let observerLock = NSLock()
    
    public init() {
    }
    
    
    /// Set the health of a service
    /// - Parameters:
    ///   - status: Health Status of the Cervice
    ///   - service: Name of the Service
    public func setHealth(status: Status, service: String) {
        services[service] = status
        
        if let observers = observerMapping[service] {
            for observer in observers {
                observer.observe(service)
            }
        }
    }
    
    func status(forService service: String) -> Status {
        services[service] ?? .unknown
    }
    
    func register(observer:Observer<String>, service:String) {
        observerLock.lock()
        defer { observerLock.unlock() }
        
        var mapping = observerMapping[service] ?? []
        mapping.append(observer)
        observerMapping[service] = mapping
    }
    
    func unregister(observer: Observer<String>, service:String) {
        if var mapping = observerMapping[service] {
            mapping.removeAll { $0 === observer }
        }
    }
    
    
    public func check(request: Grpc_Health_V1_HealthCheckRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Grpc_Health_V1_HealthCheckResponse> {
        
        let response = Grpc_Health_V1_HealthCheckResponse.with {
            $0.status = status(forService: request.service)
        }
        
        return context.eventLoop.makeSucceededFuture(response)
        
    }
    
    
    public func watch(request: Grpc_Health_V1_HealthCheckRequest, context: StreamingResponseCallContext<Grpc_Health_V1_HealthCheckResponse>) -> EventLoopFuture<GRPCStatus> {
        
        var observer : Observer<String>! = nil
        observer = Observer<String> { [weak context] service in
            _ = context?.sendResponse(Grpc_Health_V1_HealthCheckResponse.with {
                $0.status = self.status(forService: service)
            })
        }
        
        register(observer: observer, service: request.service)
        observer.observe(request.service)
        
        
        context.statusPromise.futureResult.whenComplete { _ in
            self.unregister(observer: observer, service: request.service)
        }
        
        return context.eventLoop.makePromise(of: GRPCStatus.self).futureResult
    }
    
    
}
