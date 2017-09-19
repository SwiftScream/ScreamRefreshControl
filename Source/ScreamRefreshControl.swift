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

open class ScreamRefreshControl : UIRefreshControl {
    enum State {
        case idle
        case refreshing
        case resetting
    }

    public let contentView: UIView = UIView()
    var contentOffsetObservation: NSKeyValueObservation?
    var scrollView: UIScrollView?
    var refreshState: State = .idle

    public override init() {
        super.init()

        contentView.backgroundColor = .clear
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        addTarget(self, action: #selector(onRefreshTriggered), for: .valueChanged)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding unsupported")
    }

    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        // Remove default views ;)
        if (subview != contentView) {
            subview.alpha = 0
        }
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let scrollView = superview as? UIScrollView else {
            return
        }

        self.scrollView = scrollView
        contentOffsetObservation = scrollView.observe(\.contentOffset) { [unowned self] (scrollview, value) in
            switch(self.refreshState) {
            case .idle:
                let distance = -self.frame.origin.y
                let ratio = max(0,min(1.0, Float(distance / self.triggerDistance())))
                self.updateTriggerProgress(ratio)
            case .refreshing:
                break;
            case .resetting:
                let distance = -self.frame.origin.y
                if (distance < 0.01) {
                    self.refreshState = .idle
                }
                break;
            }
        }
    }

    private func triggerDistance() -> CGFloat {
        guard let scrollView = self.scrollView else {
            return 100;
        }
        return max(74, scrollView.frame.size.height * 0.198)
    }

    open func updateTriggerProgress(_ progress: Float) {
    }

    open func beginRefreshAnimation() {
    }

    open func endRefreshAnimation() {
    }

    @objc func onRefreshTriggered() {
        updateTriggerProgress(1.0)
        beginRefreshAnimation()
        refreshState = .refreshing
    }

    override open func beginRefreshing() {
        let wasRefreshing = isRefreshing;
        super.beginRefreshing()
        if (!wasRefreshing) {
            onRefreshTriggered()
        }
    }

    override open func endRefreshing() {
        super.endRefreshing()
        endRefreshAnimation();
        refreshState = .resetting
    }
}

extension ScreamRefreshControl {
    override open var tintColor: UIColor! {
        didSet {
            tintColorDidChange()
        }
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        contentView.tintColor = tintColor
    }
}
