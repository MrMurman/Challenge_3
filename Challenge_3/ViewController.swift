//
//  ViewController.swift
//  Challenge_3
//
//  Created by Андрей Бородкин on 05.07.2021.
//

import UIKit

enum AlertType {
    case notCharacter, gameOver, notOriginal
    
    var errorTitle: String{
        switch self {
        case .notCharacter:
            return "That is not a character"
        case .gameOver:
            return "Game over"
        case .notOriginal:
            return "Please enter a new letter"
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .notCharacter:
            return "Please enter 1 letter"
        case .gameOver:
            return "Would you like to start over?"
        case .notOriginal:
            return "That character has already been used"
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet var usedCharsTableView: UITableView!
    @IBOutlet var imageView: UIImageView!
    

    var secretWords: [String] = []
    //["RHYTHM", "FUCK"]

    var chosenWord: String = ""
    
    var shownWord:[String] = [] {
        didSet {
            let tempWord = shownWord.compactMap({$0}).joined()
            if chosenWord == tempWord.replacingOccurrences(of: " ", with: "") && chosenWord != "" {
                showAlert(.gameOver)
            }
        }
    }
    
    var usedLetters: [Character] = []
    var triedLetters: [Character] = []
    
    var countDown = 7 {
        didSet {
            if countDown == 0 {
                showAlert(.gameOver)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(checkCharacter))
        
        usedCharsTableView.layer.borderWidth = 2
        usedCharsTableView.layer.cornerRadius = 7
        usedCharsTableView.layer.shadowOffset = CGSize(width: 4, height: 5)
        usedCharsTableView.layer.shadowRadius = 5
        
        DispatchQueue.global(qos: .default).async {
            self.loadWords()
            self.startNewGame()
        }
        
        setupApples()

    }

    
    @objc func checkCharacter() {
        
        let ac = UIAlertController(title: "Try a letter", message: nil, preferredStyle: .alert)
        ac.addTextField() { textfield in
            textfield.placeholder = "Enter a letter"
        }
        let checkCharacterAction = UIAlertAction(title: "Try it out", style: .default) { [self] _ in
            
            guard let character = ac.textFields?[0].text?.uppercased(), character.count == 1 else {
                showAlert(.notCharacter)
                return
            }
            guard !triedLetters.contains(Character(character)) else {
                showAlert(.notOriginal)
                return
            }
            
            for index in 0..<usedLetters.count {
                
                guard usedLetters[index] == Character(character) else {
                    if !triedLetters.contains(Character(character)) {
                        triedLetters.append(Character(character))
                    }
                    continue
                }
                shownWord[index] = character
                
            }
            if !shownWord.contains(character) {
                countDown -= 1
            }
            updateUI()
            print(countDown, "", triedLetters)
        }
        
        ac.addAction(checkCharacterAction)
        present(ac, animated: true)
    }

    func showAlert(_ type: AlertType) {
        
        let ac = UIAlertController(title: type.errorTitle, message: type.errorMessage, preferredStyle: .alert)
        let alertAction: UIAlertAction
        
        switch type {
        case .notCharacter, .notOriginal:
            alertAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
            
        case .gameOver:
            alertAction = UIAlertAction(title: "Start New Game", style: .default) { [weak self] _ in
                self?.performSelector(inBackground: #selector(self?.startNewGame), with: nil)
            }
        }
        ac.addAction(alertAction)
        present(ac, animated: true)

    }

    
   @objc func updateUI() {
        imageView.image = UIImage(named: "Tree \(countDown)")
        title = shownWord.joined(separator: " ") + " - Remaining attempts: \(countDown)"
        usedCharsTableView.reloadData()
       
    }
    
    
    
    @objc func loadWords() {
        
        if let starWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: starWordsURL) {
                secretWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if secretWords.isEmpty {
            secretWords = ["KriTiKal ProoBleem"]
        }
        
    }
    
    @objc func startNewGame() {
        var secretWordsShuffled = secretWords.shuffled()
        chosenWord = secretWordsShuffled.removeFirst().uppercased()
        countDown = 7
        triedLetters.removeAll()
        shownWord.removeAll()
        
        for letter in chosenWord {
            usedLetters.append(letter)
            shownWord.append("_")
        }
        print(usedLetters)
        
        performSelector(onMainThread: #selector(updateUI), with: nil, waitUntilDone: false)
    }
    @IBAction func giveUpButton(_ sender: UIButton) {
        showAlert(.gameOver)
    }
    
    func setupApples() {
        imageView.clipsToBounds = false
        
        
        var appleArray: [UIImageView] = []
        var xCoordinate: Double = -15
        let yCoordinate: [Double] = [75, 170, 50, 120, 10, 150, 60]
        
        for index in 0...6 {
            
            let apple = UIImageView(image: UIImage(named: "apple"))
            apple.frame = CGRect(x: xCoordinate, y: yCoordinate[index], width: 155/2.5, height: 132/2.5)
            xCoordinate += 38
            
            appleArray.append(apple)
            imageView.addSubview(apple)
        }
        
//        let appleOne = UIImageView(image: UIImage(named: "apple"))
//        appleOne.frame = CGRect(x: 0, y: 75, width: 155/2.5, height: 132/2.5)
//        let appleTwo = UIImageView(image: UIImage(named: "apple"))
//        appleTwo.frame = CGRect(x: 45, y: 75, width: 155/2.5, height: 132/2.5)
//        let appleThree = UIImageView(image: UIImage(named: "apple"))
//        appleThree.frame = CGRect(x: 90, y: 75, width: 155/2.5, height: 132/2.5)
//        let appleFour = UIImageView(image: UIImage(named: "apple"))
//        appleFour.frame = CGRect(x: 135, y: 75, width: 155/2.5, height: 132/2.5)
//        let appleFive = UIImageView(image: UIImage(named: "apple"))
//        appleFive.frame = CGRect(x: 180, y: 75, width: 155/2.5, height: 132/2.5)
//        let appleSix = UIImageView(image: UIImage(named: "apple"))
//        appleSix.frame = CGRect(x: 215, y: 75, width: 155/2.5, height: 132/2.5)
//        let appleSeven = UIImageView(image: UIImage(named: "apple"))
//        appleSeven.frame = CGRect(x: 260, y: 75, width: 155/2.5, height: 132/2.5)
//
        
//        imageView.addSubview(appleOne)
//        imageView.addSubview(appleTwo)
//        imageView.addSubview(appleThree)
//        imageView.addSubview(appleFour)
//        imageView.addSubview(appleFive)
//        imageView.addSubview(appleSix)
//        imageView.addSubview(appleSeven)
        
    }
    
    func dropApple(index: Int, letter: String) {
        UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: []) { [self] in
            imageView.subviews[index].transform = CGAffineTransform(translationX: 0, y: 165)
        } completion: { [self] _ in
            
            let letterLayer = CATextLayer()
            letterLayer.frame = CGRect(x: 20, y: 10, width: 155/2.5, height: 132/2.5)
            letterLayer.string = letter
            letterLayer.fontSize = 30
            letterLayer.foregroundColor = UIColor.white.cgColor
            imageView.subviews[index].layer.addSublayer(letterLayer)
            return
        }

    }
    
    let lettersArray: [String] = ["A", "B", "C", "D", "E", "F", "X", "Y"]
    var buttonCount = 0
    
    @IBAction func dropActionBTN(_ sender: UIButton) {
        dropApple(index: buttonCount, letter: lettersArray[buttonCount])
        buttonCount += 1
        
        
    }
    
    
}






extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        triedLetters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            cell = reuseCell
            
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        }
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = String(triedLetters[indexPath.row])
        cell.contentConfiguration = configuration
        return cell
    }
}
