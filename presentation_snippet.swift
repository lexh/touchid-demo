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
