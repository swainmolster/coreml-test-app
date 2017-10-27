//
//  ViewController.swift
//  CoreMLTestApp
//
//  Created by Swain Molster on 10/19/17.
//  Copyright © 2017 Swain Molster. All rights reserved.
//

import UIKit
import CoreML

struct TextAnalysis {
    let isHappy: Bool
    let howSure: Double
    
    init(modelOutput: SentimentPolarityOutput) {
        self.isHappy = modelOutput.classLabel == "Pos"
        self.howSure = modelOutput.classProbability[modelOutput.classLabel]!
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var currentMovieIndex: Int = -1
    
    var movies: [String] = [
        "starwars",
        "lala",
        "wonder",
        "beauty"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextView.delegate = self
        selectNextMovie()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        inputTextView.becomeFirstResponder()
    }

    func sentimentAnalysis(forString text: String) -> TextAnalysis? {
        let wordCounts = getWordCounts(fromString: text)
        
        let model = SentimentPolarity()
        let input = SentimentPolarityInput(input: wordCounts)
        
        if let output = try? model.prediction(input: input) {
            return TextAnalysis(modelOutput: output)
        } else {
            return nil
        }
        
    }
    
    func updateQuestionLabel(forAnalysis analysis: TextAnalysis) {
        let text: String
        let color: UIColor
        
        if analysis.isHappy {
            text = "We're happy to hear it! 😊"
            color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.25)
        } else {
            text = "Sorry to hear that. 😔"
            color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25)
        }
        
        DispatchQueue.main.async {
            self.questionLabel.text = text
            self.questionLabel.backgroundColor = color
        }
        
    }
    
    @objc func userInputChanged(_ textView: UITextView) {
        if totalWordCount(fromString: textView.text) < 4 {
            resetQuestionLabel()
            return
        }
        
        guard let analysis = sentimentAnalysis(forString: textView.text) else {
            print("Our model prediction failed!")
            return
        }
        
        updateQuestionLabel(forAnalysis: analysis)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        self.inputTextView.text = ""
        selectNextMovie()
        resetQuestionLabel()
    }
}

//MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            resetQuestionLabel()
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.userInputChanged), object: textView)
        self.perform(#selector(self.userInputChanged), with: textView, afterDelay: 0.75)
    }
}

//MARK: - Helper Functions
extension ViewController {
    
    func getWordCounts(fromString string: String) -> [String: Double] {
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]
        
        tagger.string = string
        
        var wordCounts: [String: Double] = [:]
        
        let range = NSRange(location: 0, length: string.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange, stop in
            let token = (string as NSString).substring(with: tokenRange).lowercased()
            guard token.count >= 3 else {
                return
            }
            
            if let value = wordCounts[token] {
                wordCounts[token] = value + 1.0
            } else {
                wordCounts[token] = 1.0
            }
            
        }
        return wordCounts
    }
    
    func totalWordCount(fromString string: String) -> Int {
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]
        tagger.string = string
        let range = NSRange(location: 0, length: string.utf16.count)
        
        var wordCount = 0
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange, stop in
            wordCount += 1
        }
        return wordCount
    }
    
    func resetQuestionLabel() {
        DispatchQueue.main.async {
            self.questionLabel.text = "What did you think?"
            self.questionLabel.backgroundColor = UIColor.clear
        }
    }
    
    func selectNextMovie() {
        currentMovieIndex += 1
        currentMovieIndex %= movies.count
        DispatchQueue.main.async {
            self.imageView.image = UIImage(named: self.movies[self.currentMovieIndex])
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
}
