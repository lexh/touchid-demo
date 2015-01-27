//
//  DetailViewController.swift
//  Secret Notes
//
//  Created by Lex Herbert on 1/27/15.
//  Copyright (c) 2015 Paradigm New Media Group. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet var content: UITextView!
    
    var note:NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
    }
    
    override func viewWillAppear(animated: Bool) {
        title        = note!.valueForKey("title")   as? String
        content.text = note!.valueForKey("content") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
