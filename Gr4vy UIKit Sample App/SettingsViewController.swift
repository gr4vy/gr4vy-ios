//
//  SettingsViewController.swift
//  Gr4vy UIKit Sample App
//
//  Created by Gr4vy
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var currencyPickerView: UIPickerView!
    var currencyTypes: [String] = ["GBP", "USD"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currencyPickerView.delegate = self
        self.currencyPickerView.dataSource = self
        navigationItem.title = "Settings"
        // Do any additional setup after loading the view.
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyTypes[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(currencyTypes[row], forKey: "Currency")
    }
}
