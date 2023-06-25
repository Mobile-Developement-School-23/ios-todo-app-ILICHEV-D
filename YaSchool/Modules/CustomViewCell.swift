import Foundation
import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func didTapCell(in cell: CustomTableViewCell)
    func didTapCheckbox(in cell: CustomTableViewCell)
}

class CustomTableViewCell: UITableViewCell {
    
    weak var delegate: CustomTableViewCellDelegate?
    
    private var stackView = UIStackView()
    
    private var titleLabel = UILabel()
    
    private let checkBoxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let priorityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Mode=Light")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var calendarLabel = UILabel()
    private var calendarImageView = UIImageView()
    private var calendarView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCalendarView()
        backgroundColor = UIColor(named: "BackSecondary")
        
        addSubview(checkBoxImageView)
        addSubview(priorityImageView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(calendarView)
        
        addSubview(stackView)
        addSubview(arrowImageView)
        
        let cellGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cellGestureRecognizer.cancelsTouchesInView = false
        isUserInteractionEnabled = true
        addGestureRecognizer(cellGestureRecognizer)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            checkBoxImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            checkBoxImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkBoxImageView.widthAnchor.constraint(equalToConstant: 24),
            checkBoxImageView.heightAnchor.constraint(equalToConstant: 24),
            
            priorityImageView.leadingAnchor.constraint(equalTo: checkBoxImageView.trailingAnchor, constant: 12),
            priorityImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            priorityImageView.heightAnchor.constraint(equalToConstant: 16),
            
            stackView.leadingAnchor.constraint(equalTo: priorityImageView.trailingAnchor, constant: 4),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            arrowImageView.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: 16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func setupCalendarView(){
        calendarLabel.removeFromSuperview()
        calendarImageView.removeFromSuperview()
        
        calendarView = UIView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarLabel = UILabel()
        calendarLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarLabel.numberOfLines = 1
        calendarLabel.textColor = UIColor(named: "LabelTertiary")
        calendarLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        calendarImageView = UIImageView()
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        calendarImageView.image = UIImage(named: "Calendar")?.withTintColor(UIColor(named: "LabelTertiary") ?? UIColor.gray)
        calendarImageView.contentMode = .scaleAspectFit
        
        calendarView.addSubview(calendarImageView)
        calendarView.addSubview(calendarLabel)
        
        NSLayoutConstraint.activate([
            calendarView.heightAnchor.constraint(equalToConstant: 20),
            
            calendarImageView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            calendarImageView.centerYAnchor.constraint(equalTo: calendarView.centerYAnchor),
            calendarImageView.heightAnchor.constraint(equalToConstant: 14),
            calendarImageView.widthAnchor.constraint(equalToConstant: 14),
            
            calendarLabel.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor),
            calendarLabel.centerYAnchor.constraint(equalTo: calendarView.centerYAnchor),
            calendarLabel.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            calendarLabel.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(todoItem: TodoItem?) {
        titleLabel.removeFromSuperview()
        calendarView.removeFromSuperview()
        
        setupCalendarView()
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 3
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(calendarView)
        titleLabel.text = nil
        titleLabel.attributedText = nil
        checkBoxImageView.image = nil
        priorityImageView.image = nil
        
        guard let todoItem = todoItem else {
            checkBoxImageView.isHidden = true
            priorityImageView.isHidden = true
            calendarView.isHidden = true
            arrowImageView.isHidden = true
            titleLabel.text = "Новое"
            titleLabel.textColor = UIColor(named: "LabelSecondary")
            return
        }
        
        checkBoxImageView.isHidden = false
        priorityImageView.isHidden = false
        calendarView.isHidden = false
        arrowImageView.isHidden = false
        titleLabel.textColor = todoItem.color?.colorFromHexString() ?? UIColor(named: "LabelPrimary")
        
        if todoItem.isDone {
            checkBoxImageView.image = UIImage(named: "Prop=on")
        } else {
            if todoItem.importance == .high {
                checkBoxImageView.image = UIImage(named: "Prop=High Priority")
            } else {
                checkBoxImageView.image = UIImage(named: "Prop=off")?.withTintColor(UIColor(named: "Check") ?? .gray)
            }
        }
        
        switch todoItem.importance {
        case .low:
            priorityImageView.image = UIImage(named: "LowPriority")
        case .high:
            priorityImageView.image = UIImage(named: "HighPriority")
        case .normal:
            break
        }
        
        if todoItem.isDone {
            titleLabel.text = nil
            titleLabel.attributedText = todoItem.text.strikeThroughWithSecondaryColor()
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = todoItem.text
        }
        
        if let date = todoItem.deadline  {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            calendarLabel.text = formatter.string(from: date)
            calendarView.isHidden = false
        } else {
            calendarView.isHidden = true
        }
    }
    
    @objc private func cellTapped(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sender.view)
        
        if checkBoxImageView.frame.contains(tapLocation) {
            delegate?.didTapCheckbox(in: self)
        } else {
            delegate?.didTapCell(in: self)
        }
    }
    
}


// MARK: Helper


private extension String {
    
    func strikeThroughWithSecondaryColor() -> NSAttributedString{
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "LabelSecondary") as Any, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
}
