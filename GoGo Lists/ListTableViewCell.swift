//
//  ListTableViewCell.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/13/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var listTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func disableButton() {
        
    }

}
