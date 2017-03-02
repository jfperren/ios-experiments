//
//  ViewController.swift
//  LocalizationTest
//
//  Created by Julien Perrenoud on 2/10/17.
//  Copyright © 2017 BuddyHopp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var label1: UILabel!
    @IBOutlet private weak var label2: UILabel!
    @IBOutlet private weak var label3: UILabel!
    @IBOutlet private weak var label4: UILabel!
    @IBOutlet private weak var label5: UILabel!
    @IBOutlet private weak var label6: UILabel!
    @IBOutlet private weak var label7: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.text = String(key: Strings.keyWithoutFolder)
        label2.text = String(key: Strings.common.greetings(profile: "Pradeep"))
        label3.text = String(key: Strings.chat.wrongInput(input: "9", solution: "10"))
        
        label4.text = String(key: Strings.chat.topBar.title(otherPersonName: "Pavel"))
        label5.text = String(key: Strings.chat.topBar.subtitle(date: "yesterday"))
        label6.text = String(key: Strings.registration.key.with.very.deep.hierarchy)
        label7.text = String(key: Strings.registration.incorrectPassword)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

