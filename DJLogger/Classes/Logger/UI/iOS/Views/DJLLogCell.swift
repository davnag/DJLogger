/*
 The MIT License (MIT)

 Copyright (c) 2021 David Jonsén

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

private extension DJLLogger.Level {
    
    var color: UIColor {
        switch self {
        case .trace, .debug:
            return .systemGreen
        case .warning:
            return .systemYellow
        case .error, .critical:
            return .systemRed
        }
    }
}

final class DJLLogCell: UITableViewCell {
    
    public lazy var timeStampLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .label
        view.numberOfLines = 0
        view.font = .preferredFont(forTextStyle: .headline)
        return view
    }()
    
    public lazy var levelLabel: UILabel = {
        let view = PaddingLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .white
        view.font = .systemFont(ofSize: 15, weight: .bold)
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    public lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .label
        view.numberOfLines = 0
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()
    
    public lazy var metaDescriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .secondaryLabel
        view.numberOfLines = 0
        view.font = .preferredFont(forTextStyle: .caption2)
        return view
    }()
    
    public lazy var labelLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .link
        view.numberOfLines = 0
        view.font = .preferredFont(forTextStyle: .caption1)
        return view
    }()

    public var log: DJLFileLog? {
        didSet {
            
            guard let log = log else {
                return
            }
            
            timeStampLabel.text = log.timeStamp
            
            levelLabel.text = log.level.name
            levelLabel.backgroundColor = log.level.color
            
            messageLabel.text = log.message
            metaDescriptionLabel.text = log.meta
            labelLabel.text = log.label
        }
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        levelLabel.layer.cornerRadius = levelLabel.bounds.height / 2
    }
}

// MARK: Setup

extension DJLLogCell {
    
    private func setupSubviews() {

        contentView.addSubview(timeStampLabel)
        contentView.addSubview(levelLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(metaDescriptionLabel)
        contentView.addSubview(labelLabel)
    }
    
    private func setupConstraints() {
        
        levelLabel.contentHuggingPriority(for: .horizontal)
        
        NSLayoutConstraint.activate([

            timeStampLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            timeStampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeStampLabel.trailingAnchor.constraint(equalTo: levelLabel.leadingAnchor, constant: -16),
            
            levelLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            levelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            messageLabel.topAnchor.constraint(equalTo: timeStampLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            metaDescriptionLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            metaDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metaDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            labelLabel.topAnchor.constraint(equalTo: metaDescriptionLabel.bottomAnchor, constant: 8),
            labelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
