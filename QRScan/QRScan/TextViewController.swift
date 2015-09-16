//
//  TextViewController.swift
//  QRCode
//
//  Created by Johnson Zhou on 9/15/15.
//  Copyright © 2015 Johnson Zhou. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var tField: UITextField!
    var thisText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tField.text = thisText
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("restartQRScanner", object: nil)
    }


}
