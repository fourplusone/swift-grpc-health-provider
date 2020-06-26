import Foundation
import GRPC

public typealias HealthClient = Grpc_Health_V1_HealthClient


public extension HealthClient {
    
    /// Checks thet status of a Service
    /// If the requested service is unknown, the call will fail with status
    /// NOT_FOUND.
    ///
    /// - Parameters:
    ///   - service: The name of the service that should be checked.
    ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
    /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
    func check(service: String,
      callOptions: CallOptions? = nil
    ) -> UnaryCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse> {
        check(Grpc_Health_V1_HealthCheckRequest.with({ $0.service = service }), callOptions: callOptions)
    }
    
    
    /// Performs a watch for the serving status of the requested service.
    /// The server will immediately send back a message indicating the current
    /// serving status.  It will then subsequently send a new message whenever
    /// the service's serving status changes.
    ///
    /// If the requested service is unknown when the call is received, the
    /// server will send a message setting the serving status to
    /// SERVICE_UNKNOWN but will *not* terminate the call.  If at some
    /// future point, the serving status of the service becomes known, the
    /// server will send a new message with the service's serving status.
    ///
    /// If the call terminates with status UNIMPLEMENTED, then clients
    /// should assume this method is not supported and should not retry the
    /// call.  If the call terminates with any other status (including OK),
    /// clients should retry the call with appropriate exponential backoff.
    ///
    /// - Parameters:
    ///   - service: The name of the service that should be watched.
    ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
    ///   - handler: A closure called when each response is received from the server.
    /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
    func watch(
      service: String,
      callOptions: CallOptions? = nil,
      handler: @escaping (Grpc_Health_V1_HealthCheckResponse) -> Void) -> ServerStreamingCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse> {
        return watch(Grpc_Health_V1_HealthCheckRequest.with({ $0.service = service }), callOptions: callOptions, handler: handler)
    }
    
}
