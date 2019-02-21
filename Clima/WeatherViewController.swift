import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a082312319a351eb2c17b0c756965962"

    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    //MARK: - Networking
    /***************************************************************/

    func getWeatherData(parameters: [String : String]) {
        Alamofire.request(WEATHER_URL, method: .get, parameters: parameters).responseJSON {response in
            if (response.result.isSuccess) {
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("There was an error!")
                print(response.result.error!)
                self.cityLabel.text = "Connection problem"
            }
        }
    }

    //MARK: - JSON Parsing
    /***************************************************************/

    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
    }

    //MARK: - UI Updates
    /***************************************************************/
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        if location!.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location!.coordinate.latitude)
            let longitude = String(location!.coordinate.longitude)
            let params: [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error)
        cityLabel.text = "Can't find location"
    }

    func userEnteredNewCityName(city: String) {
        let params: [String : String] = ["q": city, "appid": APP_ID]
        getWeatherData(parameters: params)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}
