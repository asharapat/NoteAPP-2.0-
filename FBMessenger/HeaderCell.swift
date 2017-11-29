//
//  HeaderCell.swift
//  FBMessenger
//
//  Created by user on 12.11.17.
//  Copyright © 2017 Saulebekov Azamat. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionReusableView {
    
    let textLabel: UITextView = {
        let label = UITextView()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = ""
        label.isEditable = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        addSubview(textLabel)
    }
}
