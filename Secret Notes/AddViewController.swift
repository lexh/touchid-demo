//
//  AddViewController.swift
//  Secret Notes
//
//  Created by Lex Herbert on 1/26/15.
//  Copyright (c) 2015 Paradigm New Media Group. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController {
    
    @IBOutlet var noteContent: UITextView!
    @IBOutlet var noteTitle: UITextField!
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        saveNote(noteTitle.text, content: noteContent.text)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add a Secret Note"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveNote(title:String, content:String) {
        let appDelegate:AppDelegate               = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("SecretNote", inManagedObjectContext: managedContext)
        let note   = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        note.setValue(title,   forKey: "title")
        note.setValue(content, forKey: "content")
        
        var error:NSError?
        if(!managedContext.save(&error)) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        if error != nil {
            println(error!.description)
        }
        
    }
    
}
