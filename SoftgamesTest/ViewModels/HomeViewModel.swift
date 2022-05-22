//
//  HomeViewModel.swift
//  SoftgamesTest
//
//  Created by ThomasPiechula on 21/05/2022.
//

import Foundation

class HomeViewModel {
    
    private let nameId: String = "namevalue"
    private let birthdayId: String = "birthdayvalue"
    
    var onScriptUpdate: ((_ script: String) -> Void)?
    
    func scriptRequest(messageBody: [String : AnyObject]) {
        if let bdate = messageBody["bdate"] as? String {
            DispatchQueue.global().async { [self] in
                sleep(5)
                DispatchQueue.main.async { [self] in
                    let script = "document.getElementById('\(birthdayId)').innerText = \"\(bdate)\""
                    onScriptUpdate?(script)
                }
            }
        } else if let fName = messageBody["fname"] as? String, let lName = messageBody["lname"] as? String{
            let nameText = "\(fName) \(lName)"
            let script = "document.getElementById('\(nameId)').innerText = \"\(nameText)\""
            onScriptUpdate?(script)
        }
    }
    
}
