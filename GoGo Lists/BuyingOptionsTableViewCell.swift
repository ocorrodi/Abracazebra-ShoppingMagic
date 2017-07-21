//
//  BuyingOptionsTableViewCell.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/19/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

protocol BuyingOptionsTableViewCellProtocol: class {
    func sendRow(row: Int)
}

class BuyingOptionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var merchantLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var sellingPriceLabel: UILabel!
    
    var row: Int!
    
    weak var delegate: BuyingOptionsTableViewCellProtocol?
    
    @IBAction func buyButtonTapped(_ sender: Any) {
        delegate?.sendRow(row: row)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
