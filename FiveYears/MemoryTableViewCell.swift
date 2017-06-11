//
//  MemoryCellTableViewCell.swift
//  FiveYears
//
//  Created by Jan B on 04.05.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit

/// A simple memory cell that displays the title of the memory and it's date
class MemoryTableViewCell: UITableViewCell {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
