//
//  TextCollectionViewCell.swift
//  TestCollectionView
//
//  Created by Jan B on 15.07.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = BACKGROUND_COLOR
        textView.textColor = TEXT_COLOR
        textView.font = TEXT_FONT
        textView.textAlignment = .justified
        textView.textContainerInset = TEXTVIEW_CONTAINER_INSETS
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(textView)
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
}
