import Foundation
import NIOSSL
import NIOFoundationCompat
import post

// main starts here
let arg1 = CommandLine.arguments.dropFirst(1).first
if [nil,"","?","-h","--help"].contains(arg1?.trimmingCharacters(in: .whitespaces)) {
    print ("Use : $ filepost <bodyFile> [url] [certFile] [keyFile] [trustRootFile]")
    print ("Example : $ filepost myTextFile https://localhost:8888")
    exit(1)
}
var body:String
do {
    body = try String(contentsOfFile: arg1!)
} catch {
    print("File not found: \(arg1!)")
    exit(1)
}

var url = URL(string: "https://localhost:8888")!
if let arg2 = CommandLine.arguments.dropFirst(2).first {
    url = URL(string: arg2)!
}

var cert: [NIOSSLCertificateSource] = []
if let arg3 = CommandLine.arguments.dropFirst(3).first {
    cert.append(contentsOf: try NIOSSLCertificate.fromPEMFile(arg3).map { .certificate($0) })
}

var key: NIOSSLPrivateKeySource?
if let arg4 = CommandLine.arguments.dropFirst(4).first {
    key = .file(arg4)
}

var trustRoot: NIOSSLTrustRoots = .default
if let arg5 = CommandLine.arguments.dropFirst(5).first {
    trustRoot = .file(arg5)
}

print("Starting filepost body:\(arg1!), url:\(url), cert:\(cert), key:\(String(describing: key)), trustRoot:\(trustRoot)")

var response:String
do {
    response = try HTTPSPoster().post(url: url, body: body, cert: cert, key: key, trustRoot: trustRoot)
} catch {
    response = "\(error)"
}
print(response)

