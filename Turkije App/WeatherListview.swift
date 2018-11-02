//
//  KaartListview.swift
//  Ontdek Polen
//
//  Created by Sinan Samet on 07-08-15.
//  Copyright (c) 2015 Visiamedia. All rights reserved.
//

import UIKit
import Foundation

class WeatherListview: UITableViewController {
    let cities = ["Istanbul", "Ankara", "Izmir", "Didim", "Kusadasi", "Antalya", "Alanya", "Edirne", "Konya", "Bodrum", "Canakkale", "Bursa", "Mardin", "Trabzon", "Adana", "Kayseri", "Mersin"]
    let kCellIdentifier = "CellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().isTranslucent = false;
        UINavigationBar.appearance().barTintColor = UIColor(red: CGFloat(51/255.0), green: 51/255, blue: 51/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        
        let red = UIView()
        red.backgroundColor = UIColor(red: CGFloat(51/255.0), green: 51/255, blue: 51/255, alpha: 1)
        
        UITableViewCell.appearance().selectedBackgroundView = red
        tableView.separatorInset = UIEdgeInsets.zero
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        //Get list
        return cities.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "city", for: indexPath)
        
        
        //Get list
       cell.textLabel!.text = cities[indexPath.row]
        cell.textLabel!.text = cell.textLabel!.text!.uppercased()
        cell.textLabel?.textColor = UIColor(red: CGFloat(51/255.0), green: 51/255, blue: 51/255, alpha: 1)
        cell.textLabel!.highlightedTextColor = UIColor.white
        let chevron = UIImage(named: "arrow-right.png")
        cell.accessoryView = UIImageView(image: chevron)
        cell.layoutMargins = UIEdgeInsets.zero;
        cell.preservesSuperviewLayoutMargins = false;
        return cell as UITableViewCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)?.textLabel?.text
        tableView.deselectRow(at: indexPath, animated: true)
        
        UserDefaults.standard.set(cell!, forKey: "cityName")
        
        //performSegue(withIdentifier: "listviewToWeather", sender: cell)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let chevron = UIImage(named: "arrow-right-white.png")
        tableView.cellForRow(at: indexPath)!.accessoryView = UIImageView(image:  chevron)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let chevron = UIImage(named: "arrow-right.png")
        tableView.cellForRow(at: indexPath as IndexPath)!.accessoryView = UIImageView(image:  chevron)
    }
    
    
    
    func getMarkerByTitle(title: String){
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
