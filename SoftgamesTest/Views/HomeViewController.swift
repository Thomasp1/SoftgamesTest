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
    
    private let nameId: String = "namevalue"
    private let birthdayId: String = "birthdayvalue"

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareViews()
        prepareStyle()
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
    

}

extension HomeViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }
        
        if let bdate = dict["bdate"] as? String {
            DispatchQueue.global().async { [self] in
                sleep(5)
                DispatchQueue.main.async { [self] in
                    showData(elementId: birthdayId, innerText: bdate)
                }
            }
        } else if let fName = dict["fname"] as? String, let lName = dict["lname"] as? String{
            let nameText = "\(fName) \(lName)"
            showData(elementId: nameId, innerText: nameText)
        }
        
    }
    
    private func showData(elementId: String, innerText: String) {
        let script = "document.getElementById('\(elementId)').innerText = \"\(innerText)\""
        self.webView.evaluateJavaScript(script) { (result, error) in
            if let result = result {
                print("Label is updated with message: \(result)")
            } else if let error = error {
                print("An error occurred: \(error)")
            }
        }

    }
}

