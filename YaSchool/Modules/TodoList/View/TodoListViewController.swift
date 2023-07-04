import UIKit
import TodoItem

class TodoListViewController: UIViewController {

    var output: TodoListViewOutput!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
    
    private var addBlueButtonView = UIImageView()
    private var loadingIndicatorView = UIActivityIndicatorView(style: .large)
    private var dirtyIndicatorLabelView = UILabel()

    private let headerLabel = UILabel()
    private let headerButtonLabel = UILabel()

    private var todoItems: [TodoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewDidLoad()
        setupViews()
        setupNavigation()
        setupHeaderView()
        setupTableView()
        setupBottomButton()
        setupLoadingIndicator()
        setupDirtyIndicatorView()
        configureBottomButton(status: .loading)
    }

    private func setupNavigation() {
        title = "Мои дела"
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupViews() {
        view.backgroundColor = UIColor(named: "Back")
    }

    func setupHeaderView() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerButtonLabel.translatesAutoresizingMaskIntoConstraints = false

        headerLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        headerLabel.textColor = UIColor(named: "LabelTertiary")

        headerButtonLabel.font = UIFont.preferredFont(
            forTextStyle: .subheadline,
            compatibleWith: UITraitCollection(legibilityWeight: .bold)
        )

        headerButtonLabel.textColor = UIColor(named: "Blue")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTasksVisibility))
        headerButtonLabel.isUserInteractionEnabled = true
        headerButtonLabel.addGestureRecognizer(tapGestureRecognizer)

        headerView.addSubview(headerLabel)
        headerView.addSubview(headerButtonLabel)

        tableView.tableHeaderView = headerView

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            headerButtonLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            headerButtonLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    func setupTableView() {
        tableView.backgroundColor = UIColor(named: "Back")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
    }

}

extension TodoListViewController: TodoListViewInput {

    @MainActor func configure(_ model: [TodoItem], completedTasksIsHidden: Bool, completedTasksCount: Int) {
        headerLabel.text = "Выполнено — \(completedTasksCount)"
        headerButtonLabel.text = completedTasksIsHidden ? "Показать" : "Скрыть"
        todoItems = model
        tableView.reloadData()
    }

    @MainActor func setStatus(_ status: TodoListViewStatus) {
        configureBottomButton(status: status)
    }
    
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        // swiftlint:disable:previous force_cast
        cell.delegate = self

        cell.selectionStyle = .none
        if indexPath.row < todoItems.count {
            let todoItem = todoItems[indexPath.row]
            cell.configure(todoItem: todoItem)
        } else {
            cell.configure(todoItem: nil)
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.row < todoItems.count else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, _) in
            self?.output.deleteButtonTapped(index: indexPath.row)
        }

        deleteAction.backgroundColor = UIColor(named: "Red")
        deleteAction.image = UIImage(systemName: "trash.fill")

        let infoAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, _) in
            self?.output.infoButtonTapped(index: indexPath.row)
        }
        infoAction.backgroundColor = UIColor(named: "GrayLight")
        infoAction.image = UIImage(systemName: "info.circle.fill")

        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])

        return swipeActionsConfiguration
    }

    func tableView(
        _ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.row < todoItems.count else {
            return nil
        }

        let checkAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, _) in
            self?.output.checkButtonTapped(index: indexPath.row)
        }

        checkAction.backgroundColor = UIColor(named: "Green")
        checkAction.image = UIImage(systemName: "checkmark.circle.fill")

        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [checkAction])

        return swipeActionsConfiguration
    }

}

extension TodoListViewController: CustomTableViewCellDelegate {

    @MainActor func didTapCell(in cell: CustomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.row == todoItems.count {
            output.addNewTaskButtonTapped()
        } else {
            output.infoButtonTapped(index: indexPath.row)
        }
    }

    @MainActor func didTapCheckbox(in cell: CustomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        output.checkButtonTapped(index: indexPath.row)
    }

}

private extension TodoListViewController {

    func configureBottomButton(status: TodoListViewStatus) {
        switch status {
        case .basic:
            addBlueButtonView.isHidden = false
            dirtyIndicatorLabelView.isHidden = true
            loadingIndicatorView.isHidden = true
        case .loading:
            loadingIndicatorView.startAnimating()
            addBlueButtonView.isHidden = true
            dirtyIndicatorLabelView.isHidden = true
            loadingIndicatorView.isHidden = false
        case .dirty:
            addBlueButtonView.isHidden = true
            dirtyIndicatorLabelView.isHidden = false
            loadingIndicatorView.isHidden = true
            loadingIndicatorView.stopAnimating()
        }
    }
    
    func setupDirtyIndicatorView() {
        dirtyIndicatorLabelView.translatesAutoresizingMaskIntoConstraints = false
        dirtyIndicatorLabelView.text = "Ошибка загрузки. Показываются локальные данные"
        dirtyIndicatorLabelView.numberOfLines = 2
        dirtyIndicatorLabelView.textColor = .tertiaryLabel
        dirtyIndicatorLabelView.textAlignment = .center
        let padding: CGFloat = 16
        
        view.addSubview(dirtyIndicatorLabelView)
        
        NSLayoutConstraint.activate([
            dirtyIndicatorLabelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            dirtyIndicatorLabelView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            dirtyIndicatorLabelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dirtyIndicatorLabelView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupLoadingIndicator() {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicatorView)
        
        NSLayoutConstraint.activate([
            loadingIndicatorView.widthAnchor.constraint(equalToConstant: 44),
            loadingIndicatorView.heightAnchor.constraint(equalToConstant: 44),
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupBottomButton() {
        addBlueButtonView.translatesAutoresizingMaskIntoConstraints = false
        addBlueButtonView = UIImageView(image: UIImage(named: "Plus"))
        addBlueButtonView.translatesAutoresizingMaskIntoConstraints = false
        addBlueButtonView.layer.cornerRadius = 22
        addBlueButtonView.contentMode = .scaleAspectFit

        addBlueButtonView.layer.shadowColor = UIColor(named: "Blue")?.cgColor
        addBlueButtonView.layer.shadowOpacity = 0.3
        addBlueButtonView.layer.shadowOffset = CGSize(width: 0, height: 8)
        addBlueButtonView.layer.shadowRadius = 20
        view.addSubview(addBlueButtonView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(plusButtonTapped))
        addBlueButtonView.isUserInteractionEnabled = true
        addBlueButtonView.addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            addBlueButtonView.widthAnchor.constraint(equalToConstant: 44),
            addBlueButtonView.heightAnchor.constraint(equalToConstant: 44),
            addBlueButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addBlueButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func plusButtonTapped() {
        output?.addNewTaskButtonTapped()
    }

    @objc private func changeTasksVisibility() {
        output?.toggleCompletedTasksVisibility()
    }

}

enum TodoListViewStatus {
    case basic
    case loading
    case dirty
}
