//
//  HomeViewController.swift
//  SoftgamesTest
//
//  Created by ThomasPiechula on 03/05/2022.
//

import UIKit
import WebKit
import UserNotifications

class HomeViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    lazy var viewModel = HomeViewModel()
    
    let userNotificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareViews()
        prepareStyle()
        initViewModel()
        self.requestNotificationAuthorization()
        self.userNotificationCenter.delegate = self
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
        viewModel.onNotificationUpdate = { [weak self] (title: String, body: String, timeInterval: TimeInterval) in
            self?.sendNotification(title: title, body: body, timeInterval: timeInterval)
        }
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }

    func sendNotification(title: String, body: String, timeInterval: TimeInterval) {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = title
        notificationContent.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    

}

extension HomeViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }
        
        viewModel.scriptRequest(messageBody: dict)
        
    }
    
}

extension HomeViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

