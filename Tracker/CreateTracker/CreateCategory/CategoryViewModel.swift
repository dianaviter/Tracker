import Foundation

final class CategoryViewModel {

    // MARK: - Properties

    private let trackerCategoryStore: TrackerCategoryStore

    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?(categories)
        }
    }

    var selectedCategory: TrackerCategory? {
        didSet {
            onSelectedCategoryChanged?(selectedCategory)
        }
    }

    // MARK: - Bindings

    var onCategoriesChanged: (([TrackerCategory]) -> Void)?
    var onSelectedCategoryChanged: ((TrackerCategory?) -> Void)?
    var onCategoryAdded: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?

    // MARK: - Init

    init(store: TrackerCategoryStore) {
        self.trackerCategoryStore = store
        self.trackerCategoryStore.delegate = self
        fetchCategories()
    }

    // MARK: - Public Methods

    func fetchCategories() {
        categories = trackerCategoryStore.trackerCategories()
    }

    func selectCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        let category = categories[index]
        selectedCategory = category
        onSelectedCategoryChanged?(category)
    }

    func category(at index: Int) -> TrackerCategory? {
        guard categories.indices.contains(index) else { return nil }
        return categories[index]
    }

    func numberOfCategories() -> Int {
        return categories.count
    }

    func addCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryStore.addTrackerCategory(category)
            onCategoryAdded?()
        } catch {
            print("Failed to add category: \(error)")
        }
    }

    func titleForCell(at index: Int) -> String {
        return category(at: index)?.header ?? ""
    }

    func isSelected(at index: Int) -> Bool {
        return category(at: index)?.header == selectedCategory?.header
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        fetchCategories()
    }
}
