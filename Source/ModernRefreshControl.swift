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

open class ModernRefreshControl : ScreamRefreshControl {
    private var spinnerView: NewSpinnerView

    public override init() {
        spinnerView = NewSpinnerView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

        super.init()

        contentView.addSubview(spinnerView)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding unsupported")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        spinnerView.center = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
    }

    open override func updateTriggerProgress(_ progress: Float) {
        spinnerView.progress = progress;
    }

    open override func beginRefreshAnimation() {
        spinnerView.beginAnimating()
    }

    open override func endRefreshAnimation() {
        spinnerView.endAnimating()
    }
}

extension ModernRefreshControl {
    private class NewSpinnerView : UIView {

        override class var layerClass: AnyClass {
            get {
                return CAShapeLayer.self
            }
        }

        override var layer: CAShapeLayer {
            get {
                return super.layer as! CAShapeLayer
            }
        }

        override init(frame: CGRect) {
            progress = 1.0

            super.init(frame: frame)

            layer.lineWidth = 1
            layer.fillColor = nil
            layer.strokeColor = tintColor.cgColor
            layer.strokeStart = 0
            layer.strokeEnd = 0
            layer.path = self.path
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("NSCoding unsupported")
        }

        override func tintColorDidChange() {
            super.tintColorDidChange()
            layer.strokeColor = tintColor.cgColor
        }

        private var path: CGPath {
            get {
                let size = min(self.bounds.size.width, self.bounds.size.height);
                let radius = (size-2) / 2.0;
                let startAngle = CGFloat(-Double.pi / 2);
                let endAngle = startAngle + CGFloat((2 * Double.pi));
                let center = CGPoint(x: bounds.midX, y: bounds.midY)
                return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
            }
        }

        var progress: Float {
            didSet {
                assert(0 <= progress)
                assert(progress <= 1)
                layer.strokeEnd = CGFloat(progress)
                layer.strokeStart = CGFloat(progress * 0.15)
            }
        }

        func beginAnimating() {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.byValue = Double.pi * 2.0;
            rotationAnimation.duration = 0.8;
            rotationAnimation.repeatCount = .greatestFiniteMagnitude;
            layer.add(rotationAnimation, forKey: "rotation")

            let pulseScaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseScaleAnimation.toValue = 1.18
            pulseScaleAnimation.duration = 0.1
            pulseScaleAnimation.autoreverses = true
            layer.add(pulseScaleAnimation, forKey: "pulseScale")

            let pulseWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
            pulseWidthAnimation.toValue = 2
            pulseWidthAnimation.duration = 0.1
            pulseWidthAnimation.autoreverses = true
            layer.add(pulseWidthAnimation, forKey: "pulseWidth")
        }

        func endAnimating() {
            CATransaction.begin()

            CATransaction.setCompletionBlock {
                self.layer.opacity = 1
                self.layer.strokeStart = 0
                self.layer.strokeEnd = 0
                self.layer.removeAnimation(forKey: "rotation")
            }

            CATransaction.setAnimationDuration(0.3)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))

            let strokeAnimation = CABasicAnimation(keyPath: "strokeStart")
            strokeAnimation.fromValue = 0.15
            strokeAnimation.toValue = 1
            layer.add(strokeAnimation, forKey: "strokeStart")

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1
            opacityAnimation.toValue = 0
            layer.add(opacityAnimation, forKey: "opacity")
            self.layer.opacity = 0;

            CATransaction.commit()
        }
    }
}
