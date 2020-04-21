//
//  XPPickerHeadView.swift
//  FaMiaoWang
//
//  Created by admin on 2020/3/30.
//  Copyright © 2020 法苗网. All rights reserved.
//

import UIKit

public class XPPickerHeadView: UIView {
    
    let titleLabel :UILabel = {
        let label = UILabel.creatNew(text: "",alignment:.center)
        
        return label
    }()
    
    let confimBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("确定", for: .normal)
        btn.titleLabel?.font = UIFont.fourteen
        btn.setTitleColor(UIColor.red, for: .normal)
        return btn
    }()
    
    let cancelBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = UIFont.fourteen
        btn.setTitleColor(UIColor.purple, for: .normal)
        return btn
    }()
    
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.white
        setUI()
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI(){
        let lineView = UIView.initWithBGColor(Color: UIColor.REEEEEE)
        
        addSubviews([confimBtn,cancelBtn,titleLabel])
        addSubview(lineView)
        confimBtn.snp.makeConstraints { (m) in
            m.right.centerY.height.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.25)
        }
        
        cancelBtn.snp.makeConstraints { (m) in
            m.centerY.left.height.equalToSuperview()
            m.width.equalTo(confimBtn)
        }
        
        titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(cancelBtn.snp.right)
            m.right.equalTo(confimBtn.snp.left)
            m.height.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { (m) in
            m.left.bottom.right.equalToSuperview()
            m.height.equalTo(0.5)
        }
        
    }
    
    private func addObservers(){
        
        cancelBtn.rectiveClick {[unowned self] _ in
            self.superview?.windowCloseView()
        }
    }
}
