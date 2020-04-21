//
//  PickerView.swift
//  PickerView
//
//

import UIKit
import HandyJSON

enum AreaType :Int{
    case procince = 1
    case procinceAndCity = 2
    case All = 3
}

/// PickerDelegate
protocol AreaPickerDelegate {
    
    func selectedAddress(_ pickerView : PickerView,_ procince : Area?,_ city : Area?,_ area : Area?)
}


class PickerView: UIView , UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    var pickerDelegate : AreaPickerDelegate?
    
    private var addressPicker = UIPickerView()
    
    private var type : AreaType
    private var vm :AreaViewModel
    
    // MARK: - 初始化UI
    init(_ delegate : AreaPickerDelegate,datas:[Area],type:AreaType = .procinceAndCity){
        
        
        pickerDelegate = delegate
        vm = AreaViewModel(datas)
        self.type = type
        
        let frame = CGRect.init(x: 0, y: APPConfig.height, width: APPConfig.width, height: APPConfig.height)
        super.init(frame: frame)
        let view = UIView()
        view.backgroundColor = UIColor.REEEEEE
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.bottom.right.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        
        self.backgroundColor = UIColor.black.alpha(0.3)
        //        self.addTapGesture { [unowned self] in
        //            self.cancelButtonClick()
        //        }
        
        // 取消按钮
        let cancelButton = UIButton.init(type:.custom)
        cancelButton.frame = CGRect.init(x: 0, y: 0, width: 60, height: 44)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitle("取 消", for: .normal)
        cancelButton.setTitleColor(UIColor.RC21920, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // 确定按钮
        let doneButton = UIButton.init(type: .custom)
        doneButton.frame = CGRect.init(x: APPConfig.width - 60, y: 0, width: 60, height: 44)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.setTitle("确 定", for: .normal)
        doneButton.setTitleColor(UIColor.RC21920, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        view.addSubview(doneButton)
        
        
        addressPicker = UIPickerView()
        addressPicker.delegate = self
        addressPicker.dataSource = self
        addressPicker.backgroundColor = UIColor.white
        
        view.addSubview(addressPicker)
        addressPicker.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(44)
            make.left.bottom.right.equalToSuperview()
        }
        
        self.pickerView(addressPicker, didSelectRow: 0, inComponent: 0)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Method
    
    /// 取消按钮点击方法
    @objc func cancelButtonClick(){
        
        windowCloseView()
    }
    
    /// 确定按钮点击方法
    @objc func doneButtonClick(){
        log.debug("------ \(vm.selectDistricRow),\(vm.selectCityRow),\(vm.selectProvinceRow)")
        
        
        
        let province = vm.provinceArr[vm.selectProvinceRow]
        let city = vm.cityArr?[vm.selectCityRow ?? 0]
        let distric = vm.districArr?[vm.selectDistricRow ?? 0]
        
        pickerDelegate?.selectedAddress(self, province, city, distric)
        
        windowCloseView()
    }
    
    /// 展示pickerView
    public func pickerViewShow() {
        
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.0001, animations: {
            
            self.frame.origin.y = 0
        }) { (complete: Bool) in
            
        }
    }
    
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
    /// 返回列
    ///
    /// - Parameter pickerView: pickerView
    /// - Returns: 列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return type.rawValue
        
    }
    
    /// 返回对应列的行数
    ///
    /// - Parameters:
    ///   - pickerView: pickerView
    ///   - component: 列
    /// - Returns: 行
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        vm.getCountFor(component)
    }
    
    /// 返回对应行的title
    ///
    /// - Parameters:
    ///   - pickerView: pickerView
    ///   - row: 行
    ///   - component: 列
    /// - Returns: title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        vm.getTitleFor(component, row)
    }
    
    /// 选择列、行
    ///
    /// - Parameters:
    ///   - pickerView: pickerView
    ///   - row: 行
    ///   - component: 列
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            
            if type.rawValue > 1 {
                vm.changeProvince(row: row)
                // 这里select一下是为了执行 component==1时的方法数据
                self.pickerView(pickerView, didSelectRow: vm.selectCityRow ?? 0, inComponent: 1)
            }
            vm.selectProvinceRow = row
            
            
        }else if component == 1 {
            
            if type.rawValue > 2 {
                vm.changeCity(row: row)
                self.pickerView(pickerView, didSelectRow: vm.selectDistricRow ?? 0, inComponent: 2)
            }
            
            vm.selectCityRow = row
            
        }else{
            
            vm.selectDistricRow = row
            
        }
        
        ///刷新picker
        pickerView.reloadAllComponents()
        
    }
}




struct Area :HandyJSON,Encodable,Decodable{
    var value : String?
    var label : String?
    var children : [Area]?
    
}

class AreaViewModel {
    var provinceArr : [Area]
    var cityArr : [Area]?
    var districArr : [Area]?
    
    init(_ datas:[Area]) {
        provinceArr = datas
    }
    
    var selectProvinceRow : Int = 0
    var selectCityRow : Int?
    var selectDistricRow : Int?
    
    ///滑动是会改变cityArr， 和districArr两个数据源，下面使用的时候,get最新数据源就好
    var currentDataSource:[[Area]?]{
        get{
            return [provinceArr,cityArr,districArr]
        }
    }
    
    
    
    func changeProvince(row:Int){
        cityArr = provinceArr[row].children
        
    }
    
    func changeCity(row:Int){
        districArr = cityArr?[row].children
        
    }
    
    func changeDistric(row:Int){
        
    }
    
    
    func getTitleFor(_ complace:Int,_ row:Int) -> String?{
        return currentDataSource[complace]?[row].label
    }
    
    
    func getCountFor(_ complace:Int) -> Int{
        return currentDataSource[complace]?.count ?? 0
    }
    
    
    
}
