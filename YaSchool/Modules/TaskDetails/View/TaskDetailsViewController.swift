import UIKit
import FileCache

// swiftlint:disable file_length

class TaskDetailsViewController: UIViewController {

    var output: TaskDetailsViewOutput!

    // MARK: UI elements

    private let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: nil, action: nil)
    private let saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: nil, action: nil)

    private let scrollView = makeScrollView()
    private let contentView = makeContentView()
    private let textView = makeTextView()
    private let importanceLabel = makeImportanceLabel()
    private let colorPickerLabel = makeColorPickerLabel()
    private let containerView = makeContainerView()
    private let importanceSegmentedControl = makeImportanceSegmentedControl()
    private let divider1 = makeDivider()
    private let divider2 = makeDivider()
    private let divider3 = makeDivider()
    private let deadlineLabel = makeDeadlineLabel()
    private let deadlineSubtitleLabel = makeDeadlineSubtitleLabel()
    private let deadlineSwitch = makeDeadlineSwitch()
    private let deadlinePickerContainer = makeDeadlinePickerContainer()
    private let deadlinePicker = makeDeadlinePicker()
    private let deleteButton = makeDeleteButton()
    private let freeSpace = makeFreeSpace()
    private let placeholderLabel = makePlaceholderLabel()

    private let padding: CGFloat = 16
    private let smallPadding: CGFloat = 8

    private var isCalendarAvailable = false

    // MARK: UI overriding

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        output.viewDidLoad()
    }

}

// MARK: - TaskDetailsViewInput
extension TaskDetailsViewController: TaskDetailsViewInput {

    func configure(_ model: TodoItem?) {
        if let model = model {
            placeholderLabel.isHidden = true
            textView.text = model.text
            textView.textColor = model.color?.colorFromHexString() ?? .label
            importanceSegmentedControl.selectedSegmentIndex = model.importance.index
            if let deadline = model.deadline {
                deadlinePicker.date = deadline
                deadlineSwitch.isOn = true
            } else {
                deadlineSwitch.isOn = false
            }
            deleteButton.isEnabled = true
        } else {
            textView.text = ""
            importanceSegmentedControl.selectedSegmentIndex = 1
            deadlineSwitch.isOn = false
            deleteButton.isEnabled = false
            deadlinePicker.date = Date.tomorrow
        }
        deadlineSwitchValueChanged()
    }

    func colorText(_ hextString: String) {
        textView.textColor = hextString.colorFromHexString() ?? .label

    }

}

// MARK: UITextViewDelegate

extension TaskDetailsViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        changeButtonsEnablingIfNeeded()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }

}

// MARK: Setup views

private extension TaskDetailsViewController {

    private func setupView() {
        view.backgroundColor = UIColor(named: "Back")
        textView.delegate = self
        setupNavigationBar()
        changeButtonsEnablingIfNeeded()
        setupContentView()
        setupContainerView()
        setupUIElements()
        setupConstraints()

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

     func setupNavigationBar() {
         navigationController?.setNavigationBarHidden(false, animated: false)
         navigationItem.title = "Дело"
         navigationItem.leftBarButtonItem = cancelButton
         navigationItem.rightBarButtonItem = saveButton

         cancelButton.target = self
         cancelButton.action = #selector(cancelButtonTapped)
         saveButton.target = self
         saveButton.action = #selector(saveButtonTapped)
       }

    private func setupContentView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textView)
        contentView.addSubview(containerView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(freeSpace)
        textView.addSubview(placeholderLabel)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    // swiftlint:disable function_body_length
    private func setupContainerView() {
        let firstLine = UIView()
        firstLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addArrangedSubview(firstLine)
        firstLine.addSubview(importanceLabel)
        firstLine.addSubview(importanceSegmentedControl)

        containerView.addArrangedSubview(divider1)

        let colorPickerLine = UIView()
        colorPickerLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addArrangedSubview(colorPickerLine)
        colorPickerLine.addSubview(colorPickerLabel)
        colorPickerLine.isUserInteractionEnabled = true
        let tapColorPickerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapColorPicker))
        colorPickerLine.addGestureRecognizer(tapColorPickerGestureRecognizer)

        containerView.addArrangedSubview(divider2)

        let secondLine = UIView()
        secondLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addArrangedSubview(secondLine)
        let labelStackView = UIStackView()
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        labelStackView.addArrangedSubview(deadlineLabel)
        labelStackView.addArrangedSubview(deadlineSubtitleLabel)

        secondLine.addSubview(labelStackView)
        secondLine.addSubview(deadlineSwitch)

        secondLine.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSecondLine))
        secondLine.addGestureRecognizer(tapGestureRecognizer)

        containerView.addArrangedSubview(divider3)
        deadlinePickerContainer.addSubview(deadlinePicker)
        containerView.addArrangedSubview(deadlinePickerContainer)

        NSLayoutConstraint.activate([
            firstLine.heightAnchor.constraint(equalToConstant: 56),
            importanceLabel.centerYAnchor.constraint(equalTo: firstLine.centerYAnchor),
            importanceLabel.leadingAnchor.constraint(equalTo: firstLine.leadingAnchor, constant: padding),
            importanceSegmentedControl.centerYAnchor.constraint(equalTo: firstLine.centerYAnchor),
            importanceSegmentedControl.trailingAnchor.constraint(equalTo: firstLine.trailingAnchor, constant: -padding),

            colorPickerLine.heightAnchor.constraint(equalToConstant: 56),
            colorPickerLabel.centerYAnchor.constraint(equalTo: colorPickerLine.centerYAnchor),
            colorPickerLabel.leadingAnchor.constraint(equalTo: colorPickerLine.leadingAnchor, constant: padding),

            secondLine.heightAnchor.constraint(equalToConstant: 56),
            labelStackView.centerYAnchor.constraint(equalTo: secondLine.centerYAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: secondLine.leadingAnchor, constant: padding),
            deadlineSwitch.centerYAnchor.constraint(equalTo: secondLine.centerYAnchor),
            deadlineSwitch.trailingAnchor.constraint(equalTo: secondLine.trailingAnchor, constant: -padding),

            deadlinePickerContainer.topAnchor.constraint(equalTo: deadlinePicker.topAnchor, constant: -smallPadding),
            deadlinePickerContainer.leadingAnchor.constraint(equalTo: deadlinePicker.leadingAnchor, constant: -padding),
            deadlinePickerContainer.trailingAnchor.constraint(
                equalTo: deadlinePicker.trailingAnchor, constant: padding
            ),
            deadlinePickerContainer.bottomAnchor.constraint(
                equalTo: deadlinePicker.bottomAnchor, constant: smallPadding
            )
        ])
    }
    // swiftlint:enable function_body_length

    private func setupUIElements() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        importanceSegmentedControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        deadlineSwitch.addTarget(self, action: #selector(deadlineSwitchValueChanged), for: .valueChanged)
        deadlinePicker.addTarget(self, action: #selector(deadlinePickerValueChanged), for: .valueChanged)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: padding),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: padding),

            containerView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: padding),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -padding),

            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            deleteButton.heightAnchor.constraint(equalToConstant: 56),

            freeSpace.topAnchor.constraint(equalTo: deleteButton.bottomAnchor),
            freeSpace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            freeSpace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            freeSpace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

}

// MARK: Actions

private extension TaskDetailsViewController {

    private func updateDeadlineSubtitle() {
        if deadlineSwitch.isOn {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            deadlineSubtitleLabel.text = formatter.string(from: deadlinePicker.date)
            deadlineSubtitleLabel.isHidden = false
        } else {
            deadlineSubtitleLabel.text = nil
            deadlineSubtitleLabel.isHidden = true
        }
        changeButtonsEnablingIfNeeded()
    }

    @objc private func deadlineSwitchValueChanged() {
        isCalendarAvailable = deadlineSwitch.isOn
        changeDatePickerVisibility()
        updateDeadlineSubtitle()
    }

    @objc private func segmentValueChanged() {
        changeButtonsEnablingIfNeeded()
    }

    private func changeDatePickerVisibility() {
        let shouldShowAnimation = isCalendarAvailable == deadlinePickerContainer.isHidden
        [deadlinePickerContainer, divider3].forEach {
            $0.isHidden = !isCalendarAvailable
        }

        if shouldShowAnimation {
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }

    @objc private func deadlinePickerValueChanged() {
        updateDeadlineSubtitle()
    }

    @objc private func deleteButtonTapped() {
        output.deleteButtonTapped()
        endEditing()
    }

    @objc private func cancelButtonTapped() {
        output.cancelButtonTapped()
        endEditing()
    }

    @objc private func saveButtonTapped() {
        output.saveButtonTapped(
            text: textView.text,
            importance: importanceSegmentedControl.selectedSegmentIndex.importance,
            deadline: deadlineSwitch.isOn ? deadlinePicker.date : nil,
            color: textView.textColor == .label ? nil : textView.textColor?.hexString
        )
        endEditing()
    }

    @objc
    func didTapSecondLine() {
        isCalendarAvailable.toggle()
        changeDatePickerVisibility()
        updateDeadlineSubtitle()
        endEditing()
    }

    @objc
    func didTapColorPicker() {
        output.colorPickerTapped()
    }

    @objc
    func endEditing() {
        textView.resignFirstResponder()
    }

    private func changeButtonsEnablingIfNeeded() {
        let isTextFieldEmpty = !(textView.text ?? "").isEmpty
        deleteButton.isEnabled = isTextFieldEmpty
        saveButton.isEnabled = isTextFieldEmpty
    }

}

// MARK: Keyboard handling

private extension TaskDetailsViewController {

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset

        if textView.isFirstResponder {
            let textViewFrame = textView.convert(textView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(textViewFrame, animated: true)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

}

// MARK: UI elements helper

private extension TaskDetailsViewController {

    static func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }

    static func makeContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }

    static func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.backgroundColor = UIColor(named: "BackSecondary")
        textView.layer.cornerRadius = 16
        return textView
    }

    static func makeImportanceLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Важность"
        return label
    }

    static func makeColorPickerLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Выбрать цвет"
        return label
    }

    static func makeContainerView() -> UIStackView {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.backgroundColor = UIColor(named: "BackSecondary")
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }

    static func makeImportanceSegmentedControl() -> UISegmentedControl {
        let lowPriority = UIImage(named: "LowPriority")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let highPriority = UIImage(named: "HighPriority")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        let segmentedControl = UISegmentedControl(items: ["1", "нет", "3"])
        segmentedControl.setImage(lowPriority, forSegmentAt: 0)
        segmentedControl.setImage(highPriority, forSegmentAt: 2)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }

    static func makeDivider() -> UIStackView {
        let firstEmptyView = UIView()
        firstEmptyView.translatesAutoresizingMaskIntoConstraints = false
        firstEmptyView.backgroundColor = UIColor(named: "BackSecondary")
        let secondEmptyView = UIView()
        secondEmptyView.translatesAutoresizingMaskIntoConstraints = false
        secondEmptyView.backgroundColor = UIColor(named: "BackSecondary")
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(named: "Separator")
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(firstEmptyView)
        stack.addArrangedSubview(divider)
        stack.addArrangedSubview(secondEmptyView)
        NSLayoutConstraint.activate([
            firstEmptyView.widthAnchor.constraint(equalToConstant: 16),
            secondEmptyView.widthAnchor.constraint(equalToConstant: 16),
            stack.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return stack
    }

    static func makeDeadlineLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сделать до"
        return label
    }

    static func makeDeadlineSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(named: "Blue")
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    static func makeDeadlineSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }

    static func makeDeadlinePickerContainer() -> UIView {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func makeDeadlinePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.date = Date.tomorrow
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        return datePicker
    }

    static func makeDeleteButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "BackSecondary")
        button.isEnabled = true
        return button
    }

    static func makeFreeSpace() -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let spacerWidthConstraint = spacer.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true
        return spacer
    }

    static func makePlaceholderLabel() -> UILabel {
        let placeholder = UILabel()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = "Что надо сделать?"
        placeholder.font = .systemFont(ofSize: 17)
        placeholder.textColor = .secondaryLabel
        return placeholder
    }

}

// MARK: Helper

private extension Importance {

    var index: Int {
        switch self {
        case .low:
            return 0
        case .normal:
            return 1
        case .high:
            return 2
        }

    }

}

private extension Int {

    var importance: Importance {
        switch self {
        case 0:
            return .low
        case 1:
            return .normal
        case 2:
            return .high
        default:
            return .normal
        }

    }

}
