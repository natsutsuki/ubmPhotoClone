//
//  GridViewController+algorithm.swift
//  Photo Transitioning
//
//  Created by c.c on 2019/6/14.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit

extension GridViewController
{
    /// 获取itemSize (算法)用网格分割时，获取正好能整分，且满足一行数量要求的size
    func getGridItemSize(inBoundingSize size: CGSize) -> (itemSize: CGSize, lineSpacing: Int) {
        var length = 0
        let w = Int(size.width)
        var spacing = 1
        
        // 问，在宽度x的空间里，放置正方形图片
        // 求最小的间隙可为1...3，一排最多可排4...8个项目
        for targetSpace in 1...3 {
            for itemInRowCount in 4...8 {
                // (4 - 1) * 1
                // 总间隙
                let totalSpace = (itemInRowCount-1) * targetSpace
                
                // 剩下的宽度
                let remaindWidth = w - totalSpace
                
                // 是否可以被整除，意味着是否可以刚好放置item
                let isDivisible = remaindWidth % itemInRowCount == 0
                
                // 剩下的宽度 / itemInRowCount 每个item的宽度 > 上次计算
                // item的宽度，越大越好，意味着每行被切割的越少
                let isThisBiggerThanBefore = (remaindWidth/itemInRowCount) > length
                
                if isDivisible && isThisBiggerThanBefore {
                    length = remaindWidth/itemInRowCount
                    spacing = targetSpace
                }
            }
        }
        
        return (CGSize(width: length, height: length), spacing)
    }
    
}
