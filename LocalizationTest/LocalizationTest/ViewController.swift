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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.text = String(key: Strings.common.ok)
        label2.text = String(key: Strings.other.giuseppe(beautiful: "Hello"))
        label3.text = String(key: Strings.registration.)
        
//        String(key: String.Key.chat.wrongInput(input: "Hello", solution: "Solution"))
//        String(key: String.Key.registration.incorrectPassword)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

