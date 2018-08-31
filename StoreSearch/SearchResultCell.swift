//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by shkurta on 28/08/2018.
//  Copyright © 2018 Ardita. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    //MARK: -IBOutlets
    @IBOutlet weak var artWorkImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
