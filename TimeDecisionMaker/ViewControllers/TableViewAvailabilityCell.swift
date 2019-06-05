//
//  TableViewAvailabilityCell.swift
//  TimeDecisionMaker
//
//  Created by Dmitry Reshetnik on 6/5/19.
//

import UIKit

class TableViewAvailabilityCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var avalabilityLabel: UILabel!
    
}
