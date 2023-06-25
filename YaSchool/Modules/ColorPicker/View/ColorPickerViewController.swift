import UIKit

class ColorPickerViewController: UIViewController {

    var output: ColorPickerViewOutput?

    private var color = UIColor()
    private var alphaComponent: CGFloat = 1.0

    private let padding: CGFloat = 16
    private let smallPadding: CGFloat = 8

    private let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: nil, action: nil)
    private let saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: nil, action: nil)

    private let colorPreviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let colorCodeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.setValue(1.0, animated: false)
        return slider
    }()

    private let colorPickerView: ColorPickerView = {
        let colorPicker = ColorPickerView()
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.layer.borderWidth = 1.0
        colorPicker.layer.borderColor = UIColor.black.cgColor
        return colorPicker
    }()

    private let freeSpace: UIView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let spacerWidthConstraint = spacer.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true
        return spacer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Back")

        setupNavigationBar()
        setupSubviews()
        setupConstraints()

        colorPickerView.delegate = self
        brightnessSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Цвет"
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton

        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonTapped)
        saveButton.target = self
        saveButton.isEnabled = false
        saveButton.action = #selector(saveButtonTapped)
    }

    private func setupSubviews() {
        view.addSubview(colorPreviewView)
        view.addSubview(colorCodeLabel)
        view.addSubview(brightnessSlider)
        view.addSubview(colorPickerView)
        view.addSubview(freeSpace)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            colorPreviewView.leadingAnchor.constraint(equalTo: colorPickerView.leadingAnchor),
            colorPreviewView.widthAnchor.constraint(equalToConstant: 50),
            colorPreviewView.heightAnchor.constraint(equalToConstant: 50),

            colorCodeLabel.centerYAnchor.constraint(equalTo: colorPreviewView.centerYAnchor),
            colorCodeLabel.leadingAnchor.constraint(equalTo: colorPreviewView.trailingAnchor, constant: smallPadding),

            colorPickerView.topAnchor.constraint(equalTo: colorPreviewView.bottomAnchor, constant: padding),
            colorPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorPickerView.widthAnchor.constraint(equalToConstant: 300),
            colorPickerView.heightAnchor.constraint(lessThanOrEqualToConstant: 300),

            brightnessSlider.topAnchor.constraint(equalTo: colorPickerView.bottomAnchor, constant: padding),
            brightnessSlider.widthAnchor.constraint(equalTo: colorPickerView.widthAnchor),
            brightnessSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            freeSpace.topAnchor.constraint(equalTo: brightnessSlider.bottomAnchor),
            freeSpace.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            freeSpace.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            freeSpace.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        alphaComponent = CGFloat(sender.value)
        color = color.withAlphaComponent(alphaComponent)
        colorPreviewView.backgroundColor = color
        colorCodeLabel.text = color.hexString
        saveButton.isEnabled = true
    }

    @objc private func cancelButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func saveButtonTapped() {
        output?.saveButtonTapped(hesString: color.hexString)
        self.navigationController?.popViewController(animated: true)
    }

}

extension ColorPickerViewController: ColorPickerViewDelegate {

    func didSelectColor(_ color: UIColor) {
        self.color = color
        colorPreviewView.backgroundColor = color.withAlphaComponent(alphaComponent)
        colorCodeLabel.text = color.withAlphaComponent(alphaComponent).hexString
        saveButton.isEnabled = true
    }

}

extension ColorPickerViewController: ColorPickerViewInput { }

protocol ColorPickerViewDelegate: AnyObject {

    func didSelectColor(_ color: UIColor)

}

// MARK: ColorPickerView

class ColorPickerView: UIView {

    weak var delegate: ColorPickerViewDelegate?

    private let pointerWidth: CGFloat = 20

    private let pointer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .white
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        self.addSubview(pointer)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        for yLine in stride(from: 0, to: Int(bounds.height), by: 1) {
            for xLine in stride(from: 0, to: Int(bounds.width), by: 1) {

                let normalizedX = CGFloat(xLine) / bounds.width
                let normalizedY = CGFloat(yLine) / bounds.height

                let hue = CGFloat(normalizedX)
                let saturation = 1.0 - CGFloat(normalizedY)
                let brightness = 1.0 - CGFloat(yLine) / bounds.height

                let selectedColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                context.setFillColor(selectedColor.cgColor)
                context.fill(CGRect(x: CGFloat(xLine), y: CGFloat(yLine), width: 1.0, height: 1.0))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchPoint = touch.location(in: self)

        if touchPoint.x <= frame.width, 0 <= touchPoint.x, touchPoint.y <= frame.height, 0 <= touchPoint.y {
            let normalizedX = CGFloat(touchPoint.x) / bounds.width
            let normalizedY = CGFloat(touchPoint.y) / bounds.height

            let hue = CGFloat(normalizedX)
            let saturation = 1.0 - CGFloat(normalizedY)
            let brightness = 1.0 - CGFloat(touchPoint.y) / bounds.height

            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)

            let pointerX = touchPoint.x - pointerWidth / 2
            pointer.frame = .init(
                x: pointerX, y: (touchPoint.y - pointerWidth / 2), width: pointerWidth, height: pointerWidth
            )

            delegate?.didSelectColor(color)
        }
        self.touchesCancelled(touches, with: event)
    }
}
