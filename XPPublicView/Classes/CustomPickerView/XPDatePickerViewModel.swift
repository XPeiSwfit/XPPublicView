//
//  XPDatePickerViewModel.swift
//  FaMiaoWang
//
//  Created by admin on 2020/3/19.
//  Copyright © 2020 法苗网. All rights reserved.
//

import Foundation
import ReactiveSwift
class XPDatePickerVM {
    
    var style : DateStrStyle
    init(style:DateStrStyle) {
        self.style = style
        
    }
    
    ///日历获取当前时间
   private var DateComponent :DateComponents = {
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        
        let c = NSCalendar.Unit.year.rawValue | NSCalendar.Unit.month.rawValue | NSCalendar.Unit.day.rawValue | NSCalendar.Unit.hour.rawValue | NSCalendar.Unit.minute.rawValue | NSCalendar.Unit.second.rawValue
        return calendar!.components(NSCalendar.Unit(rawValue: c) , from: Date())
    }()
    
    
    
    var dataSource : [[Int]]{
        get{
            switch style {
            case .FullTime:
                return [yearArr,monthArr,dayArr,hourArr,minuteArr,secondArr]
            case .Hms:
                return [hourArr,minuteArr,secondArr]
            case .Md:
                return [monthArr,dayArr]
            case .YM:
                return [yearArr,monthArr]
            case .yMd:
                return [yearArr,monthArr,dayArr]
            case .y:
                return [yearArr]
            }
        }
    }
    
    
    ///年份数组，当前年份上下100年
   private var yearArr : [Int]  {
        get {
            var arr = [Int]()
            
            guard let a = DateComponent.year else{
                return [0]
            }
            
            for index in a-100 ... a+100{
                arr.append(index)
            }
            
            return arr
        }
    }
    
    ///月份数组
   private var monthArr : [Int]{
        get{
            var arr = [Int]()
            for index in 1...12{
                arr.append(index)
            }
            return arr
        }
    }
    
    
    ///日源 数组数组
  private  var dayArr : [Int]{
        get{
            ///如果当前选择的月份为空，则使用当前时间的月份
            let month = selMonth.value.isEmpty ? DateComponent.month?.string : selMonth.value
            let year = selYear.value.isEmpty ? DateComponent.year?.string : selYear.value
            var lastNum : Int
            switch month {
            case "1","3","5","7","8","10","12":
                lastNum = 31
            case "4","6","9","11":
                lastNum = 30
            case "2":
                
                if isLeapyear(year: year!.int!){
                    lastNum = 29
                }else{
                    lastNum = 28
                }
               
            default:
               lastNum = 29
            }
            
            
            var arr = [Int]()
            for index in 1...lastNum{
                arr.append(index)
            }
            return arr
        }
    }
    
    ///时
   private var hourArr : [Int]{
        get{
            var arr = [Int]()
            for index in 0..<24{
                arr.append(index)
            }
            return arr
        }
    }
    
    ///分
   private var minuteArr : [Int]{
        get{
            var arr = [Int]()
            for index in 0..<60{
                arr.append(index)
            }
            return arr
        }
    }
    
    ///秒
   private var secondArr : [Int]{
        get{
            var arr = [Int]()
            for index in 0..<60{
                arr.append(index)
            }
            return arr
        }
    }
    
    ///各类型 -> 各列数据的后缀
    var titleSuffix:[String]{
           get{
               switch style {
               case .FullTime:  return ["年","月","日","时","分","秒"]
               case .Hms:       return ["时","分","秒"]
               case .yMd:       return ["年","月","日"]
               case .Md:        return ["月","日"]
               case .YM:        return ["年","月"]
               case .y:         return ["年"]
               }
           }
       }
    
    
    //选中的年月日时分秒
    var selYear = MutableProperty("")
    var selMonth = MutableProperty("")
    var selDay = MutableProperty("")
    var selHour = MutableProperty("")
    var selMinute = MutableProperty("")
    var selSecond = MutableProperty("")
    
    
}


extension XPDatePickerVM{
    
    ///返回各列宽度
    func widthForComponent() -> [CGFloat]{
        switch style {
        case .FullTime:
            let  remainingWidth = APPConfig.width - 80
            let aWidth = (remainingWidth-50) / 5
            return [80,aWidth,aWidth,aWidth,aWidth,aWidth]
        case .Md,.YM:
            return [APPConfig.width / 2,APPConfig.width / 2]
        case .Hms,.yMd:
            return [APPConfig.width / 3,APPConfig.width / 3,APPConfig.width / 3]
        case .y:
            return [APPConfig.width]
        }
    }
    
  
    
    
    /// 根据选择的列行， 根据不同状态下，给相对应的存储字段赋值， -> 返回值为所需要刷新的component列 -
    @discardableResult
    func storesSelectedDataForm(_ component:Int,row:Int) -> Int?{
        ///如果使用了无限循环， 拿余数确定数据所在行
        let r = row  % dataSource[component].count
        
        ///所选择的数据
        let data = "\(dataSource[component][r])"
        
        
        ///进行区分，赋值
        switch style {
        case .FullTime:
            let fullTimerArr = [selYear,selMonth,selDay,selHour,selMinute,selSecond]
            fullTimerArr[component].value = data
            
            ///改变了当前月份或者（年份,且选择的月份为2时）， 需要刷新“日”的数据
            if component == 1 || (component == 0 && selMonth.value == "2"){
                return 2
            }
            
        case .Hms:
            let HmsArr = [selHour, selMinute, selSecond]
            HmsArr[component].value = data
            
        case .Md:
            let MdArr = [ selMonth, selDay]
            MdArr[component].value = data
            if component == 0{
                return 1
            }
            
        case .yMd:
            let yMdArr = [ selYear, selMonth, selDay]
            
            yMdArr[component].value = data
            
            if component == 1  || (component == 0 && selMonth.value == "2") {
                return 2
            }
            
        case .YM:
            let YMArr = [ selYear, selMonth]
            YMArr[component].value = data
        
        
        case .y:
            selYear.value = data
        }
        
        
        return nil
    }
    
    
    
    
    ///各列默认选择的行数， 返回的数组下标为列,对应的成员为行
    func defaultSelRowNum() ->[Int]{
        
        ///这个是对应在没列所要展示的哪种数据
        let currentTimerArr:[Int?]
        
        switch style {
        case .FullTime:
            currentTimerArr = [DateComponent.year,
                               DateComponent.month,
                               DateComponent.day,
                               DateComponent.hour,
                               DateComponent.minute,
                               DateComponent.second]
            
        case .Hms:
            currentTimerArr = [DateComponent.hour,
                               DateComponent.minute,
                               DateComponent.second]
            
        case .Md:
            currentTimerArr = [DateComponent.month,
                               DateComponent.day]
            
        case .yMd:
            
            currentTimerArr = [DateComponent.year,
                               DateComponent.month,
                               DateComponent.day]
            
        case .YM:
            currentTimerArr = [DateComponent.year,
                               DateComponent.month]
            
        case .y:
            currentTimerArr = [DateComponent.year]
        }
        
        var selCompOrRow = [Int]()
        
        ///多重遍历，匹配与当前时间所在数据数组中的下标，即是当前列所对应的行，
        for (index,value) in currentTimerArr.enumerated(){
            for (idx,vlu) in dataSource[index].enumerated() {
                if value == vlu{
                    selCompOrRow.append(idx) //+(250*dataSource[index].count)
                    break
                }
            }
        }
        
        ///返回需要刷新的行。
        return selCompOrRow
    }
    
    
   
}


extension XPDatePickerVM{
    /// 判断是否是闰年true  闰年2月有 29天
    func isLeapyear(year:NSInteger) -> Bool{
        // 1. 能被4整除
        //        // 2. 如果能被100整除则必须也能被400整除
        //        // ==》
        //        // 1. 不能被100整除，但是能被4整除的年份是闰年
        //        // 2. 能被100整除，同时也能被400整除的年份也是闰年
        if (year % 4 == 0 && year%100 != 0) || year % 400 == 0{
            return true
        }else{
            return false
        }
        
    }
}
