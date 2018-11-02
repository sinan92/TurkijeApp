//
//  ValutaController.swift
//  Turkije App
//
//  Created by Sinan Samet on 31/10/2018.
//  Copyright © 2018 Sinan Samet. All rights reserved.
//

import UIKit

class ValutaController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //Get list
        let url = URL(string: "https://frankfurter.app/latest?from=EUR")
        var request = NSMutableURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: Double.infinity)
        if Reachability.isConnectedToNetwork(){
            request = NSMutableURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Double.infinity);
        }
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest,
                                    completionHandler: { data, response, error -> Void in
                                        do {
                                            
                                            let jsonDecoder = JSONDecoder()
                                            self.valutas = try [jsonDecoder.decode(ValutaWaarde.self, from: data!)]
                                            
                                        } catch { print(error) }
        })
        task.resume()
    }
    
    @IBOutlet weak var euro: UILabel!
    @IBOutlet weak var lira: UILabel!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    var valutas : [ValutaWaarde] = []
    
    var number = 0;
    var isTypingNumber = false
    var currentNumber = 0;
    var currency = "TRY";
    
    @IBAction func numberTapped(_ sender: AnyObject) {
        let number = sender.currentTitle!
        var disable = false
        
        if number == "."{
            if euro.text!.range(of: ".") != nil{
                disable = true
            }
        }
        
        if(disable == false){
            if isTypingNumber {
                euro.text = euro.text!+number!
            } else {
                euro.text = number
                isTypingNumber = true
            }
            
            
            var output : Float
            let euroText = Float(euro.text!)!
            if(currency == "EUR"){
                output = euroText/Float((valutas[0].rates?.tr!)!)
            }
            else{
                output = euroText*Float((valutas[0].rates?.tr!)!)
            }
            
            lira.text = String(format: "%.2f", output)
        }
    }
    
    @IBAction func resetCalculator(_ sender: Any) {
        isTypingNumber = false
        lira.text = "0"
        euro.text = "0"
    }
    
    @IBAction func backspace(_ sender: Any) {
        if euro.text != ""{
            euro.text = String(euro.text!.dropLast())
            
            var output : Float;
            if(currency == "EUR"){
                output = (euro.text! as NSString).floatValue/Float((valutas[0].rates?.tr!)!)
            }
            else{
                output = (euro.text! as NSString).floatValue*Float((valutas[0].rates?.tr!)!)
            }
            
            lira.text = String(format: "%.2f", output)
            
            if(euro.text == ""){
                isTypingNumber = false
                euro.text = "0"
            }
            if(lira.text == "0.00"){
                lira.text = "0"
            }
        }
    }
    
    @IBAction func switchCurrency(_ sender: Any) {
        //Reset calculator
        isTypingNumber = false;
        lira.text = "0";
        euro.text = "0";
        
        //Change currency
        if currency == "TRY"{
            //Change to EURO
            topButton.setTitle("LIRA", for: [])
            bottomButton.setTitle("EURO", for: [])
            currency = "EUR"
        }
        else{
            //Change to LIRA
            topButton.setTitle("EURO", for: [])
            bottomButton.setTitle("LIRA", for: [])
            currency = "TRY"
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
