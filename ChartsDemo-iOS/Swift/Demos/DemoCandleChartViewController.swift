//
//  DemoCandleChartViewController.swift
//  ChartsDemo-iOS-Swift
//
//  Created by Enter on 2022/4/12.
//  Copyright © 2022 dcg. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif
import Charts
#if canImport(UIKit)
    import UIKit
#endif

class DemoCandleChartViewController: DemoBaseViewController {
    @IBOutlet var chartView: CombinedChartView!
    private let ITEM_COUNT = 200
    private var panValue:CGFloat = 0
    private var bIsCalculatePan = false
    private var lastXValue: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Combine Chart"
        
        initChart()
        updateChartData()
    }

    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setChartData()
    }
    func setChartData() {
        let data = CombinedChartData()
        
        data.candleData = generateCandleData()
        data.lineData = generateLineData()
//        chartView.xAxis.axisMaximum = data.xMax + 0.25
        chartView.data = data
        chartView.setVisibleXRangeMaximum(31)
        if let last = data.lineData.dataSets[0].entryForIndex(ITEM_COUNT-1) {
            chartView.moveViewToX(last.x)
            self.lastXValue = last.x
        }
        
    }
    
    func generateLineData() -> LineChartData {
        let date = Date().startOfMonth().timeIntervalSince1970 / daySeconds
        let entries = (0..<ITEM_COUNT).map { (i) -> ChartDataEntry in
            let x = lround(date)+i
            return ChartDataEntry(x: Double(x), y: Double(arc4random_uniform(15) + 35))
        }
        
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set.lineWidth = 2.5
        set.setCircleColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set.circleRadius = 5
        set.circleHoleRadius = 2.5
        set.fillColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        set.mode = .linear
        set.drawValuesEnabled = false
        
        set.axisDependency = .left
        
        return LineChartData(dataSet: set)
    }
    
    func generateCandleData() -> CandleChartData {
        let date = Date().startOfMonth().timeIntervalSince1970 / daySeconds
        let entries = stride(from: 0, to: ITEM_COUNT, by: 1).map { (i) -> CandleChartDataEntry in
            let high = Double(arc4random_uniform(15) + 60)
            let low = Double(arc4random_uniform(15) + 20)
            let x = lround(date)+i
            return CandleChartDataEntry(x: Double(x), shadowH: high, shadowL: low, open: high, close: low)
        }
        
        let set = CandleChartDataSet(entries: entries, label: "Candle DataSet")
        set.setColor(UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1))
        set.decreasingColor = UIColor(red: 142/255, green: 150/255, blue: 175/255, alpha: 1)
        set.shadowColor = .darkGray
        set.drawValuesEnabled = false
        set.barSpace = 0.25
        set.barCornerRadius = 1.5
        return CandleChartData(dataSet: set)
    }

}

extension DemoCandleChartViewController {
    func initChart() {
        chartView.delegate = self
        chartView.drawOrder = [
                               DrawOrder.candle.rawValue,
                               DrawOrder.line.rawValue
        ]
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
        xAxis.granularityEnabled = true
        xAxis.axisLineWidth = 0.3
        xAxis.gridLineWidth = 0.3
        xAxis.gridLineDashLengths = [2, 4]
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
//        leftAxis.axisMaximum = 60
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

extension DemoCandleChartViewController: ChartViewDelegate {
    // TODO: Cannot override from extensions
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.bIsCalculatePan = true
            if self.panValue >= 15 {
                let leftValue = self.chartView.lowestVisibleX
                let timeInterval = leftValue*daySeconds
                let date = Date.init(timeIntervalSince1970: TimeInterval.init(timeInterval))
                let day = date.startOfMonth()
                print("<-\(day.get(.month))月\(day.get(.day))")
                let aim = Double(lround(day.timeIntervalSince1970 / daySeconds)-1)
                print(day.timeIntervalSince1970)
                self.chartView.moveViewToAnimated(xValue: aim, yValue: 0, axis: .left, duration: 0.3, easingOption: .easeInCubic)
                self.lastXValue = aim
            } else if self.panValue < -15 {
                let rightValue = self.chartView.highestVisibleX
                let timeInterval = rightValue*daySeconds
                let date = Date.init(timeIntervalSince1970: TimeInterval.init(timeInterval))
                let day = date.startOfMonth()
                print("->\(day.get(.month))月\(day.get(.day))")
                let aim = Double(lround(day.timeIntervalSince1970 / daySeconds)-1)
                print(day.timeIntervalSince1970)
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
        }
    }
}

extension DemoCandleChartViewController {
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
}
