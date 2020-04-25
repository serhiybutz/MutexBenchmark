//
//  ViewController.swift
//  MutexBenchmarkContendedIOS
//
//  Created by Serge Bouts on 4/25/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import UIKit
import XConcurrencyKit
import Mutexes

class ViewController: UIViewController {

    @IBOutlet weak var runButton: UIButton!

    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBAction func runButtonAction(_ sender: Any) {
        textView.text = ""
        runButton.isEnabled = false
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        DispatchQueue.global().async {
            let resultLog = runContended(renderingAs: .numbersChartData)
            DispatchQueue.main.sync {
                self.runButton.isEnabled = true
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                self.textView.text += resultLog
            }
        }
    }
}