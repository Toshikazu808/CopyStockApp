//
//  PannelVC.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit

class PannelVC: UIViewController {
   // Child ViewController Example
   override func viewDidLoad() {
      super.viewDidLoad()
      let grabberView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
      grabberView.backgroundColor = .label
      view.addSubview(grabberView)
      grabberView.center = CGPoint(x: view.center.x, y: 5)
      view.backgroundColor = .secondarySystemBackground      
   }   
}
