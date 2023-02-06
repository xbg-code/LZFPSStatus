//
//  LZFPSStatus.swift
//  Smart
//
//  Created by ZYF MacMini on 2022/11/24.
//


import UIKit
import JKAlertX

// 宏定义当前屏幕的宽度
public let kScreenWidth =  UIScreen.main.bounds.width
// 宏定义当前屏幕的高度
public let kScreenHeight = UIScreen.main.bounds.height

public var kStatusBarH: CGFloat {
    get {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
}

public class LZFPSStatus: NSObject {
    
    public static let shared = LZFPSStatus()
    
    lazy var fpsLabel: UILabel = {
        let fpsLabel = UILabel(frame: CGRect(x: 10, y: kStatusBarH-10, width: kScreenWidth-20, height: 15))
        fpsLabel.font = UIFont.boldSystemFont(ofSize: 10)
        fpsLabel.numberOfLines = 2
        fpsLabel.textColor = UIColor.gray
        fpsLabel.backgroundColor = UIColor.clear
        fpsLabel.textAlignment = .center
        fpsLabel.layer.zPosition = .greatestFiniteMagnitude
        return fpsLabel
    }()
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate var lastTime: TimeInterval = 0
    fileprivate var count: Int = 0
    fileprivate var handler: ((Int) -> ())?
    
    var version: String {
        get {
            //获取 Version  版本号
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
            //获取 Build  构建版本号
            let Build = Bundle.main.infoDictionary?["CFBundleVersion"]
            let ambient = "测"
            return "\(version!)(\(Build!)\(ambient))"
        }
    }
    
    
    fileprivate override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (_) in
            self.displayLink?.isPaused = false
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: self, queue: nil) { (_) in
            self.displayLink?.isPaused = true
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkTick(_:)))
        displayLink?.isPaused = true
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    @objc fileprivate func displayLinkTick(_ displayLink: CADisplayLink) {
        
        if lastTime == 0 {
            lastTime = displayLink.timestamp
        } else if displayLink.timestamp - lastTime > 1.00 {
            let fps = "\(count)"
            
            let progress: CGFloat = CGFloat(count) / 60.0
            let color = UIColor(hue: 0.27 * (progress - 0.2), saturation: 1, brightness: 0.9, alpha: 1)
            let text = NSMutableAttributedString(string: fps, attributes: [.foregroundColor: color])
            text.append(NSAttributedString(string: "  \(version)"))
            fpsLabel.attributedText = text
            lastTime = displayLink.timestamp
            if handler != nil {
                handler!(count)
            }
            count = 0
        } else {
            count += 1
        }
    }
    
    public func close() {
        displayLink?.isPaused = true
        handler = nil
        fpsLabel.removeFromSuperview()
    }
    
    public func open(_ handler: ((_ fpsValue: NSInteger) -> ())? = nil) { // 根据接口地址环境
//        if LZNetworkTool.kBaseUrl == kReleaseBaseUrl {
//            return
//        }
//        self.handler = handler
//        UIWindow.keyWindow?.addSubview(fpsLabel)
//        displayLink?.isPaused = false
//        print("have opened")
    }
    
    deinit {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: .common)
    }
}

