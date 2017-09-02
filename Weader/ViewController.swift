//
//  ViewController.swift
//  Weader
//
//  Created by Seweryn Kotowski on 28.01.2017.
//  Copyright © 2017 Seweryn Kotowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var contitionLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var degree: Int!
    var condition: String!
    var imgURL: String!
    var city: String!

    var exists: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/current.json?key=379d278a34c84eac97e182514172801&q=\(searchBar.text!.replacingOccurrences(of: "", with: "%20"))")!)
        
        
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        
        if error == nil {
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                
                if let current = json["current"] as? [String: AnyObject] {
                    
                    if let temp = current["temp_c"] as? Int {
                    self.degree = temp
                    }
                    if let condition = current["condition"] as? [String: AnyObject] {
                        self.condition = condition["text"] as! String
                        let icon = condition["icon"] as! String
                        self.imgURL = "http:\(icon)"
                    }
                }
                if let location = json["location"] as? [String: AnyObject] {
                    self.city = location["name"] as! String
                }
                if let _ = json["error"] {
                    self.exists = false
                }
            
                DispatchQueue.main.async {
                    if self.exists {
                        
                        self.degreeLabel.isHidden = false
                        self.contitionLabel.isHidden = false
                        self.imageView.isHidden = false
                        
                        self.degreeLabel.text = "\(self.degree.description)°"
                        self.cityLabel.text = self.city
                        self.contitionLabel.text = self.condition
                        self.imageView.downloadImage(from: self.imgURL!)
                    }else{
                        self.degreeLabel.isHidden = true
                        self.contitionLabel.isHidden = true
                        self.imageView.isHidden = true
                        self.cityLabel.text = "Nie znaleziono takiego miasta"
                        self.exists = true
                    }
                }
                
            }catch let jsonError {
                print(jsonError.localizedDescription)
                
            }
        }
    }
        task.resume()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


    extension UIImageView {
        func downloadImage(from url: String) {
            let urlRequest = URLRequest(url: URL(string: url)!)
            
                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    if error == nil {
                        DispatchQueue.main.sync {
                            self.image = UIImage(data: data!)
                        }
                    }
            }
            task.resume()
        }
}
    



