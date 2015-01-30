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
    
    @IBAction func authneticateButtonPressed(sender: AnyObject) {
        authorizeUser()
        
    }
    
    func showPasswordAlert() {
        var passwordAlert:UIAlertView = UIAlertView(title: "Secret Notes", message: "Please Enter PAssword", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
        
        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
        dispatch_async(dispatch_get_main_queue()) {
            passwordAlert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let passwordAttempt:String = alertView.textFieldAtIndex(0)!.text
        
        if buttonIndex == 1 {
            if passwordAttempt == "stlios" {
                hideTableView(false)
            } else {
                hideTableView(true)
            }
        }
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
    
    func authorizeUser() {
       let context = LAContext()
        
        var error:NSError?
        
        let reasonString = "Please authenticate."
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {(success:Bool, evalPolicyError:NSError?)-> Void in
                if success {
                    self.hideTableView(false)
                    
                } else {
                    // If authentication failed then show a message to the console with a short description.
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        println("Authentication was cancelled by the system.")
                        self.hideTableView(true)
                        
                    case LAError.UserCancel.rawValue:
                        println("Authentication was cancelled by the user.")
                        self.showPasswordAlert()
                        self.hideTableView(true)
                        
                    case LAError.UserFallback.rawValue:
                        println("User selected to enter a custom password.")
                        
                    default:
                        println("Could not authenticate.")
                        self.hideTableView(true)
                    }
                }
            })
        } else {
            // The security policy can not be evaluated at all, so display a short message detailing why
            println(error!.localizedDescription)
            
            switch error!.code {
            case LAError.TouchIDNotEnrolled.rawValue:
                println("TouchID is not enrolled.")
            case LAError.PasscodeNotSet.rawValue:
                println("Passcode is not set")
            default:
                println("Something unexpected happened...")
            }
            
            showPasswordAlert()
            hideTableView(true)
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
        
        hideTableView(true)
        authorizeUser()
        self.tableView.reloadData()
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
    
    func sampl() {
        dispatch_async(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) {
            <#code somethin#>
        }typedef <#existing#> <#new#>;
    }
    
}

