//
//  SignUpInViewController.swift
//  ParseTutorial
//
//  Created by Ian Bradbury on 10/02/2015.
//  Copyright (c) 2015 bizzi-body. All rights reserved.
//

import UIKit

class SignUpInViewController: UIViewController {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var message: UILabel!
	@IBOutlet weak var emailAddress: UITextField!
	@IBOutlet weak var password: UITextField!

	@IBAction func signUp(sender: AnyObject) {
		
		// Build the terms and conditions alert
		let alertController = UIAlertController(title: "Agree to terms and conditions",
			message: "Click I AGREE to signal that you agree to the End User Licence Agreement.",
			preferredStyle: UIAlertControllerStyle.Alert
		)
		alertController.addAction(UIAlertAction(title: "I AGREE",
			style: UIAlertActionStyle.Default,
			handler: { alertController in self.processSignUp()})
		)
		alertController.addAction(UIAlertAction(title: "I do NOT agree",
			style: UIAlertActionStyle.Default,
			handler: nil)
		)
		
		// Display alert
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	@IBAction func signIn(sender: AnyObject) {
		
		activityIndicator.hidden = false
		activityIndicator.startAnimating()
		
		// Clear an previous sign in message
		message.text = ""
		
		var userEmailAddress = emailAddress.text
		userEmailAddress = userEmailAddress.lowercaseString
		
		var userPassword = password.text
		
		PFUser.logInWithUsernameInBackground(userEmailAddress, password:userPassword) {
			(user: PFUser?, error: NSError?) -> Void in

			// If there is a user
			if let user = user {
				
				if user["emailVerified"] as! Bool == true {
					dispatch_async(dispatch_get_main_queue()) {
						self.performSegueWithIdentifier(
							"signInToNavigation",
							sender: self
						)
					}
				} else {
					// User needs to verify email address before continuing
					let alertController = UIAlertController(
						title: "Email address verification",
						message: "We have sent you an email that contains a link - you must click this link before you can continue.",
						preferredStyle: UIAlertControllerStyle.Alert
					)
					alertController.addAction(UIAlertAction(title: "OKAY",
						style: UIAlertActionStyle.Default,
						handler: { alertController in self.processSignOut()})
					)
					// Display alert
					self.presentViewController(
						alertController,
						animated: true,
						completion: nil
					)
				}
			} else {
				
				// User authentication failed, present message to the user
				self.message.text = "Sign In failed.  The email address and password combination were not recognised."
				
				// Remove the activity indicator
				self.activityIndicator.hidden = true
				self.activityIndicator.stopAnimating()
			}
		}
	}
	

	// Main viewDidLoad method
	override func viewDidLoad() {
		super.viewDidLoad()
		
		activityIndicator.hidden = true
		activityIndicator.hidesWhenStopped = true
	}

	
	// Sign the current user OUT of the app
	func processSignOut() {
		
		// // Sign out
		PFUser.logOut()
		
		// Display sign in / up view controller
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewControllerWithIdentifier("SignUpInViewController") as! UIViewController
		self.presentViewController(vc, animated: true, completion: nil)
	}

	
	// Sign UP method that is called when once a user has accepted the terms and conditions
	func processSignUp() {
		
		var userEmailAddress = emailAddress.text
		var userPassword = password.text
		
		// Ensure username is lowercase
		userEmailAddress = userEmailAddress.lowercaseString
		
		// Add email address validation
		
		// Start activity indicator
		activityIndicator.hidden = false
		activityIndicator.startAnimating()
		
		// Create the user
		var user = PFUser()
		user.username = userEmailAddress
		user.password = userPassword
		user.email = userEmailAddress
		
		user.signUpInBackgroundWithBlock {
			(succeeded: Bool, error: NSError?) -> Void in
			if error == nil {
				
				// User needs to verify email address before continuing
				let alertController = UIAlertController(title: "Email address verification",
					message: "We have sent you an email that contains a link - you must click this link before you can continue.",
					preferredStyle: UIAlertControllerStyle.Alert
				)
				alertController.addAction(UIAlertAction(title: "OKAY",
					style: UIAlertActionStyle.Default,
					handler: { alertController in self.processSignOut()})
				)
				// Display alert
				self.presentViewController(alertController, animated: true, completion: nil)
				
			} else {
				
				self.activityIndicator.stopAnimating()
				
				if let message: AnyObject = error!.userInfo!["error"] {
					self.message.text = "\(message)"
				}				
			}
		}
	}
}
