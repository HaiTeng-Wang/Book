import UIKit
import Combine

class Person {
    @Published var name: String

    init(name: String) {
        self.name = name
    }
}

// 这里的练习是为了验证，通过Combine来实现对数组元素值的观察。 以下内容来自 deepseek。同时延伸了tableView的DiffableDataSourc 练习，关于这同时可参考：[UITableView学习笔记一-差量数据源](https://fanthus.github.io/2023/02/07/uitableview-学习笔记-1/)。

class CombineTestViewController: UIViewController {

    // 数据源
    private var persons: [Person] = []

    // Combine 订阅存储
    private var cancellables = Set<AnyCancellable>()

    // UI 组件
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Int, UUID>!
    private var personMap: [UUID: Person] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        setupCombineObservers()
    }

    private func setupUI() {
        title = "Person 观察器"
        view.backgroundColor = .systemBackground

        // 配置表格视图
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        // 创建数据源
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, itemID in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

            if let person = self?.personMap[itemID] {
                cell.textLabel?.text = "\(indexPath.row + 1). \(person.name)"
                cell.textLabel?.font = .systemFont(ofSize: 18)

                // 添加随机颜色背景
                let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple]
                let color = colors[indexPath.row % colors.count].withAlphaComponent(0.1)
                cell.backgroundColor = color
            }

            return cell
        }

        // 添加底部按钮
        let button = UIButton(type: .system)
        button.setTitle("随机修改名称", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(changeRandomName), for: .touchUpInside)

        button.frame = CGRect(x: 20, y: view.bounds.height - 100, width: view.bounds.width - 40, height: 50)
        view.addSubview(button)
    }

    private func setupData() {
        // 创建初始数据
        persons = [
            Person(name: "Alice"),
            Person(name: "Bob"),
            Person(name: "Charlie"),
            Person(name: "Diana"),
            Person(name: "Ethan")
        ]

        // 创建ID到Person的映射
        personMap = [:]
        for person in persons {
            let id = UUID()
            personMap[id] = person
        }

        // 应用初始快照
        applySnapshot()
    }

    private func setupCombineObservers() {
        // 为每个Person的name属性创建观察者
        for person in persons {
            // 观察name属性的变化
            person.$name
                .dropFirst() // 忽略初始值
                .sink { [weak self] newValue in
                    print("检测到变化: \(person.name)")
                    self?.applySnapshot()
                }
                .store(in: &cancellables) // 存储订阅
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])

        // 获取所有Person的ID
        let personIDs = personMap.keys.sorted(by: { $0.uuidString < $1.uuidString })
        snapshot.appendItems(personIDs)

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // 随机修改一个Person的名称
    @objc private func changeRandomName() {
        guard let randomPerson = persons.randomElement() else { return }

        let names = ["Alex", "Taylor", "Jordan", "Morgan", "Casey", "Riley", "Quinn", "Avery"]
        let randomName = names.randomElement() ?? "New Name"

        randomPerson.name = randomName

    }

    deinit {
        // 取消所有订阅（实际在Set释放时会自动取消）
        cancellables.forEach { $0.cancel() }
    }
}
