//
//  ViewController.swift
//  Matching Cards
//
//  Created by Celil Çağatay Gedik on 26.10.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let model = CardModel()
    var cardsArray = [Card]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsArray = model.getCards()
        
    }


}

