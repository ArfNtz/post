# Post

**An example of simple HTTP SSL POST request**

<a href="https://swift.org" target="_blank"><img src="https://img.shields.io/badge/Language-Swift%205-orange.svg" alt="Language Swift 5"></a>
<img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
<img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**Motivation**

- easy integration into <a href="https://github.com/ArfNtz/ctrs">ctrs</a>

**Features**
- open source development environment and dependencies
- kiss (keep it stupid simple) : minimal code
- non blocking multithread I/O
- linux and macOS compatible
- library and command line executable

**Dependencies**
- Foundation, SwiftNIO, SwiftNIOSSL

**Development tools**
- VSCode 
- <a href="https://lldb.llvm.org">LLDB</a>
- Sourcekit-LSP

**Testing platforms**
- macOS 10.15
- Linux Ubuntu 18.04.

----

## Build

```bash
$ swift build -c release
```

## Use

```bash
$ ./.build/release/filepost
Use : $ filepost <bodyFile> [url] [certFile] [keyFile] [trustRootFile]
Example : $ filepost myTextFile https://localhost:8888
```

Test, send a file to https://google.com :
```bash
$ echo "meilleurs voeux" > myFile.txt
$ ./.build/release/filepost myFile.txt https://google.com
Starting filepost body:myFile.txt, url:https://google.com, cert:[], key:nil, trustRoot:default
moz-border-image:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) 0}}@media only screen and (-webkit-min-device-pixel-ratio:2){#logo{background:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat;-webkit-background-size:100% 100%}}#logo{display:inline-block;height:54px;width:150px}
  </style>
  <a href=//www.google.com/><span id=logo aria-label=Google></span></a>
  <p><b>405.</b> <ins>That’s an error.</ins>
  <p>The request method <code>POST</code> is inappropriate for the URL <code>/</code>.  <ins>That’s all we know.</ins>
```

In a swift program : 
```swift
try HTTPSPoster().post(url: url, body: body, cert: cert, key: key, trustRoot: trustRoot)
```

## Code

VSCode files are located in the `.vscode` directory.
They provide launch and task configurations for debug and test.
These configurations can be used with "Native Debug" or "CodeLLDB" extensions.


## Test

```bash
$ swift test
```
