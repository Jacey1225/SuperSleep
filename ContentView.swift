//  ContentView.swift
//  Super Sleep
//
//  Created by Jacey Simpson on 6/8/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlFileName: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } else {
            let html = "<html><body><h1>file not found</h1></body></html>"
            uiView.loadHTMLString(html, baseURL: nil)
        }
    }
}

struct ContentView: View {
    var body: some View {
        WelcomeView()
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
