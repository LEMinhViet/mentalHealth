//
//  AZDetailHeaderCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 17/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AZDetailHeaderCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setExtended() {
        arrow.isHighlighted = true
        
        label.layer.masksToBounds = true
        self.roundCorners(label, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10)
    }
    
    func setCollapsed() {
        arrow.isHighlighted = false
        
        label.layer.masksToBounds = true
        self.roundCorners(label, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10)
    }
    
    func roundCorners(_ view: UIView, corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
}
