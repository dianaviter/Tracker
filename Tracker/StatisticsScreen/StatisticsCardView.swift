//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by Diana Viter on 15.06.2025.
//

import UIKit

final class StatisticsCardView: UIView {
    
    private let gradientBorderLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .trackerBlack
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trackerBlack
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.cornerRadius = 16
        clipsToBounds = true

        setupLayout()
        setupGradientBorder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        gradientBorderLayer.frame = bounds
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.75, dy: 0.75),
            cornerRadius: layer.cornerRadius
        ).cgPath
    }
    
    private func setupGradientBorder() {
        gradientBorderLayer.colors = [
            UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1).cgColor,
            UIColor(red: 0.27, green: 0.90, blue: 0.62, alpha: 1).cgColor,
            UIColor(red: 0.00, green: 0.49, blue: 0.98, alpha: 1).cgColor
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: -1)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: -1)
        layer.addSublayer(gradientBorderLayer)

        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientBorderLayer.mask = shapeLayer
    }

    private func setupLayout() {
        [valueLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }
}
