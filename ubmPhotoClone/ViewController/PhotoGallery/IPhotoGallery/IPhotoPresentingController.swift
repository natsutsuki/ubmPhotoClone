//
//  IPhotoPresentingController.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/15.
//  Copyright © 2019 c.c. All rights reserved.
//

import Foundation
import UIKit

/// 弹出层协议
protocol IPhotoPresentingController where Self:UIViewController
{
    /// 获取indexPath 对应的frame (对应window的)
    func getFrameInWindow(for indexPath:IndexPath) -> CGRect
    
}
