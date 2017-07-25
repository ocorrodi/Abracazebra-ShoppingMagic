//
//  FavoritesTableViewCell.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/22/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

protocol FavoritesTableViewCellProtocol: class {
    func addThisItemToAList(cell: FavoritesTableViewCell)
}


class FavoritesTableViewCell: UITableViewCell {
    
//    var row: Int!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    weak var delegate: FavoritesTableViewCellProtocol?

    @IBAction func addItemButtonTapped(_ sender: Any) {
        delegate?.addThisItemToAList(cell: self)
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
