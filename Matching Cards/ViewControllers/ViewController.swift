//
//  ViewController.swift
//  Matching Cards
//
//  Created by Celil Çağatay Gedik on 26.10.2022.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
    let model = CardModel()
    var cardsArray = [Card]()
    
    var timer: Timer?
    var milliseconds: Int = 10 * 1000
    
    var firstFlippedCardIndex: IndexPath?
    
    var soundPlayer = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsArray = model.getCards()
        
        // Set the view controller as the datasource and the delegate of the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Initialize the timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Play shuffle sound
        soundPlayer.playSound(effect: .shuffle)
    }
    
    // MARK: - Timer Methods
    
    @objc func timerFired() {
        
        // Decrement the counter
        milliseconds -= 1
        
        // Update the label
        let seconds: Double = Double(milliseconds)/1000.0
        timerLabel.text = String(format: "Time Remaining: %.2f", seconds)
        
        // Stop the timer if it reaches zero
        if milliseconds == 0 {
            
            timerLabel.textColor = UIColor.red
            timer?.invalidate()
            
            // Check if the usser has cleared all the pairs
            checkForGameEnd()
        }
    }
    
    // MARK: - Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return number of cards
        return cardsArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Return it
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Configure the state of the cell based on the proporties of the card that it represents
        let cardcell = cell as? CardCollectionViewCell
        
        // Get the card from card array
        let card = cardsArray[indexPath.row]
        
        // Configure it
        cardcell?.configureCell(card: card)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get a reference to the cell that was tapped
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        
        
        //Check the status of the card to determine how to flip it
        if cell?.card?.isFlipped == false && cell?.card?.isMatched == false {
            
            // Flip the card up
            cell?.flipUp()
            
            // Play flip sound
            soundPlayer.playSound(effect: .flip)
            
            // Check if this is the first card that was flipped or the second one
            
            if firstFlippedCardIndex == nil {
                
                //This is the first card flipped over
                firstFlippedCardIndex = indexPath
                
            }
            else {
                
                // Second card that is flipped
                
                // Run the comparison logic
                checkForMatch(indexPath)
            }
        }
    }
    
    // MARK: - Game Logic Methods
    
    func checkForMatch(_ secondFlippedCardIndex: IndexPath)  {
        
        // Get the two card object for the indices and see they match
        let cardOne = cardsArray[firstFlippedCardIndex!.row]
        let cardTwo = cardsArray[secondFlippedCardIndex.row]
        
        // Get the two collections view cells
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        // Compare the two
        if cardOne.imageName == cardTwo.imageName {
            
            // It's a match
            
            // Play match sound
            soundPlayer.playSound(effect: .match)
            
            // Set the status and remove them
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Was that the last pair?
            checkForGameEnd()
        }
        else {
            
            // It's not a match
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Play not a match sound
            soundPlayer.playSound(effect: .nomatch)
            
            // Flip them back over
            cardOneCell?.flipDown()
            cardTwoCell?.flipDown()
            
        }
        
        // Reset the firsFlippedCardIndex property
        firstFlippedCardIndex = nil
        
    }
    
    func checkForGameEnd() {
        
        // Check if there's any card that is unmatched
        // Assume the user has won, loop through all the cards to see if all of matched
        var hasWon = true
        
        for card in cardsArray {
            if card.isMatched == false {
                // We've found a card that unmatched
                hasWon = false
                break
            }
        }
        
        if hasWon {
            
            // User has won, show an alert
            showAlert(title: "Amazing", message: "You Won!!!")
            
        }
        else {
            
            // User hasn't won yet, check if there's any time left
            if milliseconds <= 0 {
                showAlert(title: "Oops", message: "Try another time")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a dismiss button
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
}

