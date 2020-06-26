import XCTest
import GRPC
import NIO
@testable import HealthProvider

final class HealthProviderTests: XCTestCase {
    
    var healthProvider : HealthProvider!
    var server : Server!
    var channel : ClientConnection!
    var group : EventLoopGroup!
    
    let serviceName = "TestService"
    
    func testGet() {
        let client = Grpc_Health_V1_HealthClient(channel: channel)
        healthProvider.setHealth(status:.serving, service:serviceName)
        let done = channel.eventLoop.makePromise(of: Void.self)

        
        client.check(Grpc_Health_V1_HealthCheckRequest.with { $0.service = serviceName}).response.whenSuccess {
            XCTAssertEqual($0.status, HealthProvider.Status.serving)
            done.succeed(())
        }
        
         try! done.futureResult.wait()
    }
    
    func testWatch() {
        var receivedStatusCount = 0
        var receivedStatus : HealthProvider.Status? = nil
        let done = channel.eventLoop.makePromise(of: Void.self)
        let subscribed = channel.eventLoop.makePromise(of: Void.self)
        healthProvider.setHealth(status:.unknown, service:serviceName)
        
        let client = Grpc_Health_V1_HealthClient(channel: channel)
        _ = client.watch(Grpc_Health_V1_HealthCheckRequest.with({ $0.service = serviceName })) { (response) in
            
            subscribed.succeed(())
            
            receivedStatusCount += 1;
            receivedStatus = response.status
            
            switch receivedStatusCount {
                case 1: XCTAssertEqual(receivedStatus, HealthProvider.Status.unknown)
                case 2: XCTAssertEqual(receivedStatus, HealthProvider.Status.notServing)
                case 3: XCTAssertEqual(receivedStatus, HealthProvider.Status.serving)
                fallthrough
            default:
                done.succeed(())
            }
        }
        try! subscribed.futureResult.wait()
        
        healthProvider.setHealth(status:.notServing, service:serviceName)
        healthProvider.setHealth(status:.serving, service:serviceName)
        
        try! done.futureResult.wait()
    }
    
    func setupServer() throws {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.server = try Server.insecure(group: self.group)
        .withServiceProviders([healthProvider])
        .bind(host: "localhost", port: 0)
        .wait()
    }
    
    override func setUp() {
        healthProvider = HealthProvider()
        XCTAssertNoThrow(try setupServer())
        channel = ClientConnection
            .insecure(group: group)
            .connect(host: "localhost", port: server.channel.localAddress!.port!)
    }
    
    override func tearDown() {
        try! channel.close().wait()
        try! self.server.close().wait()
        try! self.group.syncShutdownGracefully()
    }

    static var allTests = [
        ("testWatch", testWatch),
        ("testWatch", testWatch),
    ]
}
