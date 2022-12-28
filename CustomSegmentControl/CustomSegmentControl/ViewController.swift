//
//  ViewController.swift
//  CustomSegmentControl
//
//  Created by Sawan Rana on 19/07/22.
//

import UIKit

/* texts: ["Hi anuj and sawan! Happy Coding",
"Hi Pankaj Udhas",
"HI Devilal Prasad"]
 */

typealias AnimationCompletion = (() -> ())?

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pressIt: UIButton!
    
    @IBAction func buttonTouchAction(_ sender: Any) {
        pressIt.isEnabled = false
        label.animatePrint(text: "Hi Sawan Rana!", delay: 0.2) {
            self.pressIt.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Custom Segement Control"
        label.animatePrint(text: "Hi sawan! Happy Coding", delay: 0.2) {
//            self.label.animatePrint(text: "Everything is fine", delay: 0.1, completion: nil)
        }

    }

}

extension UILabel {
    func animatePrint(text: String, delay: Double, completion: AnimationCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.text = ""
            var charIndex = 0.0
            for letter in text {
                Timer.scheduledTimer(withTimeInterval: 0.2 * charIndex, repeats: false) { (timer) in
                    self.text?.append(letter)
                    if text == self.text {
                        print("Job done")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                           charIndex = 0.0
                            for _ in text {
                                Timer.scheduledTimer(withTimeInterval: 0.2 * charIndex, repeats: false) { (timer) in
                                    self.text?.removeLast()
                                    if self.text == "" {
                                        print("Deleted")
                                    }
                                }
                                charIndex += 1
                            }
                        }
                    }
                }
                charIndex += 1
            }
        }
    }
    
}

@IBDesignable
class CustomSegmentedControl: UIControl {
    
    private var segmentButtons = [UIButton]()
    private var selectorView: UIView!
    var selectedSegmentIndex = 0
    
    @IBInspectable
    var leading: CGFloat = 0.0 {
        didSet {
            updateSegmentedControl()
        }
    }
    
    @IBInspectable
    var trailing: CGFloat = 0.0 {
        didSet {
            updateSegmentedControl()
        }
    }
    
    @IBInspectable
    var insets: CGFloat = 2.0 {
        didSet {
            updateSegmentedControl()
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .red {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = .red {
        didSet {
            updateSegmentedControl()
        }
    }
    
    @IBInspectable
    var selectorTextColor: UIColor = .red {
        didSet {
            updateSegmentedControl()
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .red {
        didSet {
            updateSegmentedControl()
        }
    }
    
    // Please mention titles as comma separated
    @IBInspectable
    var buttonTitlesCommaSeparated: String = "" {
        didSet {
            updateSegmentedControl()
        }
    }
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = frame.height/2
    }
    
    func updateSegmentedControl() {
        // Return if button are empty
        if buttonTitlesCommaSeparated.isEmpty {
            return
        }
        
        // Since many view get added multiple time, so we need to remove them everytime we add new views
        segmentButtons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = buttonTitlesCommaSeparated.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles {
            if !buttonTitle.isEmpty {
                let button = UIButton(type: .custom)
                let attributedString = attributedStringForTextColor(buttonTitle: buttonTitle)
                button.setAttributedTitle(attributedString, for: .normal)
                button.addTarget(self, action: #selector(segmentButtonTapped(sender:)), for: .touchUpInside)
                segmentButtons.append(button)
            }
            
            // If button title is empty, so no new button get created
        }
        
        // Setting up first button
        let button = segmentButtons[selectedSegmentIndex]
        button.setAttributedTitle(attributedStringForTextColor(buttonTitle: button.titleLabel?.text ?? "", forTextColor: false), for: .normal)
        
        let selectorViewWidth = (UIScreen.main.bounds.width - (leading + trailing)) / CGFloat(segmentButtons.count)
        let selectorViewPosition = (((UIScreen.main.bounds.width - (leading + trailing)) / CGFloat(segmentButtons.count)) * CGFloat(selectedSegmentIndex))
        
        selectorView = UIView(frame:
                                CGRect(x: selectorViewPosition,
                                       y: 0,
                                       width: selectorViewWidth,
                                       height: frame.height))
        selectorView.bounds = selectorView.bounds.insetBy(dx: insets, dy: insets)
        selectorView.layer.cornerRadius = selectorView.bounds.height / 2
        selectorView.backgroundColor = selectorColor
        addSubview(selectorView)
        
        let horizonatalStackView = UIStackView(arrangedSubviews: segmentButtons)
        horizonatalStackView.axis = .horizontal
        horizonatalStackView.alignment = .fill
        horizonatalStackView.distribution = .fillEqually
        horizonatalStackView.spacing = 0
        addSubview(horizonatalStackView)
        horizonatalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizonatalStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        horizonatalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizonatalStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        horizonatalStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }
    
    @objc
    private func segmentButtonTapped(sender: UIButton) {
        segmentButtons.enumerated().forEach { (buttonIndex, button) in
            
            if sender == button {
                selectedSegmentIndex = buttonIndex
                let selectorViewPosition = (((UIScreen.main.bounds.width - (leading + trailing)) / CGFloat(segmentButtons.count)) * CGFloat(buttonIndex)) + CGFloat(insets)
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.selectorView.frame.origin.x = selectorViewPosition
                } completion: { [weak self] success in
                    if success {
                        button.setAttributedTitle(self?.attributedStringForTextColor(buttonTitle: button.titleLabel?.text ?? "", forTextColor: false), for: .normal)
                    }
                }
                
            } else {
                button.setAttributedTitle(attributedStringForTextColor(buttonTitle: button.titleLabel?.text ?? ""), for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
    
    private func attributedStringForTextColor(buttonTitle: String, forTextColor: Bool = true) -> NSAttributedString {
        var attributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 12), NSAttributedString.Key.foregroundColor: textColor]
        if !forTextColor {
            attributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 12), NSAttributedString.Key.foregroundColor: selectorTextColor]
        }
        let attributedString = NSAttributedString(string: buttonTitle, attributes: attributes as [NSAttributedString.Key : Any])
        return attributedString
    }
    
}
