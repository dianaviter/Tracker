import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    
    var onFinish: (() -> Void)?
    
    
    // MARK: - UI Elements
    
    private lazy var onboardingPages: [UIViewController] = {
        let page1 = UIViewController()
        let page2 = UIViewController()
        return [page1, page2]
    }()
    
    private let onboardingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("onboarding.button.title", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .black
        return button
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = onboardingPages.count
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = .gray
        return pc
    }()
    
    let backgroundImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    
    // MARK: - Lifecycle
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = onboardingPages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
        
        onboardingButton.addTarget(self, action: #selector(onboardingButtonTapped(_:)), for: .touchUpInside)
        
        setUpConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func onboardingButtonTapped(_ sender: UIButton) {
        onFinish?()
    }
    
    // MARK: - Layout
    
    private func setUpConstraints() {
        [onboardingButton, textLabel, backgroundImage, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(backgroundImage)
        view.addSubview(onboardingButton)
        view.addSubview(textLabel)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -130),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -24)
        ])
        
        setUpOnboardingScreen()
    }
    
    private func setUpOnboardingScreen() {
        guard let currentVC = viewControllers?.first,
              let index = onboardingPages.firstIndex(of: currentVC) else { return }
        
        if index == 0 {
            textLabel.text = NSLocalizedString("onboarding.page1.text", comment: "")
            backgroundImage.image = UIImage(named: "Onboarding1")
        } else {
            textLabel.text = NSLocalizedString("onboarding.page2.text", comment: "")
            backgroundImage.image = UIImage(named: "Onboarding2")
        }
    }
}


// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = onboardingPages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = currentIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        return onboardingPages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = onboardingPages.firstIndex(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1

        guard nextIndex < onboardingPages.count else {
            return nil
        }

        return onboardingPages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = onboardingPages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
        
        if completed {
            setUpOnboardingScreen()
        }
    }
}
