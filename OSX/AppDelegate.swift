//
//  AppDelegate.swift
//  DynamoApp
//
//  Created by John Holdsworth on 20/06/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import Cocoa
import Dynamo
import WebKit

public var evalJavaScript: ((String) -> String?)!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, /*WebFrameLoadDelegate,*/ WKUIDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var webView: WebView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        let serverPort: UInt16 = 8080, sslServerPort: UInt16 = 9090
        let documentRoot = "\(NSHomeDirectory())/Sites"

        // create shared swiftlet for server applications
        let exampleTableGenerator = ExampleAppSwiftlet( pathPrefix: "/example" )
        let tickTackToeGame = BundleSwiftlet( pathPrefix: "/ticktacktoe", bundleName: "TickTackToe" )!

        let logger = {
            (msg: String) in
            print( msg )
        }

        // create non-SSL server/proxy on 8080
        _ = DynamoWebServer( portNumber: serverPort, swiftlets: [
            LoggingSwiftlet( logger: dynamoTrace ),
            exampleTableGenerator,
            tickTackToeGame,
            SSLProxySwiftlet( logger: logger ),
            ProxySwiftlet( logger: logger ),
            ServerPagesSwiftlet( documentRoot: documentRoot ),
            DocumentSwiftlet( documentRoot: documentRoot )
        ] )

        let keyChainName = "DynamoSSL"
        var certs = DDKeychain.sslIdentityAndCertificates( keyChainName )
        if certs?.count == 0 {
            DDKeychain.createNewIdentity( keyChainName )
            certs = DDKeychain.sslIdentityAndCertificates( keyChainName )
        }

        // create SSL server on port 9090
        _ = DynamoSSLWebServer( portNumber: sslServerPort, swiftlets: [
            LoggingSwiftlet( logger: { print( $0 ) } ),
            exampleTableGenerator,
            tickTackToeGame,
            ServerPagesSwiftlet( documentRoot: documentRoot ),
            DocumentSwiftlet( documentRoot: documentRoot )
        ], certs: certs! as [AnyObject] )

        // or can make SSL proxy to any non-SSL web server
        _ = DynamoSSLWebServer( portNumber: 9191, certs: certs! as [AnyObject], surrogate: "http://localhost:\(serverPort)" )

        evalJavaScript = {
            javascript in
            return self.webView.windowScriptObject.evaluateWebScript( javascript ) as? String
        }

        webView.mainFrame.load( URLRequest( url: URL( string: "http://localhost:\(serverPort)" )! ) )
    }

    func webView( _ aWebView: WebView, didReceiveTitle aTitle: String, forFrame frame: WebFrame ) {
        window.title = aTitle
    }

    func webView( _ sender: WebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WebFrame ) {
        let alert = NSAlert()
        alert.messageText = "JavaScript message from page"
        alert.informativeText = message
        alert.runModal()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
