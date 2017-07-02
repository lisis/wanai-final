//
//  FollowViewCell.swift
//  wanai
//
//  Created by carolina lisa on 30/6/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

protocol FollowViewCellDelegate: class {
    func userCellFollowButtonPressed(sender: FollowViewCell)
}

class FollowViewCell: UITableViewCell {
    
   
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
     weak var delegate: FollowViewCellDelegate?
    
    
    @IBAction func followButttonPressed(_ sender: UIButton) {
        
        if let delegate = delegate {
            delegate.userCellFollowButtonPressed(sender: self)
            }

    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    

}
