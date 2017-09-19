//   Copyright 2017 Alex Deem
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

import UIKit
import Dispatch
import ScreamRefreshControl

class ViewController: UIViewController {
    private var tableView: UITableView?

    override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.refreshControl = ModernRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(ViewController.didPullToRefresh), for: .valueChanged)
        self.tableView = tableView

        view.addSubview(tableView)
        self.view = view
    }

    @objc func didPullToRefresh() {
        let duration = DispatchTimeInterval.milliseconds(Int(arc4random_uniform(4000)))
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.tableView?.refreshControl?.endRefreshing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath.row)"
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.refreshControl?.beginRefreshing()
        self.didPullToRefresh()
    }
}
