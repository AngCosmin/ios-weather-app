import UIKit


protocol ChangeCityDelegate {
    func userEnteredNewCityName(city: String)
}


class ChangeCityViewController: UIViewController {
    var delegate: ChangeCityDelegate?

    @IBOutlet weak var changeCityTextField: UITextField!

    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredNewCityName(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
