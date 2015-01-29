# Secret Notes: A Touch ID Demonstration for the St. Louis iOS Developers Group Meetup

## Resources
- [Working with Touch ID API in iOS 8 SDK](http://www.appcoda.com/touch-id-api-ios8) - Gabriel Theodoropoulos
- [Apple Developer Docs: LAContext](https://developer.apple.com/library/ios/documentation/LocalAuthentication/Reference/LAContext_Class/)

## My Notes From the Presentation
-------------------------------------------------------
## Intro

#### Explain format
- Live coding exercise
- Adding basic Touch ID authentication to a note taking application
- Glossing over a lot of details for brevity, want to give the basic flavor and see Swift in action

#### Talk about TouchID
- Introduced in iOS 7 for the iPhone 5s
- Laser cut sapphire crystal to prevent scratching (wouldn't work)
- Stainless steel detection ring to detect finger without pressing
- New framework added for developers with iOS 8
- Not the most secure thing in the world, but at least stored locally

#### Demo the "Secret Notes" app before adding the TouchID authentication
- Add a note
- Add a another note!
- Delete a note

## Le Code

#### MainViewController.swift

- Import Local Authentication framework
```
import LocalAuthentication
```
- Create a new function, `authenticateUser()`
- Show what error cases we need to cover by opening up
  `LocalAuthentication.framework/Headers/LAError.h`
- Add code to `authenticateUser()`
```c
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
        
      } else {
        // If authentication failed then show a message to the console with a short description.
        switch evalPolicyError!.code {
          
        case LAError.SystemCancel.rawValue:
          println("Authentication was cancelled by the system.")
          
        case LAError.UserCancel.rawValue:
          println("Authentication was cancelled by the user.")
          self.notes = [NSManagedObject]()
          
        case LAError.UserFallback.rawValue:
          println("User selected to enter a custom password.")
          
        default:
          println("Could not authenticate.")
        }
      }
      
    })
  } else {
    // The security policy can not be evaluated at all, so display a short message detailing why
    switch error!.code {
    case LAError.TouchIDNotEnrolled.rawValue:
      println("TouchID is not enrolled.")
    case LAError.PasscodeNotSet.rawValue:
      println("Passcode is not set")
    default:
      println("Catastrophic error.")
    }
  }
}
```
- Add a call to this function to the main view controller's viewDidAppear method
- Demo the functionality so far on the phone

## Hiding the Table View
- First thing we can do is hide the tableView if the user taps "Cancel" on the Touch ID UIAlertView
```c
case LAError.UserCancel.rawValue:
  println("Authentication was cancelled by the user.")
  dispatch_async(dispatch_get_main_queue()) {
    self.tableView.hidden = true
  }
```
- Make sure the table is visible when we successfully authenticate
```c
if success {
  dispatch_async(dispatch_get_main_queue()) {
    self.tableView.hidden = false
}
```
- Expand on this by adding and "Authenticate" button to the view and refactoring the code
```c
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
```
- Refactor the evalPolicyError switch statement to use this new function

## Adding the Password Fallback
- Explain the need to a fallback option, in case of thumbs being severed or something else fancy like that
- Add comments to show where our new function, `showPasswordAlert()` will be called from (In two branches of the evalPolicyError switch, and as the last statement in the canEvalPolicy else clause)
- Add the function
```c
func showPasswordAlert() {
  var passwordAlert : UIAlertView = UIAlertView(title: "Secret Notes", message: "Please type your password", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
  passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
  dispatch_async(dispatch_get_main_queue()) {
    passwordAlert.show()
  }
}
```
- Uncomment the lines and test run
- We need to add some lines which actually check the password supplied
- Click into the UIAlertViewDelegate protocol and find the method to implement
- Implement it back in the View Controller
```c
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
  let passwordAttempt:NSString? = alertView.textFieldAtIndex(0)!.text
  // There are two buttons, 0:Cancel, 1:Okay
        
  if buttonIndex == 1 {
    if passwordAttempt != nil {
      if passwordAttempt == "stlios" {
        self.hideTableView(false)
      } else {
        showPasswordAlert()
      }
    }
  } else {
    self.hideTableView(true)
  }
}
```
- Give a final demonstration