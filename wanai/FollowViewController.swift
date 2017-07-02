//
//  SecondViewController.swift
//  wanai
//
//  Created by carolina lisa on 27/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class FollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FollowViewCellDelegate  {
    
    
    var users = [User]()
    var db: DatabaseReference!
    var filterdUsers = [User]()
    
    
    @IBAction func logoutButtonClicked(_ sender: UIBarButtonItem) {
        
        FBSDKLoginManager().logOut()
        
        UserDefaults.standard.removeObject(forKey: "userSigned")
        UserDefaults.standard.synchronize()
        
        let signUp = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = signUp
        delegate.rememberLogin()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followTableView.dataSource = self
        followTableView.delegate = self
        db = Database.database().reference()
        retrieveUsers()
        
    }
    
    @IBOutlet weak var followTableView: UITableView!
    

    
    func retrieveUsers() {
        db.child("users").queryOrderedByKey().observe(.value, with: { snapshot in
            if let dbUsers = snapshot.value as? [String: [String: String]],
                let userUid = Auth.auth().currentUser?.uid {
                
                print("Logged user " + userUid)
                
                self.db.child("follows").queryOrderedByKey().queryEqual(toValue: userUid).observe(.value, with: { snapshot in
                    
                    self.users.removeAll()
                    for eachUser in dbUsers {
                        if (eachUser.key != userUid) {
                            print("Listed user "+eachUser.key)
                            let user = User()
                            user.uid = eachUser.key
                            user.username = eachUser.value["name"]
                            
                            for case let childSnapshot as DataSnapshot in snapshot.children {
                                print("Child: ")
                                print(childSnapshot)
                                if childSnapshot.key == userUid {
                                    print("Child Value: ")
                                    print(childSnapshot.value)
                                    if let following = childSnapshot.value as? [String: [String: String]]{
                                        print(following)
                                        if  (following[eachUser.key] != nil) {
                                            user.follow = true
                                        }
                                    }
                                }
                            }
                            self.users.append(user)
                        }
                    }
                    self.followTableView.reloadData()
                })
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveUsers()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }

   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! FollowViewCell
        
        var user = users[indexPath.row]
        
        cell.nameLabel.text = user.username
        cell.selectionStyle = .none
        cell.delegate = self
        if user.follow {
            cell.followButton.setTitle("Unfollow", for: .normal)
        } else {
            cell.followButton.setTitle("Follow", for: .normal)
        }
        
        return cell
    }
    
    func userCellFollowButtonPressed(sender: FollowViewCell) {
        if let indexPath = followTableView.indexPath(for: sender) {
            let user = users[indexPath.row]
            user.follow = !user.follow
            
            //save the follow info db
            if let userUid = Auth.auth().currentUser?.uid,
                let followedUser = user.uid {
                
                if user.follow == true {
                    let followItem = ["uid": user.uid!]
                    
                    let childUpdates = ["/follows/\(userUid)/\(followedUser)": followItem,
                                        "/followedBy/\(followedUser)/\(userUid)/": ["uid": userUid]] as [String : Any]
                    self.db.updateChildValues(childUpdates)
                    
                    
                   
                } else {
                    self.db.child("follows").child(userUid).child(followedUser).removeValue()
                    self.db.child("followedBy").child(followedUser).child(userUid).removeValue()
                    
                }
            }
            followTableView.reloadData()
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    }
