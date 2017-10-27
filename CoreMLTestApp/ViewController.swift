//
//  ViewController.swift
//  CoreMLTestApp
//
//  Created by Swain Molster on 10/19/17.
//  Copyright © 2017 Swain Molster. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var movies: [String] = [
        "starwars",
        "lala",
        "wonder",
        "beauty"
    ]
    
    var currentMovieIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextView.delegate = self
        selectNextMovie()
    }
    
    func updateQuestionLabel(forInput text: String) {
        let wordCounts = getWordCounts(fromString: text)    // wordCounts: [String: Double]
        
        let model = SentimentPolarity()
        let input = SentimentPolarityInput(input: wordCounts)
        
        guard let output = try? model.prediction(input: input) else {
            print("We couldn't make a prediction!")
            return
        }
        
        let newText: String
        let newColor: UIColor
        
        if output.classLabel == "Pos" {
            newText = "We're happy to hear it! 😊"
            newColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.25)
        } else {
            newText = "Sorry to hear that. 😔"
            newColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25)
        }
        
        DispatchQueue.main.async {
            self.questionLabel.text = newText
            self.questionLabel.backgroundColor = newColor
        }
    }
    
}

//MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            resetQuestionLabel()
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.userInputChanged(_:)), object: textView)
        self.perform(#selector(self.userInputChanged), with: textView, afterDelay: 0.70)
    }
    
    @objc func userInputChanged(_ textView: UITextView) {
        updateQuestionLabel(forInput: textView.text)
    }
}
