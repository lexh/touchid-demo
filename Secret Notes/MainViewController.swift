//
//  ViewController.swift
//  Secret Notes
//
//  Created by Lex Herbert on 1/26/15.
//  Copyright (c) 2015 Paradigm New Media Group. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet var authenticateButton: UIButton!
    @IBAction func authenticateButtonPressed(sender: AnyObject) {
        
        authenticateUser()
    }
    @IBOutlet weak var tableView: UITableView!
    var notes = [NSManagedObject]()
    
    func hideTableView(value:Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.hidden = value
            self.navigationController!.navigationBar.hidden = value
            self.authenticateButton.hidden = !value
        }
    }
    
    func showPasswordAlert() {
        var passwordAlert:UIAlertView = UIAlertView(title: "Secret Notes", message: "Please enter password", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
        dispatch_async(dispatch_get_main_queue()) {
            passwordAlert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let attemptedPassword = alertView.textFieldAtIndex(0)!.text
        
        if buttonIndex == 1 {
            if attemptedPassword == "stlios" {
                hideTableView(false)
            }
        }
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error:NSError?
        let reasonString:NSString = "You need to authenticate before accessing your secret notes"
        
        if(context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success:Bool, evalPolicyError:NSError?) -> Void in
                if success {
                    self.hideTableView(false)
                    println("You did it!")
                    
                } else {
                    switch evalPolicyError!.code {
                    case LAError.UserCancel.rawValue:
                        println("User pressed cancel button")
                        self.hideTableView(true)
                    case LAError.UserFallback.rawValue:
                        println("User chose to enter password")
                        self.showPasswordAlert()
                    default:
                        println("Could not authenticate...")
                    }
                }
            })
            
        } else {
            switch error!.code {
            default:
                println("Catastrophic error!!!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        title = "Secret Notes"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate:AppDelegate               = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest:NSFetchRequest           = NSFetchRequest(entityName: "SecretNote")
        
        var error:NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            notes = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        self.tableView.reloadData()
        
        hideTableView(true)
        authenticateUser()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()! as NSIndexPath
            let detailVC  = segue.destinationViewController as DetailViewController
            detailVC.note = notes[indexPath.row]
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let note:NSManagedObject = notes[indexPath.row] as NSManagedObject
        
        if let title = note.valueForKey("title") as? String {
            cell.textLabel!.text = title
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate:AppDelegate               = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let noteToRemove = notes[indexPath.row] as NSManagedObject
            managedContext.deleteObject(noteToRemove)
            
            var error:NSError?
            if(!managedContext.save(&error)) {
                println("Could not save: \(error)")
            }
            
            notes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

