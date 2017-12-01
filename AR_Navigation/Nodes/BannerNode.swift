//
//  BannerNode.swift
//  TestNodes
//
//  Created by Gleb Radchenko on 11/29/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

class BannerNode: SCNNode {
    
    static var defaultWidth: CGFloat = 400
    static var defaultFontSize: CGFloat {
        return (defaultWidth * 0.3 + defaultWidth / 12) / 8
    }
    
    override init() {
        super.init()
        
        geometry = SCNShape.bannerShape(width: BannerNode.defaultWidth)
        applyScale(1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func applyScale(_ scale: Float) {
        let scale = Float(1 / BannerNode.defaultWidth) * scale
        transform = SCNMatrix4Scale(transform, scale, scale, scale)
    }
    
    func updateInfo(_ text: String, backgroundColor: UIColor) {
        updateContentLayer(text: text, backgroundColor: backgroundColor)
    }
    
    func updateInfo(_ text: NSAttributedString, backgroundColor: UIColor) {
        updateContentLayer(text: text, backgroundColor: backgroundColor)
    }
    
    fileprivate func updateContentLayer(text: Any, backgroundColor: UIColor) {
        let layer = CALayer()
        let pointerHeight = BannerNode.defaultWidth / 12
        let rectHeight = BannerNode.defaultWidth * 0.3
        
        layer.frame = CGRect(x: 0, y: 0, width: BannerNode.defaultWidth, height: rectHeight + pointerHeight)
        layer.backgroundColor = backgroundColor.cgColor
        
        let textLayer = CATextLayer()
        textLayer.frame = layer.bounds
        textLayer.fontSize = BannerNode.defaultFontSize
        textLayer.string = text
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.truncationMode = kCATruncationEnd
        textLayer.isWrapped = true
        layer.addSublayer(textLayer)
        
        geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        geometry?.firstMaterial?.diffuse.contents = layer
    }
    
}

extension SCNShape {
    static func bannerShape(width: CGFloat) -> SCNShape {
        let shape = SCNShape()
        let height = width * 0.3
        
        let contentRect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        let rectPath = UIBezierPath(roundedRect: contentRect, cornerRadius: contentRect.width / 20)
        
        let pointerPath = UIBezierPath()
        
        let poinerWidth = contentRect.width / 4
        let pointerHeight = poinerWidth / 3
        
        let bottomCenterPoint = contentRect.origin.translated(contentRect.width / 2, 0)
        pointerPath.move(to: bottomCenterPoint.translated(-poinerWidth / 2, 0))
        
        pointerPath.addQuadCurve(to: bottomCenterPoint.translated(0, -pointerHeight),
                                 controlPoint: bottomCenterPoint.translated(-poinerWidth / 8, -pointerHeight / 4))
        
        pointerPath.addQuadCurve(to: bottomCenterPoint.translated(poinerWidth / 2, 0),
                                 controlPoint: bottomCenterPoint.translated(poinerWidth / 8, -pointerHeight / 4))
        pointerPath.close()
        
        rectPath.append(pointerPath)
        
        shape.path = rectPath
        
        return shape
    }
}

