# ZGDatePickerView

一个日期选择器。

1.可设置只选择未来日期、过去的日期、或者全部日期

2.可设置最多可以选择过去/未来多少年时间

3.可自定义确认取消按钮、背景颜色

# 安装
通过 Swift Package Manager安装

# 使用
```swift
let picker = ZGDatePickerView(dateType: .all) { date in
            let dateFormat: String = "YYYY年MM月dd日"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let dateString: String = dateFormatter.string(from: date)
            print(dateString)
        }
        picker.backgroundColor = .red
        picker.maxPastCount = 3
        picker.maxFutureCount = 3
        picker.show()
        picker.selectRow(row: 1, inComponent: 0, animated: false)
        
        //设置contentView背景
//        picker.contentView.backgroundColor
        //设置取消、确认按钮
//        picker.sureButton
//        picker.cancelButton
```
