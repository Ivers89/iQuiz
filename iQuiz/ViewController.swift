//
//  ViewController.swift
//  iQuiz
//
//  Created by Iverson Li on 5/5/25.
//

import UIKit


struct QuizTopic {
    let title: String
    let description: String
    let iconName: String
}

let quizTopics = [
    QuizTopic(title: "Mathematics", description: "Try out some math!", iconName: "math_icon"),
    QuizTopic(title: "Marvel Super Heroes", description: "Do you know your heroes?", iconName: "marvel_icon"),
    QuizTopic(title: "Science", description: "Test your scientific knowledge!", iconName: "science_icon")
]

struct QuizQuestion {
    let text: String
    let choices: [String]
    let correctAnswer: Int
}

let quizQuestionsByTopic: [String: [QuizQuestion]] = [
    "Mathematics": [
        QuizQuestion(text: "What is 9 + 10?", choices: ["21", "19", "910"], correctAnswer: 1),
        QuizQuestion(text: "What is 5 * 6?", choices: ["11", "30", "60"], correctAnswer: 1)
    ],
    "Marvel Super Heroes": [
        QuizQuestion(text: "Who is Iron First?", choices: ["Shang-Chi", "Luke Cage", "Daniel Rand"], correctAnswer: 2),
        QuizQuestion(text: "Who is the Deadpool?", choices: ["Loki", "Wade Wilson", "Peter Parker"], correctAnswer: 1)
    ],
    "Science": [
        QuizQuestion(text: "What scale is used to measure the hardness of minerals?", choices: ["Moh's Scale", "Richter Scale", "Pauling scale"], correctAnswer: 0),
        QuizQuestion(text: "Who was the first American woman in space?", choices: ["Sally Ride", "Valentina Tereshkova", "Mae "], correctAnswer: 1)
    ]
]

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iQuiz"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Settings",
            style: .plain, target: self,
            action: #selector(showSettings)
        )
    }

    @objc func showSettings() {
        let alert = UIAlertController(title: nil, message: "Settings go here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = quizTopics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath)
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.description
        cell.imageView?.image = UIImage(named: topic.iconName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedTopic = quizTopics[indexPath.row]
        let questions = quizQuestionsByTopic[selectedTopic.title] ?? []
        if let questionVC = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController {
            questionVC.topicTitle = selectedTopic.title
            questionVC.questions = questions
            questionVC.currentQuestionIndex = 0
            questionVC.correctAnswers = 0

            navigationController?.pushViewController(questionVC, animated: true)
        }
    }
    
}
