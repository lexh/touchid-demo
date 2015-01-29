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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var authenticateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var notes = [NSManagedObject]()
    
    @IBAction func authenticateButtonPressed(sender: AnyObject) {
        authenticateUser()
    }
    
    func hideTableView(value:Bool) {
        dispatch_async(dispatch_get_main_queue()) {
        self.tableView.hidden = value
        self.navigationController!.navigationBar.hidden = value
        self.authenticateButton.hidden = !value
    }
        
    }
    
    func authenticateUser() {
        // Get the local authentication context
        let context:LAContext = LAContext()
        
        // Declare an NSError variable
        var error:NSError? = nil
        
        // Set the reason string that will appear on the authentication alert
        let reasonString = "Authentication required to view these top secret notes!"
        
        // Check if the device can evaluate the policy
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
                        self.hideTableView(true)
                        
                    case LAError.UserFallback.rawValue:
                        println("User selected to enter a custom password.")
                        
                    default:
                        println("Could not authenticate.")
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

