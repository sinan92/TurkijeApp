//
//  CityDetails.swift
//  Ontdek Polen
//
//  Created by Sinan Samet on 03-08-15.
//  Copyright (c) 2015 Visiamedia. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

class Weer: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var weatherByDayLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dateNowLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var bgScrollView: UIScrollView!
    var weerItems3Uur : [HourlyWeatherItem] = []
    var weerItemsDag : [DailyWeatherItem] = []
    let synth = AVSpeechSynthesizer()
    var temperature : Double?
    var myUtterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        if(!Reachability.isConnectedToNetwork()){
            self.showAlert(title: "Geen internet", message: "Je kunt deze pagina niet bekijken zonder internet.")
        }
        
        bgScrollView.backgroundColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 0)
        super.viewDidLoad()
        let cityName = UserDefaults.standard.object(forKey: "cityName") as! String
        
        //Get weather data per day
        let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?q=\(cityName),TR&mode=json&units=metric&cnt=5&appid=e9f26957dec64c48ded799a531fe9609")
        var request = URLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: Double.infinity)
        if Reachability.isConnectedToNetwork(){
            request = URLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Double.infinity);
        }
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest,
            completionHandler: { data, response, error -> Void in
                do {
                        let jsonDecoder = JSONDecoder()
                        guard let dataValues = data else {
                            self.showAlert(title: "Geen internet", message: "Je kunt deze pagina niet bekijken zonder internet.")
                            return
                        }
                        self.weerItemsDag = try [jsonDecoder.decode(DailyWeatherItem.self, from: dataValues)]
                    
                        //Retrieved JSON
                        //Get daily weather items
                        self.getDailyWeatherItems(cityName: cityName)
                    
                } catch { print(error) }
        })
        task.resume()
        
        //Get weather data per 3 hours
        let url2 = URL(string: "http://api.openweathermap.org/data/2.5/forecast?q=\(cityName),TR&mode=json&units=metric&appid=e9f26957dec64c48ded799a531fe9609")
        var request2 = NSMutableURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: Double.infinity)
        if Reachability.isConnectedToNetwork(){
            request2 = NSMutableURLRequest(url: url2! as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Double.infinity);
        }
        let session2 = URLSession.shared
        
        let task2 = session2.dataTask(with: request2 as URLRequest,
            completionHandler: { data, response, error -> Void in
                do {
                        let jsonDecoder = JSONDecoder()
                        guard let dataValues = data else {
                            self.showAlert(title: "Geen internet", message: "Je kunt deze pagina niet bekijken zonder internet.")
                            return
                        }
                        self.weerItems3Uur = try [jsonDecoder.decode(HourlyWeatherItem.self, from: dataValues)]
                    
                        //Retrieved JSON
                        //Get weather items and define static values of the day
                    
                        DispatchQueue.main.async {
                            self.getWeatherItemsPer3Hours(cityName: cityName)
                        }
                    
                } catch { print(error) }
        })
        task2.resume()

    }
    
    func roundToPlaces(value:Double, places:Int) -> Int {
        let divisor = pow(10.0, Double(places))
        return Int(round(value * divisor) / divisor)
    }
    
    func getDayOfWeek(date: NSDate)->String? {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let myComponents = myCalendar?.components(NSCalendar.Unit.weekday, from: date as Date)
        let weekDay = myComponents?.weekday
        return weekNumberToWord(weekDay: weekDay!)
    }
    
    func weekNumberToWord(weekDay: Int) -> String{
        switch weekDay{
        case 1:
            return "Zondag"
        case 2:
            return "Maandag"
        case 3:
            return "Dinsdag"
        case 4:
            return "Woensdag"
        case 5:
            return "Donderdag"
        case 6:
            return "Vrijdag"
        case 7:
            return "Zaterdag"
        default:
            return "Onbekend"
        }
    }
    
    //Weather icons
    func getWeatherIconById(id: Int) -> [String:String]{
        var weatherType = [String : String]()
        switch id{
        case 200...232:
            weatherType["icon"] = "storming.png"
            weatherType["icon-large"] = "white-storming.png"
            weatherType["bg"] = "bg-storming.png"
            weatherType["color"] = "white"
        case 300...321:
            weatherType["icon"] = "rainy.png" //Drizzle
            weatherType["icon-large"] = "large-rainy.png"
            weatherType["bg"] = "bg-rainy.png"
            weatherType["color"] = "black"
        case 500...522:
            weatherType["icon"] = "rainy.png"
            weatherType["icon-large"] = "large-rainy.png"
            weatherType["bg"] = "bg-rainy.png"
            weatherType["color"] = "black"
        case 600...621:
            weatherType["icon"] = "winter.png"
            weatherType["icon-large"] = "large-winter.png"
            weatherType["bg"] = "bg-winter.png"
            weatherType["color"] = "black"
        case 701...741:
            weatherType["icon"] = "misty.png"
            weatherType["icon-large"] = "white-misty.png"
            weatherType["bg"] = "bg-misty.png"
            weatherType["color"] = "white"
        case 800:
            weatherType["icon"] = "sunny.png"
            weatherType["icon-large"] = "large-sunny.png"
            weatherType["bg"] = "bg-sunny.png"
            weatherType["color"] = "black"
        case 801:
            weatherType["icon"] = "fewclouds.png"
            weatherType["icon-large"] = "white-fewclouds.png"
            weatherType["bg"] = "bg-fewclouds.png"
            weatherType["color"] = "white"
        case 802...804:
            weatherType["icon"] = "clouds.png"
            weatherType["icon-large"] = "white-clouds.png"
            weatherType["bg"] = "bg-clouds.png"
            weatherType["color"] = "white"
        case 900:
            weatherType["icon"] = "tornado.png"
            weatherType["icon-large"] = "large-tornado.png"
            weatherType["bg"] = "bg-tornado.png"
            weatherType["color"] = "black"
        case 901:
            weatherType["icon"] = "rainy.png"
            weatherType["icon-large"] = "large-rainy.png"
            weatherType["bg"] = "bg-rainy.png"
            weatherType["color"] = "black"
        case 902:
            weatherType["icon"] = "tornado.png"
            weatherType["icon-large"] = "white-tornado.png"
            weatherType["bg"] = "bg-tornado.png"
            weatherType["color"] = "white"
        case 903:
            weatherType["icon"] = "winter.png"
            weatherType["icon-large"] = "large-winter.png"
            weatherType["bg"] = "bg-winter.png"
            weatherType["color"] = "black"
        case 904:
            weatherType["icon"] = "sunny.png"
            weatherType["icon-large"] = "large-sunny.png"
            weatherType["bg"] = "bg-sunny.png"
            weatherType["color"] = "black"
        case 905:
            weatherType["icon"] = "wind.png"
            weatherType["icon-large"] = "large-wind.png"
            weatherType["bg"] = "bg-wind.png"
            weatherType["color"] = "black"
        case 906:
            weatherType["icon"] = "hail.png"
            weatherType["icon-large"] = "white-hail.png"
            weatherType["bg"] = "bg-hail.png"
            weatherType["color"] = "white"
        default:
            weatherType["icon"] = "clouds"
            weatherType["icon-large"] = "large-clouds.png"
            weatherType["bg"] = "bg-clouds.png"
            weatherType["color"] = "black"
        }
        
        return weatherType
    }
    
    func monthNumberToWord(month: Int) -> String{
        switch month{
        case 1:
            return "Januari"
        case 2:
            return "Februari"
        case 3:
            return "Maart"
        case 4:
            return "April"
        case 5:
            return "Mei"
        case 6:
            return "Juni"
        case 7:
            return "Juli"
        case 8:
            return "Augustus"
        case 9:
            return "September"
        case 10:
            return "Oktober"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return "Onbekend"
        }
    }
    
    func getDailyWeatherItems(cityName: String){ /****** Hier JSON Aanpassing *****/
        var coordinateY = 15
        for weer in self.weerItemsDag[0].list! {
            //Max and min degrees
            let max = String(roundToPlaces(value: weer.temp!.max!, places: 0))
            let min = String(roundToPlaces(value: weer.temp!.min!, places: 0))
            let imageId = getWeatherIconById(id: weer.weather![0].id!)
                    
            //Get day
            let timestamp = weer.dt
            let day = getDayOfWeek(date: NSDate(timeIntervalSince1970: Double(timestamp!)))!
                    
            createWeatherByDayItem(day: day, coordinateY: coordinateY, max: max, min: min, imageId: imageId)
                    
            coordinateY+=18
        }
    }
    
    func getWeatherItemsPer3Hours(cityName: String){
        //Get current date
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = monthNumberToWord(month: calendar.component(.month, from: date))

        //Get weerItems
        for weer in self.weerItems3Uur {
            let name = weer.city?.name
            let weatherType = weer.list![0].weather![0].id
            temperature = weer.list![0].main?.temp
            let largeWeatherImage = getWeatherIconById(id: weatherType!)["icon-large"]!
            let largeWeatherBg = getWeatherIconById(id: weatherType!)["bg"]!
        
            //Get main color
            var mainColor :  UIColor
                if(getWeatherIconById(id: weatherType!)["color"]! == "white"){
                    mainColor = UIColor.white;
            }
            else{
                mainColor = UIColor(red: CGFloat(51/255.0), green: 51/255, blue: 51/255, alpha: 1)
            }
            
            let dateNow = "Vandaag, \(day) \(month)".uppercased()
            
            dateNowLabel.text = dateNow
            cityNameLabel.text = name
            
            //Change template color
            dateNowLabel.textColor = mainColor
            cityNameLabel.textColor = mainColor
            temperatureLabel.textColor = mainColor
            
            weatherImageView.autoresizingMask = []
            weatherImageView.image = UIImage(named: largeWeatherImage)
            bgImage.image = UIImage(named: largeWeatherBg)
            
            //Add guassian blur to background
            guard let image = bgImage.image, let cgimg = image.cgImage else {
                print("imageView doesn't have an image!")
                return
            }
            let coreImage = CIImage(cgImage:cgimg)
            
            let h = coreImage.extent.size.height
            let w = coreImage.extent.size.width
 
            
            guard let radialMask = CIFilter(name:"CIRadialGradient") else {
                return
            }
            
            let imageCenter = CIVector(x:0.55 * w, y:0.6 * h)
            radialMask.setValue(imageCenter, forKey:kCIInputCenterKey)
            radialMask.setValue(0.2 * h, forKey:"inputRadius0")
            radialMask.setValue(0.3 * h, forKey:"inputRadius1")
            radialMask.setValue(CIColor(red:0, green:1, blue:0, alpha:0),
                                forKey:"inputColor0")
            radialMask.setValue(CIColor(red:0, green:1, blue:0, alpha:1),
                                forKey:"inputColor1")
            
            guard let maskedVariableBlur = CIFilter(name:"CIMaskedVariableBlur") else {
                print("CIMaskedVariableBlur does not exist")
                return 
            }
            maskedVariableBlur.setValue(coreImage, forKey: kCIInputImageKey)
            
            maskedVariableBlur.setValue(10, forKey: kCIInputRadiusKey)
            maskedVariableBlur.setValue(radialMask.outputImage, forKey: "inputMask")
            guard let selectivelyFocusedCIImage = maskedVariableBlur.outputImage else {
                print("Setting maskedVariableBlur failed")
                return
            }
            let ciCtx = CIContext()
            let cgiig = ciCtx.createCGImage(selectivelyFocusedCIImage, from: coreImage.extent)
            let uiImage = UIImage(cgImage: cgiig!)
            bgImage.image = uiImage
            
            temperatureLabel.text = String(stringInterpolationSegment: roundToPlaces(value: temperature ?? 0, places: 0))+"°"
        
            let contentWidth = 1620
            scrollView.contentSize = CGSize(width: contentWidth, height: 50)
            var xCoordinate = 30
            var listCount = 0;
            for listItem in weer.list! {
                let temp = String(roundToPlaces(value: (listItem.main?.temp ?? 0)!, places: 0))+"°"
                let timestamp = listItem.dt
                let imageId = getWeatherIconById(id: listItem.weather![0].id!)
                
                var time: String
                if listCount == 0{
                    time = "Nu"
                }
                else{
                    let hour = NSCalendar.current.component(.hour, from: Date(timeIntervalSince1970: Double(timestamp!)))
                    time = String(hour)
                }
                
                createWeatherItem(time: time, type: "marker", temp: temp, coordinateX: xCoordinate, imageId: imageId)
                xCoordinate+=40
                listCount += 1
            }
        
        }
    }
    
    func createWeatherItem(time: String, type: String, temp: String, coordinateX: Int, imageId: [String:String]){
        let grey = UIColor(red: CGFloat(51/255.0), green: 51/255, blue: 51/255, alpha: 1)
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 200, height: 21))
        let timeLabel = UILabel(frame: rect)
        timeLabel.center = CGPoint(x: coordinateX, y: 10)
        timeLabel.textAlignment = NSTextAlignment.center
        timeLabel.text = time
        timeLabel.textColor = grey
        timeLabel.font = UIFont(name: "Helvetica Neue", size: 9)
        self.scrollView.addSubview(timeLabel)
        
        let imageIcon = imageId["icon"]
        let image = UIImage(named: "red-\(imageIcon!)")
        let typeImage = UIImageView(image: image!)
        typeImage.frame = CGRect(x: coordinateX-10, y: 20, width: 20, height: 20)
        self.scrollView.addSubview(typeImage)
        
        let tempLabel = UILabel(frame: rect)
        tempLabel.center = CGPoint(x: coordinateX+2, y: 50)
        tempLabel.textAlignment = NSTextAlignment.center
        tempLabel.text = temp
        tempLabel.textColor = grey
        tempLabel.font = UIFont(name: "Helvetica Neue", size: 9)
        self.scrollView.addSubview(tempLabel)
    }
    
    func createWeatherByDayItem(day: String, coordinateY: Int, max: String, min: String, imageId: [String:String]){
        DispatchQueue.main.async {
            let grey = UIColor(red: CGFloat(160/255.0), green: 160/255, blue: 160/255, alpha: 1)
            var rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 80, height: 21))
            let dayLabel = UILabel(frame: rect)
            dayLabel.center = CGPoint(x: 60, y: coordinateY)
            dayLabel.textAlignment = NSTextAlignment.left
            dayLabel.text = day
            dayLabel.textColor = UIColor.white
            dayLabel.font = UIFont(name: "Helvetica Neue", size: 10)
            self.weatherByDayLabel.addSubview(dayLabel)
            
            guard let image = UIImage(named: imageId["icon"]!) else {
                self.showAlert(title: "Image not found", message: "The image could not be found.")
                return
            }
            let typeImage = UIImageView(image: image)
            typeImage.frame = CGRect(x: Int(self.view.frame.size.width/2), y: coordinateY-5, width: 12, height: 12)
            self.weatherByDayLabel.addSubview(typeImage)
            
            rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 18, height: 21))
            let maxLabel = UILabel(frame: rect)
            maxLabel.center = CGPoint(x: Int(self.view.frame.size.width - maxLabel.frame.size.width-28), y: coordinateY)
            maxLabel.textAlignment = NSTextAlignment.right
            maxLabel.text = max
            maxLabel.textColor = UIColor.white
            maxLabel.font = UIFont(name: "Helvetica Neue", size: 10)
            self.weatherByDayLabel.addSubview(maxLabel)
            
            let minLabel = UILabel(frame: rect)
            minLabel.center = CGPoint(x: Int(self.view.frame.size.width - maxLabel.frame.size.width-10), y: coordinateY)
            minLabel.textAlignment = NSTextAlignment.right
            minLabel.text = min
            minLabel.textColor = grey
            minLabel.font = UIFont(name: "Helvetica Neue", size: 10)
            self.weatherByDayLabel.addSubview(minLabel)
        }
    }
    
    @IBAction func selecteerRegioButton(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if(event!.subtype == .motionShake) {
            let textToSpeak = "Het is op het moment " + String(format: "%.0f",temperature!) + " graden in " + cityNameLabel.text!
            myUtterance = AVSpeechUtterance(string: textToSpeak)
            myUtterance.rate = 0.45
            myUtterance.voice = AVSpeechSynthesisVoice(language: "nl-NL")
            synth.speak(myUtterance)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.navigationController?.popViewController(animated: true)
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
}
