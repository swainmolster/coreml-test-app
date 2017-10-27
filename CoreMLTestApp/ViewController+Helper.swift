//
//  ViewController+Helper.swift
//  CoreMLTestApp
//
//  Created by Swain Molster on 10/27/17.
//  Copyright © 2017 Swain Molster. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        self.inputTextView.text = ""
        selectNextMovie()
        resetQuestionLabel()
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        inputTextView.becomeFirstResponder()
    }
    
    func resetQuestionLabel() {
        DispatchQueue.main.async {
            self.questionLabel.text = "What did you think?"
            self.questionLabel.backgroundColor = UIColor.clear
        }
    }
}
