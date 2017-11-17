//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


// Coordinator Protocol

protocol Coordinating: class {
    associatedtype ViewController: UIViewController
    var viewController: ViewController? { get set }
    var root: UIViewController { get }
    func createViewController() -> ViewController
    func configure(_ vc: ViewController)
    func show(_ vc: ViewController)
    func dismiss()
}

extension Coordinating {
    func configure(_ vc: ViewController) {
    }
    func show(_ vc: ViewController) {
        root.show(vc, sender: self)
    }
    func dismiss() {
        root.dismiss(animated: true, completion: nil)
    }
}

extension Coordinating {
    
    func start() {
        let vc = createViewController()
        configure(vc)
        show(vc)
        viewController = vc
    }
    
    func stop() {
        dismiss()
        viewController = nil
    }
}


// ViewControllers

class HomeViewController: UITableViewController {
    
    var didSelectRow: ((IndexPath) -> Void)?
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "someCell")
        self.title = "Home"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "someCell")!
        cell.textLabel?.text = "\(indexPath.row+1)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow?(indexPath)
    }
}

class MoreViewController: UITableViewController {
    
    var didSelectRow: ((Int) -> Void)?
    
    var items: [Int] = []
    
    convenience init(style: UITableViewStyle, index: Int) {
        self.init(style: style)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "someCell")
        self.title = "\(index)"
        
        for i in 0..<10 {
            let item = index*10 + i
            items.append(item)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "someCell")!
        cell.textLabel?.text = "\(items[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = items[indexPath.row]
        didSelectRow?(index)
    }
}

class DetailViewController: UIViewController {
    
    convenience init(index: Int) {
        self.init()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let label = UILabel(frame: CGRect(x: 150, y: 200, width: 100, height: 100))
        label.font = UIFont.boldSystemFont(ofSize: 46)
        label.textAlignment = .center
        label.text = "\(index)"
        view.addSubview(label)
    }
}



// Custom Coordinators for ViewControllers

class HomeCoordinator: Coordinating {
    
    var viewController: HomeViewController?
    let root: UIViewController
    init(root: UIViewController) {
        self.root = root
    }
    func createViewController() -> HomeViewController {
        return HomeViewController(style: .grouped)
    }
    
    func configure(_ vc: HomeViewController) {
        vc.didSelectRow = didSelectRow(at:)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let index = indexPath.row + 1
        let moreVC = MoreCoordinator(root: root, index: index)
        moreVC.start()
    }
}

class MoreCoordinator: Coordinating {
    
    var viewController: MoreViewController?
    let root: UIViewController
    let index: Int
    init(root: UIViewController, index: Int) {
        self.root = root
        self.index = index
    }
    func createViewController() -> MoreViewController {
        return MoreViewController(style: .grouped, index: index)
    }
    
    func configure(_ vc: MoreViewController) {
        vc.didSelectRow = didSelectRow(at:)
    }
    
    func didSelectRow(at indexPath: Int) {
        let detailCoordinator = DetailCoordinator(root: root, index: indexPath)
        detailCoordinator.start()
    }
}

class DetailCoordinator: Coordinating {
    
    var viewController: DetailViewController?
    let root: UIViewController
    let index: Int
    init(root: UIViewController, index: Int) {
        self.root = root
        self.index = index
    }
    func createViewController() -> DetailViewController {
        return DetailViewController(index: index)
    }
}

// Starting the presentation.

let nav = UINavigationController()
let coordinator = HomeCoordinator(root: nav)
PlaygroundPage.current.liveView = nav
coordinator.start()
