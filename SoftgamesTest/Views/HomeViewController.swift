//
//  HomeViewController.swift
//  SoftgamesTest
//
//  Created by ThomasPiechula on 03/05/2022.
//

import UIKit
import WebKit

class HomeViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    lazy var viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareViews()
        prepareStyle()
        initViewModel()
    }
    
    func prepareStyle() {
        self.view.backgroundColor = .brown
        
        self.title = "Softgames Test"
    }
    
    func prepareViews() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            debugPrint("index not found")
        }

        
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "homeMessageHandler")
        var script:String?
        if let filePath:String = Bundle(for: HomeViewController.self).path(forResource: "message", ofType:"js") {
            script = try! String(contentsOfFile: filePath, encoding: .utf8)
        }
        let userScript:WKUserScript =  WKUserScript(source: script!, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        

    }
    
    func initViewModel()
    {
        viewModel.onScriptUpdate = { [weak self] (script: String) in
            self?.webView.evaluateJavaScript(script) { (result, error) in
                if let result = result {
                    print("Label is updated with message: \(result)")
                } else if let error = error {
                    print("An error occurred: \(error)")
                }
            }
        }
    }
    

}

extension HomeViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }
        
        viewModel.scriptRequest(messageBody: dict)
        
    }
    
}

