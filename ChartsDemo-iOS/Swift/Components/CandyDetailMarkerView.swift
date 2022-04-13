//
//  CandyDetailMarkerView.swift
//  ChartsDemo-iOS-Swift
//
//  Created by Enter on 2022/4/13.
//  Copyright © 2022 dcg. All rights reserved.
//

import UIKit
import Charts

class CandyDetailMarkerView: MarkerView {

    private let formatter = DateFormatter()
    public let titleLabel: UILabel = UILabel()
    public let numlabel: UILabel = UILabel()
    public let unitLabel: UILabel = UILabel()
    public let timeLabel: UILabel = UILabel()
    public let lineView = UIView()
    public let decimal: Bool = false
    public let labelBg = UIView()
    private let titleFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    private let numberFont = UIFont.systemFont(ofSize: 28, weight: .semibold)
    private let unitFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    private let timeFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    private let lableViewHeight: CGFloat = 68
    
    init() {
        super.init(frame: CGRect.zero)
        setUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI() {
        self.backgroundColor = .clear
        self.addSubview(labelBg)
        self.addSubview(lineView)
        labelBg.addSubview(titleLabel)
        labelBg.addSubview(numlabel)
        labelBg.addSubview(unitLabel)
        labelBg.addSubview(timeLabel)
        
        labelBg.layer.cornerRadius = 8
        labelBg.backgroundColor = .lightGray
        labelBg.frame = CGRect(x: 0, y: 0, width: 0, height: lableViewHeight)
        
        titleLabel.frame = CGRect(x: 8, y: 4, width: 56, height: 17)
        titleLabel.textAlignment = .left
        titleLabel.font = titleFont
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        
        numlabel.frame = CGRect(x: 8, y: 21, width: 0, height: 28)
        numlabel.textAlignment = .left
        numlabel.font = numberFont
        
        unitLabel.frame = CGRect(x: 10, y: 29, width: 0, height: 20)
        unitLabel.font = unitFont
        
        timeLabel.frame = CGRect(x: 8, y: 49, width: 0, height: 17)
        timeLabel.font = timeFont
        timeLabel.textColor = UIColor.init(white: 1, alpha: 0.6)

        lineView.backgroundColor = .gray
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if !decimal {
            numlabel.text = String.init(format: "%d", Int(entry.y))
        } else {
            numlabel.text = String.init(format: "%.1f", entry.y)
        }

        self.formatter.dateFormat = "yyyy年M月d日"
        timeLabel.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(entry.x*86400)))

        let numWidth = numlabel.text?.width(withConstrainedHeight: 28, font: numberFont)
        let unitWidth = unitLabel.text?.width(withConstrainedHeight: 20, font: unitFont)
        let timeWidth = timeLabel.text?.width(withConstrainedHeight: 17, font: timeFont)
        if let numWidth = numWidth, let unitWidth = unitWidth, let timeWidth = timeWidth {
            timeLabel.frame.size.width = timeWidth
            numlabel.frame.size.width = numWidth
            unitLabel.frame = CGRect(x: 8+numWidth+2, y: 29, width: unitWidth, height: 20)
            if numWidth+unitWidth+2 > timeWidth {
                labelBg.frame.size.width = numWidth+unitWidth+18
            } else {
                labelBg.frame.size.width = timeWidth+16
            }
            
        }
        layoutIfNeeded()
        
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        guard let chart = chartView else { return self.offset }
        self.bounds = CGRect(x: 0, y: 0, width: labelBg.bounds.size.width, height: point.y-2)
        
        var offset = self.offset
        
        let width = self.bounds.size.width
        
        offset.x = offset.x - width/2
        
        if point.x + offset.x < 0.0
        {
            offset.x = -point.x
        }
        else if point.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - point.x - width
        }

        self.lineView.frame = CGRect(x: -offset.x, y: lableViewHeight, width: 1.0, height: point.y-4-lableViewHeight)
        offset.y = -point.y
        
        return offset
    }

}

