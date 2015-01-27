//
//  ViewController.swift
//  Secret Notes
//
//  Created by Lex Herbert on 1/26/15.
//  Copyright (c) 2015 Paradigm New Media Group. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var notes = [NSManagedObject]()
    
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

