//===----------------------------------------------------------------------===//
// HTTPs post
// For linux & macOS
// Based on Apple's SwiftNIO and SwiftNIO SSL libraries
//===----------------------------------------------------------------------===//

import NIO
import NIOHTTP1
import NIOSSL
import Foundation
import NIOFoundationCompat

public class HTTPSPoster {

    public init() {}

    public func post(url:URL = URL(string: "https://localhost:8888")!, body:String = "", cert:[NIOSSLCertificateSource] = [], key:NIOSSLPrivateKeySource? = nil, trustRoot:NIOSSLTrustRoots = .default) throws -> String {

        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let promise: EventLoopPromise<String> = eventLoopGroup.next().makePromise(of: String.self)
        defer {
            try! eventLoopGroup.syncShutdownGracefully()
        }

        // added "certificateVerification: .none,"
        // should instead add the CA to trusted roots
        let tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none, trustRoots: trustRoot, certificateChain: cert, privateKey: key, renegotiationSupport: .once)
        let sslContext = try NIOSSLContext(configuration: tlsConfiguration)

        let bootstrap = ClientBootstrap(group: eventLoopGroup)
                .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
                .channelInitializer { channel in
                    do {
                        let openSslHandler = try NIOSSLClientHandler(context: sslContext, serverHostname: url.host)
                        return channel.pipeline.addHandler(openSslHandler).flatMap {
                            channel.pipeline.addHTTPClientHandlers()
                        }.flatMap { _ in
                            channel.pipeline.addHandler(HTTPResponseHandler(promise))
                        }
                    } catch {
                        return channel.close()
                    }
                }

        bootstrap.connect(host: url.host ?? "", port: url.port ?? 443)
            .flatMap { self.sendRequest(url, body, $0) }
                .cascadeFailure(to: promise)

        return try promise.futureResult.wait()
    }

    private func sendRequest(_ url: URL, _ body:String, _ channel: Channel) -> EventLoopFuture<Void> {
        var request = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1), method: HTTPMethod.POST, uri: url.absoluteString)
        request.headers = HTTPHeaders([
            ("Host", url.host!),
        ("User-Agent", "ArfPost"),
            ("Accept", "application/json"),
            ("Connection", "close")
        ])
        channel.write(HTTPClientRequestPart.head(request), promise: nil)

        // body to post
        var buf = channel.allocator.buffer(capacity: 0)
        buf.writeString(body)
        channel.write(HTTPClientRequestPart.body(IOData.byteBuffer(buf)), promise: nil)

        return channel.writeAndFlush(HTTPClientRequestPart.end(nil))
    }

}

private final class HTTPResponseHandler: ChannelInboundHandler {

    typealias InboundIn = HTTPClientResponsePart
    let promise: EventLoopPromise<String>
    var closeFuture: EventLoopFuture<Void>? = nil
    var body:String = ""

    init(_ promise: EventLoopPromise<String>) {
        self.promise = promise
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let httpResponsePart = unwrapInboundIn(data)
        switch httpResponsePart {
        case .head(let httpResponseHeader):
            ()
        case .body(var byteBuffer):
            if let d:Data = byteBuffer.readData(length: byteBuffer.readableBytes) {
                self.body = String(data: d, encoding: .utf8) ?? ""
            }
        case .end(_):
            closeFuture = context.channel.close()
            promise.succeed(self.body)
        }
    }

    func channelInactive(context: ChannelHandlerContext) {
        if closeFuture == nil {
            closeFuture = context.channel.close()
            promise.fail(ChannelError.inputClosed)
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        closeFuture = context.channel.close()
        promise.fail(error)
    }
}
