//
//  ViewController.swift
//  CircleAnimation
//
//  Created by Sarah Mohammed  on 14/4/19.
//  Copyright © 2019 sarita designs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    
    let backgroundColor = UIColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 1.0)
    let outlineStrokeColor = UIColor(red: 0.92, green: 0.17, blue: 0.44, alpha: 1.0)
    let trackStrokeColor = UIColor(red: 0.22, green: 0.10, blue: 0.19, alpha: 1.0)
    let pulsatingFillColor = UIColor(red: 0.34, green: 0.12, blue: 0.25, alpha: 1.0)
    
    var shapeLayer:CAShapeLayer!
    
    var pulsatingLayer: CAShapeLayer!
    
    // programatically creating the UI Label
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    // the statusbar (top) isnt visible with the dark background -- update to lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // when you exit app, the animations end; this handles re-entry
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    // creating the circles
    private func createCircleShapeLayer(strokeColor:UIColor, fillColor:UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.lineCap = CAShapeLayerLineCap.round
        layer.fillColor = fillColor.cgColor
        layer.position = view.center
        return layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        view.backgroundColor = backgroundColor
        
        setupCircleLayers()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleTap)))
        
        setupPercentageLabel()
        
    }
    
    private func setupCircleLayers() {
        // pulsating layer
        pulsatingLayer = createCircleShapeLayer(strokeColor:UIColor.clear,fillColor:pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        // create track layer
        let trackLayer = createCircleShapeLayer(strokeColor: trackStrokeColor, fillColor: backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        // create shape layer
        shapeLayer = createCircleShapeLayer(strokeColor: outlineStrokeColor, fillColor: UIColor.clear
        )
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        view.layer.addSublayer(shapeLayer)
    }
    
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0,y: 0,width: 100,height: 100)
        percentageLabel.center = view.center
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale") // transform.scale must be keyword
        animation.toValue = 1.3 // scale it to x% of original
        animation.duration = 0.8 // time to scale
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        
        pulsatingLayer.add(animation, forKey: "pulsing") // forKey ?
    }
    
    let urlString = "https://unsplash.com/photos/dqy5wtCdS4U/download?force=true"
    
    private func beginDownloadingFile() {
        print("Attempting to download file")
        
        shapeLayer.strokeEnd = 0
        
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        // if we didnt care about monitoring the progress, we would use URLSession.shared.dataTask
        
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten)/CGFloat(totalBytesExpectedToWrite)
        
        // since we are using the operationQueue in the background for downloading, when we want to update the UI we need to go back to main thread with DispatchQueue
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage*100))%"
            self.shapeLayer.strokeEnd = percentage
        }
        print(percentage)
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading file")
    }
    
    // this was used before downloading file functionality 
//    fileprivate func animateCircle() {
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd") // refers to strokeEnd variable
//        basicAnimation.toValue = 1 // end % of circle colored
//        basicAnimation.duration = 2
//        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//        basicAnimation.isRemovedOnCompletion = false
//
//        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
//    }
//
    @objc private func handleTap() {
        print("Attempting to animate")
        beginDownloadingFile()
        
//        animateCircle()
    }


}

