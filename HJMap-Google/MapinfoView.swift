//
//  MapinfoView.swift
//  SpotShare
//
//  Created by 김희중 on 03/03/2020.
//  Copyright © 2020 김희중. All rights reserved.
//

import UIKit
// https://mpclarkson.github.io/2015/09/03/draw-speech-bubble-swift/
class MapinfoView: UIView {

    var color:UIColor = .white

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {

        let rounding:CGFloat = rect.width * 0.04
        let angleRounding:CGFloat = rect.width * 0.02

        //Draw the main frame
        
        let shadowLayer = CAShapeLayer()
        let shadowLayer2 = CAShapeLayer()
        let bubbleFrame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 6 / 7)
        let bubblePath = UIBezierPath(roundedRect: bubbleFrame, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: rounding, height: rounding))

        //Color the bubbleFrame

        color.setStroke()
        color.setFill()
        bubblePath.stroke()
        bubblePath.fill()
        
        let leftRect = CGRect(x: 0, y: 0, width: bubbleFrame.width * 2/5, height: bubbleFrame.height)
        let shadowPathLeft = UIBezierPath(roundedRect: leftRect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: rounding, height: rounding))
        shadowPathLeft.stroke()
        
        let rightRect = CGRect(x: bubbleFrame.width * 3/5, y: 0, width: bubbleFrame.width * 2/5, height: bubbleFrame.height)
        let shadowPathRight = UIBezierPath(roundedRect: rightRect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: rounding, height: rounding))
        shadowPathRight.stroke()
        
        //Add the point
        shadowLayer.path = shadowPathLeft.cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowPath = shadowPathLeft.cgPath
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = rounding
        self.layer.insertSublayer(shadowLayer, at: 0)
        
        shadowLayer2.path = shadowPathRight.cgPath
        shadowLayer2.fillColor = UIColor.white.cgColor
        shadowLayer2.shadowColor = UIColor.darkGray.cgColor
        shadowLayer2.shadowPath = shadowPathRight.cgPath
        shadowLayer2.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer2.shadowOpacity = 0.3
        shadowLayer2.shadowRadius = rounding
        self.layer.insertSublayer(shadowLayer2, at: 0)
        
        

        guard let context = UIGraphicsGetCurrentContext() else {return}
        let offset = CGSize(width: 0, height: 1)
        context.setShadow(offset: offset, blur: angleRounding)
        
        
        //Start the line

        context.beginPath()
        context.move(to: CGPoint(x: bubbleFrame.minX + bubbleFrame.width * 2/5, y: bubbleFrame.maxY))

        //Draw a rounded point
        
        context.addArc(tangent1End: CGPoint(x: rect.maxX * 1/2, y: rect.maxY), tangent2End: CGPoint(x: bubbleFrame.maxX, y: bubbleFrame.minY), radius: angleRounding)

        //Close the line

        context.addLine(to: CGPoint(x: bubbleFrame.minX + bubbleFrame.width * 3/5, y: bubbleFrame.maxY))
        context.closePath()

        //fill the color

        context.fillPath()
        
        
    }
}
