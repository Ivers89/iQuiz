//
//  QuizModels.swift
//  iQuiz
//
//  Created by Iverson Li on 5/15/25.
//

import Foundation

struct RemoteQuizTopic: Codable {
    let title: String
    let desc: String
    let questions: [RemoteQuizQuestion]
}

struct RemoteQuizQuestion: Codable {
    let text: String
    let answer: String
    let answers: [String]
}

