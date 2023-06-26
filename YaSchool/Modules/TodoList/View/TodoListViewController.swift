import UIKit
import TodoItem

class TodoListViewController: UIViewController {

    var output: TodoListViewOutput!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))

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
        //        tableView.tableHeaderView = headerView

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

    func configure(_ model: [TodoItem], completedTasksIsHidden: Bool, completedTasksCount: Int) {
        headerLabel.text = "Выполнено — \(completedTasksCount)"
        headerButtonLabel.text = completedTasksIsHidden ? "Показать" : "Скрыть"
        todoItems = model
        tableView.reloadData()
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

    func didTapCell(in cell: CustomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.row == todoItems.count {
            output.addNewTaskButtonTapped()
        } else {
            output.infoButtonTapped(index: indexPath.row)
        }
    }

    func didTapCheckbox(in cell: CustomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        output.checkButtonTapped(index: indexPath.row)
    }

}

private extension TodoListViewController {

    func setupBottomButton() {
        let imageView = UIImageView(image: UIImage(named: "Plus"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 22
        imageView.contentMode = .scaleAspectFit

        imageView.layer.shadowColor = UIColor(named: "Blue")?.cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 8)
        imageView.layer.shadowRadius = 20
        view.addSubview(imageView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(plusButtonTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 44),
            imageView.heightAnchor.constraint(equalToConstant: 44),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func plusButtonTapped() {
        output?.addNewTaskButtonTapped()
    }

    @objc private func changeTasksVisibility() {
        output?.toggleCompletedTasksVisibility()
    }

}
