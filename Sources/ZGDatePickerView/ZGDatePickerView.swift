import UIKit

public enum ZGDatePickerType {
    case future
    case past
    case all
}

public class ZGDatePickerView: UIView {

    public var maxPastCount = 50 {
        didSet {picker.reloadAllComponents()}
    }
    public var maxFutureCount = 8  {
        didSet {picker.reloadAllComponents()}
    }
    public let cancelButton = UIButton()
    public let sureButton = UIButton()
    public let contentView = UIView()
    
    private var dateType: ZGDatePickerType = .all  {
        didSet {picker.reloadAllComponents()}
    }
    private var picker: UIPickerView!
    private var dateBlock: ((Date) -> Void)?
    private let scBounds = UIScreen.main.bounds
    private var currentDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    
    public convenience init(dateType: ZGDatePickerType = .all, dateBlock: ((Date) -> Void)?){
        self.init(frame: .zero)
        self.dateType = dateType
        self.dateBlock = dateBlock
    }
    
    private override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: scBounds.height, width: scBounds.width, height: scBounds.height))
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        cancelButton.frame = CGRect(x: 0, y: 10, width: 70, height: 30)
        sureButton.frame = CGRect(x: scBounds.width - 80, y: 10, width: 70, height: 30)
        cancelButton.setTitle("取消", for: .normal)
        sureButton.setTitle("确认", for: .normal)
        cancelButton.setTitleColor(rgba(224, 223, 223, 1), for: .normal)
        sureButton.setTitleColor(rgba(224, 223, 223, 1), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
        picker = UIPickerView(frame: CGRect(x: 0, y: 34, width: scBounds.width, height: 216))
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.clear
        picker.clipsToBounds = true
        contentView.frame = CGRect(x: 0, y: scBounds.height-240, width: scBounds.width, height: 250)
        contentView.backgroundColor = rgba(21, 19, 30, 1)
        contentView.addSubview(cancelButton)
        contentView.addSubview(sureButton)
        contentView.addSubview(picker)
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(){
        var kWindow: UIWindow?
        if #available(iOS 13.0, *) {
            for window in UIApplication.shared.windows {
                if window.isKeyWindow {
                    kWindow = window
                    break
                }
            }
        } else {
            if let keyWindow = UIApplication.shared.keyWindow {
                kWindow = keyWindow
            }
        }
        kWindow?.addSubview(self)
        UIView.animate(withDuration: 0.2) {
            self.frame.origin.y = self.scBounds.height - self.frame.height
        }
    }

    @objc public func dismiss() {
        UIView.animate(withDuration: 0.2) {
            self.frame.origin.y = self.scBounds.height
        } completion: { (finish) in
            self.removeFromSuperview()
        }
    }
    
    public func selectRow(row: Int, inComponent: Int, animated:Bool){
        picker.selectRow(row, inComponent: inComponent, animated: animated)
    }
    
    @objc private func onClickSure() {
        var year = picker.selectedRow(inComponent: 0) + currentDate.year! - maxPastCount
        var month = picker.selectedRow(inComponent: 1) + 1
        var days = picker.selectedRow(inComponent: 2) + 1
        if dateType == .future {
            year = picker.selectedRow(inComponent: 0) + currentDate.year!
            if year == currentDate.year {
                month = picker.selectedRow(inComponent: 1) + currentDate.month!
                if month == currentDate.month {
                    days = picker.selectedRow(inComponent: 2) + currentDate.day!
                }
            }
        }
        
        let dateString = String(format: "%02ld-%02ld-%02ld", year, month, days)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateBlock?(dateFormatter.date(from: dateString) ?? Date())
        dismiss()
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let currentPoint = touches.first?.location(in: self)
        if !self.contentView.frame.contains(currentPoint ?? CGPoint()) {
            dismiss()
        }
    }
    
    private func rgba(_ r:CGFloat, _ g:CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor{
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}

extension ZGDatePickerView:UIPickerViewDelegate,UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            switch dateType {
            case .all: return maxFutureCount+1 + maxPastCount
            case .future: return maxFutureCount+1
            case .past: return maxPastCount+1
            }
        }
        else if component == 1 {
            switch dateType {
            case .all: return 12
            case .future:
                if currentDate.year == pickerView.selectedRow(inComponent: 0) + (currentDate.year!){
                    return 12 - (currentDate.month ?? 12) + 1
                }
            case .past:
                if currentDate.year == pickerView.selectedRow(inComponent: 0) + (currentDate.year!-maxPastCount){
                    return currentDate.month ?? 12
                }
            }
            return 12
        }
        else {
            var year = pickerView.selectedRow(inComponent: 0) + currentDate.year! - maxPastCount
            var month = pickerView.selectedRow(inComponent: 1) + 1
            if dateType == .future {
                year = pickerView.selectedRow(inComponent: 0) + currentDate.year!
                if year == currentDate.year {
                    month = pickerView.selectedRow(inComponent: 1) + currentDate.month!
                }
            }
            let days = howManyDays(inThisYear: year, withMonth: month)
            switch dateType {
            case .all: return days
            case .future:
                if currentDate.year == year, currentDate.month! == month{
                    return days - (currentDate.day ?? 31)+1
                }
            case .past:
                if currentDate.year == year, currentDate.month! <= month{
                    return currentDate.day ?? 31
                }
            }
            return days
        }
    }
    private func howManyDays(inThisYear year: Int, withMonth month: Int) -> Int {
        if (month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12) {
            return 31
        }
        if (month == 4) || (month == 6) || (month == 9) || (month == 11) {
            return 30
        }
        if (year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3) {
            return 28
        }
        if year % 400 == 0 {
            return 29
        }
        if year % 100 == 0 {
            return 28
        }
        return 29
    }
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return scBounds.width / 3
    }
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var text = ""
        if component == 0 {
            if dateType == .future {
                text = "\((currentDate.year!) + row)\("年")"
            }else{
                text = "\((currentDate.year!) + row - maxPastCount)\("年")"
            }
        } else if component == 1 {
            if dateType == .future && pickerView.selectedRow(inComponent: 0) == 0 {
                text = "\(row + currentDate.month!)\("月")"
            }else{
                text = "\(row + 1)\("月")"
            }
        } else {
            if dateType == .future,
               pickerView.selectedRow(inComponent: 0) == 0,
               pickerView.selectedRow(inComponent: 1) == 0{
                text = "\(row + currentDate.day!)\("日")"
            }else{
                text = "\(row + 1)\("日")"
            }
        }
        let attr = NSMutableAttributedString(string: text)
        attr.addAttributes([.foregroundColor : rgba(224, 223, 223, 1)], range: NSMakeRange(0, attr.length))
        return attr
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
        }
        else if component == 1 {
            pickerView.reloadComponent(2)
        }
    }
}
