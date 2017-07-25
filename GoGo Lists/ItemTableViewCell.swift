//
//  ItemTableViewCell.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/17/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
