import UIKit

final class CategoryViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CategoryViewModel
    private let cellIdentifier = "cell"
    private var tableViewHeightConstraint: NSLayoutConstraint?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    private var preselectedCategory: TrackerCategory?


    // MARK: - Init

    init(viewModel: CategoryViewModel, selectedCategory: TrackerCategory?) {
        self.viewModel = viewModel
        self.preselectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Elements

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .trackerBackground
        tableView.backgroundView = backgroundView
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 75
        return tableView
    }()

    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("categoryview.addcategory.button", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .trackerBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categoryview.title", comment: "")
        label.textColor = .trackerBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhite

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true

        viewModel.onCategoriesChanged = { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateTableHeight()
        }

        viewModel.onSelectedCategoryChanged = { [weak self] selected in
            guard let selected = selected else { return }
            self?.onCategorySelected?(selected)
            self?.dismiss(animated: true)
        }

        viewModel.fetchCategories()
        createButton.addTarget(self, action: #selector(addCategoryButtonTapped(_:)), for: .touchUpInside)

        setUpConstraints()
    }

    // MARK: - Actions

    @objc private func addCategoryButtonTapped(_ sender: UIButton) {
        let vc = CreateNewCategoryViewController()
        vc.onCategoryCreated = { [weak self] newCategory in
            self?.viewModel.addCategory(newCategory)
        }
        present(vc, animated: true)
    }

    // MARK: - Layout

    private func updateTableHeight() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint?.constant = tableView.contentSize.height
    }

    private func setUpConstraints() {
        [textLabel, createButton, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        guard let category = viewModel.category(at: indexPath.row) else { return cell }

        cell.textLabel?.text = category.header
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .trackerBackground
        cell.accessoryType = category.header == preselectedCategory?.header ? .checkmark : .none

        if indexPath.row == viewModel.numberOfCategories() - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let category = viewModel.category(at: indexPath.row) else { return }
        onCategorySelected?(category)
        dismiss(animated: true)
    }
}
