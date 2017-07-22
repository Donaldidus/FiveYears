//
//  ParallaxHeaderTableView.swift
//  FiveYears
//
//  Created by Jan B on 22.07.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit

class ParallaxHeaderTableView: UITableView, UITableViewDelegate {

    var parallaxHeaderView: UIView! {
        didSet{
            setupViews()
        }
    }
    
    var headerLayer: CAShapeLayer!
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    /// Setup table view and header view.
    private func setupViews() {
        delegate = self
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        backgroundColor = BACKGROUND_COLOR
        separatorStyle = .none
        
        headerLayer = CAShapeLayer()
        headerLayer.fillColor = UIColor.black.cgColor
        parallaxHeaderView.layer.mask = headerLayer
        
        tableHeaderView = nil
        addSubview(parallaxHeaderView)
        
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = 50
        
        let insetHeight = bounds.height * SLIDESHOW_TEXT_RATIO
        contentInset = UIEdgeInsets(top: insetHeight, left: 0, bottom: 0, right: 0)
        contentOffset = CGPoint(x: 0, y: -insetHeight)
        
        updateHeaderView()
    }
    
    /// Adjust upon scrolling.
    private func updateHeaderView() {
        let headerHeight = bounds.height * SLIDESHOW_TEXT_RATIO
        var headerFrame = CGRect(x: 0, y: 0, width: bounds.width, height: headerHeight)
        
        if contentOffset.y < headerHeight {
            headerFrame.origin.y = contentOffset.y
            headerFrame.size.height = -contentOffset.y
        }
        
        parallaxHeaderView.frame = headerFrame
        
        let leftCtrlPoint = CGPoint(x: parallaxHeaderView.frame.width / 5, y: parallaxHeaderView.frame.height)
        let rightCtrlPoint = CGPoint(x: parallaxHeaderView.frame.width * 4 / 5, y: parallaxHeaderView.frame.height)

        headerLayer.path = getHeaderShapePath(leftControlPoint: leftCtrlPoint, rightControlPoint: rightCtrlPoint).cgPath
    }
    
    /// Returns the path for the header layer.
    ///
    /// - Parameters:
    ///   - leftControlPoint: left point determining how the curve at the bottom is bend
    ///   - rightControlPoint: right point determining how the curve at the bottom is bend
    /// - Returns: UIBezierPath for the headerLayer.
    private func getHeaderShapePath(leftControlPoint: CGPoint, rightControlPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        let inbound = parallaxHeaderView.frame.height * HEADER_LAYER_CURVE_BENDING
        path.addLine(to: CGPoint(x: parallaxHeaderView.frame.width, y: 0))
        path.addLine(to: CGPoint(x: parallaxHeaderView.frame.width, y: parallaxHeaderView.frame.height - inbound))
        path.addCurve(to: CGPoint(x: 0, y: parallaxHeaderView.frame.height - inbound), controlPoint1: rightControlPoint, controlPoint2: leftControlPoint)
        
        return path
    }
    

}
