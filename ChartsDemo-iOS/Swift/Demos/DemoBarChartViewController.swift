//
//  DemoBarChartViewController.swift
//  ChartsDemo-iOS-Swift
//
//  Created by Enter on 2022/4/6.
//  Copyright © 2022 dcg. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif
import Charts
#if canImport(UIKit)
    import UIKit
#endif

class DemoBarChartViewController: DemoBaseViewController {
    @IBOutlet var chartView: BarChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    private var panValue:CGFloat = 0
    private var bIsCalculatePan = false
    private var lastXValue: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Bar Chart"
        
        self.options = [.toggleValues,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleData,
                        .toggleBarBorders]
        
//        self.setup(barLineChartView: chartView)

        sliderX.value = 200
        sliderY.value = 50
        slidersValueChanged(nil)
        
        initChart()
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(sliderX.value) + 1, range: UInt32(sliderY.value))
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let start = 0
        let date = Date().startOfMonth().timeIntervalSince1970
        let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            let x = lround(date / daySeconds) + i
            return BarChartDataEntry(x: Double(x), y: val)
            
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.first as? BarChartDataSet {
            set1 = set
            set1.roundedCorners = [.topLeft, .topRight]
            set1.replaceEntries(yVals)
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(entries: yVals, label: "The year")
            set1.roundedCorners = [.topLeft, .topRight]
            set1.colors = [NSUIColor.green]
            set1.drawValuesEnabled = false
            let data = BarChartData(dataSet: set1)
            data.barWidth = 0.5
            chartView.data = data
        }
        chartView.setVisibleXRangeMaximum(31)
        if let last = yVals.last {
            chartView.moveViewToX(last.x)
            self.lastXValue = last.x
        }
        
    }
    
    override func optionTapped(_ option: Option) {
        super.handleOption(option, forChartView: chartView)
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value + 2))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        self.updateChartData()
    }
}

extension DemoBarChartViewController {
    func initChart() {
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.dragEnabled = true
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.dragDecelerationEnabled = false
        chartView.extraTopOffset = 80
        chartView.xAxisRenderer = MonthXAxisRenderer(viewPortHandler: chartView.viewPortHandler, axis: chartView.xAxis, transformer: chartView.getTransformer(forAxis: .left))
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.valueFormatter = DayValueFormatter(chart: chartView)
        xAxis.axisLineWidth = 0.3
        xAxis.gridLineWidth = 0.3
        xAxis.gridLineDashLengths = [2, 4]
        xAxis.spaceMax = 1
        xAxis.spaceMin = 1
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.axisMaximum = 60
        leftAxis.labelCount = 3
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.gridLineWidth = 0.2
        leftAxis.axisLineWidth = 0.2
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false

        let l = chartView.legend
        l.enabled = false

        let marker = DetailMarkerView()
        marker.chartView = chartView
        chartView.marker = marker
        marker.titleLabel.text = "平均"
        marker.unitLabel.text = "次/分"
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.3
        chartView?.addGestureRecognizer(longPressGesture)

    }
}


extension DemoBarChartViewController: ChartViewDelegate {
    // TODO: Cannot override from extensions
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.bIsCalculatePan = true
            if self.panValue >= 15 {
                let leftValue = self.chartView.lowestVisibleX
                let timeInterval = leftValue*daySeconds
                let date = Date.init(timeIntervalSince1970: TimeInterval.init(timeInterval))
                let day = date.startOfMonth()
                let aim = Double(lround(day.timeIntervalSince1970 / daySeconds)-1)//Double(Int(day.timeIntervalSince1970))
                print("<-\(day.get(.month))月\(day.get(.day)) \(aim)")
                self.chartView.moveViewToAnimated(xValue: aim, yValue: 0, axis: .left, duration: 0.3, easingOption: .easeInCubic)
                self.lastXValue = aim
            } else if self.panValue < -15 {
                let rightValue = self.chartView.highestVisibleX
                let timeInterval = rightValue*daySeconds
                let date = Date.init(timeIntervalSince1970: TimeInterval.init(timeInterval))
                let day = date.startOfMonth()
                
                let aim = Double(lround(day.timeIntervalSince1970 / daySeconds)-1)
                print("->\(day.get(.month))月\(day.get(.day)) \(aim)")
                self.chartView.moveViewToAnimated(xValue: aim, yValue: 0, axis: .left, duration: 0.3, easingOption: .easeInCubic)
                self.lastXValue = aim
            } else {
                self.chartView.moveViewToAnimated(xValue: self.lastXValue, yValue: 0, axis: .left, duration: 0.1, easingOption: .easeInCubic)
            }
            self.panValue = 0
            self.bIsCalculatePan = false
        }
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
   
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
 
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        if !bIsCalculatePan {
            
            panValue += dX
        } else {
            
        }
    }
}

extension DemoBarChartViewController {
    @objc
    private func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        guard let h = chartView.getHighlightByTouchPoint(sender.location(in: self.chartView)) else {return}
        if sender.state == .began {
            if h == chartView.lastHighlighted {
                chartView.lastHighlighted = nil
                chartView.highlightValue(nil)
            } else {
                chartView.lastHighlighted = h
                chartView.highlightValue(h, callDelegate: true)
            }
        } else if sender.state == .changed {
            chartView.lastHighlighted = h
            chartView.highlightValue(h, callDelegate: true)
        } else if sender.state == .ended {
            chartView.lastHighlighted = nil
            chartView.highlightValue(nil)
        }
    }
    
//    @objc
//    private func panGesture(_ sender: UIPanGestureRecognizer) {
//
//    }
}
