//
//  ViewController.swift
//  jtaCalendar-Demo
//
//  Created by apple on 2020/12/22.
//

import UIKit
import JTAppleCalendar
import SnapKit

class ViewController: UIViewController {

    let calendarView = JTACMonthView()
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    var numberOfRows = 6
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var hasStrictBoundaries = false
    let calendarWidth: CGFloat = 300
    lazy var calendarCellSize: CGFloat = {
        (calendarWidth / 7).rounded()
    }()
    lazy var calendarHeight: CGFloat = {
        calendarCellSize * 6
    }()
    
    let monthLabel = UILabel()
    let preBtn = UIButton()
    let nextBtn = UIButton()
    let styleBtn = UIButton()
    var weekScope = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(calendarView)
        view.addSubview(monthLabel)
        view.addSubview(preBtn)
        view.addSubview(nextBtn)
        view.addSubview(styleBtn)
        
        monthLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(calendarView.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        preBtn.snp.makeConstraints { (make) in
            make.right.equalTo(monthLabel.snp.left).offset(-10)
            make.centerY.equalTo(monthLabel.snp.centerY)
            make.width.height.equalTo(30)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.left.equalTo(monthLabel.snp.right).offset(10)
            make.centerY.equalTo(monthLabel.snp.centerY)
        }
        styleBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
            make.centerY.equalTo(monthLabel.snp.centerY)
        }
        calendarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150)
            make.centerX.equalToSuperview()
            make.width.equalTo(calendarWidth)
            make.height.equalTo(calendarHeight)
        }
        
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.register(CellView.self, forCellWithReuseIdentifier: "CellView")
        calendarView.backgroundColor = .white
        calendarView.cellSize = calendarCellSize//= CGSize(width: 30, height: 30)
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        calendarView.scrollingMode = .stopAtEachSection
        
        preBtn.setTitle("<", for: .normal)
        nextBtn.setTitle(">", for: .normal)
        styleBtn.setTitle("scope", for: .normal)
        styleBtn.setTitleColor(.black, for: .normal)
        nextBtn.setTitleColor(.black, for: .normal)
        preBtn.setTitleColor(.black, for: .normal)
        preBtn.addTarget(self, action: #selector(preMonth), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        styleBtn.addTarget(self, action: #selector(changeScope), for: .touchUpInside)
        
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    @objc
    func preMonth() {
        calendarView.scrollToSegment(.previous)
    }
    @objc
    func nextMonth() {
        calendarView.scrollToSegment(.next)
    }
    @objc
    func changeScope() {
        
        if weekScope {
            numberOfRows = 6
            calendarView.snp.updateConstraints { (make) in
                make.height.equalTo(calendarHeight)
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                self.calendarView.reloadData()
            }
        } else {
            numberOfRows = 1
            calendarView.snp.updateConstraints { (make) in
                make.height.equalTo(calendarCellSize)
            }
            UIView.animate(withDuration: 0.2) {
//                if let date = self.calendarView.selectedDates.first {
//                self.calendarView.scrollToDate(date)
//                }
                self.view.layoutIfNeeded()
                self.calendarView.reloadData()
            }
        }
        
        
        weekScope.toggle()
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = testCalendar.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
}

extension ViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        
        let startDate = formatter.date(from: "2020 01 01")!
        let endDate = formatter.date(from: "2022 12 31")!
        
        var parameters: ConfigurationParameters!
        if weekScope {
             parameters = ConfigurationParameters(startDate: startDate,
                                                     endDate: endDate,
                                                     numberOfRows: numberOfRows,
                                                     calendar: testCalendar,
                                                     generateInDates: generateInDates,
                                                     generateOutDates: generateOutDates,
                                                     firstDayOfWeek: .sunday,
                                                     hasStrictBoundaries: hasStrictBoundaries)
        } else {
            parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows)
        }
        return parameters
    }
}

extension ViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
        return myCustomCell
    }
    
    func configureVisibleCell(myCustomCell: CellView, cellState: CellState, date: Date, indexPath: IndexPath) {
        myCustomCell.dayLabel.text = cellState.text
        if testCalendar.isDateInToday(date) {
//            myCustomCell.backgroundColor = .red
            myCustomCell.layerView.backgroundColor = .red
        } else {
//            myCustomCell.backgroundColor = .white
            myCustomCell.layerView.backgroundColor = .white
        }
        
//        handleCellConfiguration(cell: myCustomCell, cellState: cellState)
        
        
        if cellState.text == "1" {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            myCustomCell.monthLabel.text = "\(month) \(cellState.text)"
        } else {
            myCustomCell.monthLabel.text = ""
        }
    }
}

class CellView: JTACDayCell {
    let dayLabel = UILabel()
    let monthLabel = UILabel()
    
    let selectView = UIView()
    let layerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectView)
        selectView.addSubview(layerView)
        contentView.addSubview(dayLabel)
        dayLabel.font = .systemFont(ofSize: 14)
        dayLabel.textColor = .black
        dayLabel.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.center.equalToSuperview()
        }
        layerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.height.equalTo(30)
//            make.edges.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
        }
        selectView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
//            make.edges.equalToSuperview()
        }
        selectView.layer.cornerRadius = 15
        selectView.clipsToBounds = true
        dayLabel.textAlignment = .center
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
