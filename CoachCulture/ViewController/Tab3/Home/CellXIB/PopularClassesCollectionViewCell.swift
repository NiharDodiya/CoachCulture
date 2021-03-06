//
//  PopularClassesCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit

class PopularClassesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgThumbnail : UIImageView!
    
    @IBOutlet weak var viwTopStatusContainer : UIView!
    @IBOutlet weak var viwTopDurationContainer : UIView!
    
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblViews : UILabel!
    @IBOutlet weak var lblClassSubTitle : UILabel!
    @IBOutlet weak var lblClassType : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viwTopDurationContainer.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
    }
    
    func setData(obj: PopularClassList) {
        
        lblTime.text = obj.duration
        lblClassSubTitle.text = obj.class_type
        lblClassType.text = obj.class_subtitle
        lblName.text = "@" + obj.username
        lblViews.text = obj.total_viewers + " Views"
        
        if obj.coach_class_type == CoachClassType.live {
            viwTopStatusContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            lblStatus.text = "LIVE"
        }
        
        if obj.coach_class_type == CoachClassType.onDemand {
            viwTopStatusContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            lblStatus.text = "ON DEMAND"
        }
        imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        imgThumbnail.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        imgThumbnail.blurImage()
    }
    
}
