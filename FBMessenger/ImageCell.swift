//
//  ImageCell.swift
//  FBMessenger
//
//  Created by user on 12.11.17.
//  Copyright © 2017 Saulebekov Azamat. All rights reserved.
//

import UIKit

protocol TableViewDelegateImage: class {
    func didTouchImageButtonAt(_ indexPath: IndexPath)
}

class ChatLogImageCell: UICollectionViewCell{
    
    weak var delegate: TableViewDelegateImage?
    var indexPath: IndexPath?
    
    var imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    var imageViewMark: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var attachButton: UIButton = {
        let image = UIImage(named: "delete") as UIImage?
        let button = UIButton(type: UIButtonType.custom) as UIButton
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return button
    }()
    
    func deleteAction(sender: Any){
        self.delegate?.didTouchImageButtonAt(self.indexPath!)
    }
    
    let textBubleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let date: UITextView = {
        let date = UITextView()
        date.backgroundColor = UIColor.clear
        date.font = UIFont.systemFont(ofSize: 14)
        date.text = ""
        return date
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(textBubleView)
        addSubview(date)
        addSubview(imageView)
        addSubview(imageViewMark)
        addSubview(attachButton)
        imageViewMark.isHidden = true
        //attachButton.isHidden = true
    }
}
