//
//  CustomDatePickerView.swift
//  FaMiaoWang
//
//  Created by admin on 2020/3/18.
//  Copyright © 2020 法苗网. All rights reserved.
//

import UIKit

protocol XPDatePickerSelectDelegate {
    func selectFinishBackFrom(pickerView:XPCustomDatePickerView,year:String?,month:String?,day:String?,hour:String?,midel:String?,second:String?)
}

class XPCustomDatePickerView: UIView {
    
    ///展示时间选择器
    public func showView(){
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        UIView.animate(withDuration: 0.00001, animations: {
            self.frame.origin.y = 0
        }, completion: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let funcationView = XPPickerHeadView()
    
    
    private lazy var datePicker : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        return pickerView
    }()
    
    private let delegate : XPDatePickerSelectDelegate  //选择协议
    private let vm : XPDatePickerVM  //数据模型
    
    private let style : DateStrStyle //时间类型
    
    init(delegate:XPDatePickerSelectDelegate,dateStyle:DateStrStyle) {
        style = dateStyle
        self.delegate = delegate
        vm = XPDatePickerVM(style: dateStyle)
        
        super.init(frame: CGRect.init(x: 0, y: APPConfig.height, width: APPConfig.width, height: APPConfig.height))
        backgroundColor = UIColor.black.alpha(0.3)
        
        setUI()
        addObservers()
    }
    
    private func setUI(){
        
        addSubview(datePicker)
        addSubview(funcationView)
        
        
        datePicker.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.height.equalToSuperview().multipliedBy(0.3)
        }
        
        funcationView.snp.makeConstraints { (m) in
            m.bottom.equalTo(datePicker.snp.top)
            m.left.right.equalToSuperview()
            m.height.equalTo(55)
        }
        
        funcationView.titleLabel.text = "时间选择"
        
    }
    
    
    private func addObservers(){
        
        funcationView.confimBtn.rectiveClick {[unowned self] _ in
            self.delegate.selectFinishBackFrom(pickerView: self,
                                               year: self.vm.selYear.value,
                                               month: self.vm.selMonth.value,
                                               day: self.vm.selDay.value,
                                               hour: self.vm.selHour.value,
                                               midel: self.vm.selMinute.value,
                                               second: self.vm.selSecond.value)
            self.windowCloseView()
        }
        
        
        self.addTapGesture {[unowned self] in  self.windowCloseView()  }
        
        
        
        ///首次默认选择
        for (component,row) in vm.defaultSelRowNum().enumerated(){
            pickerView(datePicker, didSelectRow: row, inComponent: component)
            
            datePicker.selectRow(row, inComponent: component, animated: true)
        }
        
        
    }
    
}


extension XPCustomDatePickerView:UIPickerViewDataSource{
    /// 多少列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return vm.dataSource.count
        
    }
    
    /// 列中多少行
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ///暂没有做无限循环，还得优化，倍数行可实现
        return vm.dataSource[component].count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleLabel = view as? UILabel
        if titleLabel == nil{
            titleLabel = UILabel()
            titleLabel?.textAlignment = .center
            titleLabel?.font = UIFont.systemFont(ofSize: 14)
            titleLabel?.textColor = UIColor.R333333
        }
        
        let componentData = vm.dataSource[component]
        
        let title = componentData[row % componentData.count]
        
        titleLabel?.text = "\(title)\(vm.titleSuffix[component])"
        return titleLabel!
    }
    
}

extension XPCustomDatePickerView:UIPickerViewDelegate{
    
    ///列宽
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return vm.widthForComponent()[component]
    }
    
    ///行高
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let componentNum = vm.storesSelectedDataForm(component, row: row){
            pickerView.reloadComponent(componentNum)
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        for subView in pickerView.subviews {
            if subView.height < 1{
                subView.backgroundColor = UIColor.lightGray
                subView.height = 0.5
            }
        }
        
        return nil
        
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //
    //    }
    
    
}



