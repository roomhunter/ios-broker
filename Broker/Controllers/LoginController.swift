//
//  FirstViewController.swift
//  agent
//
//  Created by to0 on 5/6/15.
//  Copyright (c) 2015 roomhunter. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let api = APIModel.sharedInstance
    @IBAction func loginButtonTapped(sender: UIButton) {
        if emailField.text.isEmpty || passwordField.text.isEmpty {
            return
        }
        loginButton.enabled = false
        activityIndicator.startAnimating()
        api.loginWith(emailField.text, password: passwordField.text, success: {
            (data: NSDictionary) in
            let token = (data["data"] as? NSDictionary)?["userToken"] as? String
            if token != nil {
                BrokerModel.sharedInstance.update(self.emailField.text, token: token!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    self.performSegueWithIdentifier("toMainAppSegue", sender: token)
                })
            }
            }, fail: {
                [unowned self] (err: NSError) in
                self.loginButton.enabled = true
                self.activityIndicator.stopAnimating()
                if err.code / 100 == 4 {
                    self.errorLabel.text = "Password or Email Invalid"
                }
                else {
                    self.errorLabel.text = "Network Error"
                }
                self.errorLabel.hidden = false
        })
    }
    @IBAction func emailChanged(sender: UITextField) {
        errorLabel.hidden = !sender.text.isEmpty && !passwordField.text.isEmpty
    }
    @IBAction func passwordChanged(sender: UITextField) {
        errorLabel.hidden = !sender.text.isEmpty && !emailField.text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        autoLogin()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func autoLogin() {
        let token = BrokerModel.sharedInstance.token
        errorLabel.hidden = false
        loginButton.enabled = false
        if token == nil {
            activityIndicator.stopAnimating()
            errorLabel.text = "Please Login"
            loginButton.enabled = true
            return
        }
        errorLabel.text = "Auto Login"
        activityIndicator.startAnimating()
        
        api.verifyToken(token!, success: {(res: NSDictionary) in
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.performSegueWithIdentifier("toMainAppSegue", sender: token)
            })
            }, fail: {(err: NSError) in
                self.activityIndicator.stopAnimating()
                self.errorLabel.text = "Please Login"
                self.loginButton.enabled = true
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let token = sender as? UIButton {
            return false
        }
        return true
    }
}

