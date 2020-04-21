//
//  XPNonLinkagePickerView.swift
//  FaMiaoWang
//
//  Created by admin on 2020/3/30.
//  Copyright © 2020 法苗网. All rights reserved.
//

import UIKit
protocol XPNonLinkageSelectDelegate {
    
    /// 非联动选择器,
    /// - Parameter result: 被选中的数据,下标为列
    func selectFinishResult(pickerView:UIView, _ result:[String])
}

/// 非联动-自定义数据选择器
class XPNonLinkagePickerView: UIView {
    
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
    private lazy var picker : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        return pickerView
    }()
    
    private var delegate : XPNonLinkageSelectDelegate?
    ///所展示的数据源
    private var dataSource = [[String]]()
    
    ///各列被选中的行 - 下标为列
    private var selectRow = [Int](){
        didSet{
            selectRow.enumerated().forEach({
                picker.selectRow($0.element, inComponent: $0.offset, animated: true)
            })
        }
    }
    
    
    //设置默认选择的数据
    var defaultData : [String]?{
        didSet{
            defaultSelect()
        }
    }
    
    /// 非联动选择器
    /// - Parameters:
    ///   - delegate: XPNonLinkageSelectDelegate
    ///   - data: 数据源
    ///   - defaultSelect: 默认选择数组,下标为列
    init(delegate:XPNonLinkageSelectDelegate,data:[[String]]) {
        dataSource = data
        
        self.delegate = delegate
        super.init(frame: CGRect.init(x: 0, y: APPConfig.height, width: APPConfig.width, height: APPConfig.height))
        backgroundColor = UIColor.black.alpha(0.3)
        setUI()
        addObservers()
    }
    
    
    private func setUI(){
        addSubview(picker)
        addSubview(funcationView)
        
        
        picker.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.height.equalToSuperview().multipliedBy(0.3)
        }
        
        funcationView.snp.makeConstraints { (m) in
            m.bottom.equalTo(picker.snp.top)
            m.left.right.equalToSuperview()
            m.height.equalTo(55)
        }
    }
    
    
    private func addObservers(){
        
        funcationView.confimBtn.rectiveClick {[unowned self] _ in
            
            var datas = [String]()
            self.selectRow.enumerated().forEach({
                datas.append(self.dataSource[$0.offset][$0.element])
            })
            
            if datas.count > 0{
                self.delegate?.selectFinishResult(pickerView: self, datas)
            }
            
            self.windowCloseView()
        }
        
        
        self.addTapGesture {[unowned self] in  self.windowCloseView()  }
        
        ///初始化各列默认选择行
        var rows = [Int]()
        dataSource.forEach { _ in
            rows.append(0)
        }
        selectRow = rows
        
        
    }
    
    ///设置默认选择数据
    private func defaultSelect(){
        
        guard defaultData?.count == dataSource.count else {
            log.debug("请确认默认值数量与数据源数量是否一致")
            return
        }
        
        var rows = [Int]()
        
        dataSource.enumerated().forEach { (datas) in
            
            rows.append(0)
            
            datas.element.enumerated().forEach { (subDatas) in
                if defaultData?[datas.offset] ==  subDatas.element{
                    rows[datas.offset] = subDatas.offset
                }
            }
        }
        
        selectRow = rows
        
    }
}

extension XPNonLinkagePickerView:UIPickerViewDelegate,UIPickerViewDataSource{
    
    /// 多少列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
        
    }
    
    /// 列中多少行
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ///暂没有做无限循环，还得优化，倍数行可实现
        return dataSource[component].count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleLabel = view as? UILabel
        if titleLabel == nil{
            titleLabel = UILabel()
            titleLabel?.textAlignment = .center
            titleLabel?.font = UIFont.systemFont(ofSize: 14)
            titleLabel?.textColor = UIColor.R333333
        }
        
        let componentData = dataSource[component]
        
        let title = componentData[row % (componentData.count )]
        
        titleLabel?.text = title
        
        return titleLabel!
    }
    
    ///列宽
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return APPConfig.width / (dataSource.count.cgFloat)
    }
    
    ///行高
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        selectRow[component] = row
        
    }
    
    
    //    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    //
    //
    //        return nil
    //
    //    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //
    //    }
}
