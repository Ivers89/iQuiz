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

struct QuizQuestion {
    let text: String
    let choices: [String]
    let correctAnswer: Int
}

class ViewController: UITableViewController, SettingsViewControllerDelegate {

    private var quizTopics: [QuizTopic] = [
        QuizTopic(title: "Mathematics", description: "Try out some math!", iconName: "math_icon"),
        QuizTopic(title: "Marvel Super Heroes", description: "Do you know your heroes?", iconName: "marvel_icon"),
        QuizTopic(title: "Science", description: "Test your scientific knowledge!", iconName: "science_icon")
    ]

    private var quizQuestionsByTopic: [String: [QuizQuestion]] = [
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
            QuizQuestion(text: "Who was the first American woman in space?", choices: ["Sally Ride", "Valentina Tereshkova", "Mae Jemison"], correctAnswer: 2)
        ]
    ]

    let defaultURL = "https://tednewardsandbox.site44.com/questions.json"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iQuiz"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Settings",
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )

        let savedURL = UserDefaults.standard.string(forKey: "quizDataURL") ?? defaultURL
        loadQuizData(from: savedURL)
    }

    @objc func showSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }

    func didUpdateQuizURL(_ urlString: String) {
        loadQuizData(from: urlString)
    }

    func loadQuizData(from urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert(title: "Invalid URL", message: "Could not create URL from the string.")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Network Error", message: error.localizedDescription)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No data received.")
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let remoteTopics = try decoder.decode([RemoteQuizTopic].self, from: data)

                var localTopics: [QuizTopic] = []
                var localQuestions: [String: [QuizQuestion]] = [:]

                for remote in remoteTopics {
                    localTopics.append(
                        QuizTopic(title: remote.title, description: remote.desc, iconName: "default_icon")
                    )
                    let questions = remote.questions.enumerated().map { (index, q) in
                        // Find correctAnswer index from answer string
                        let correctIndex = q.answers.firstIndex(of: q.answer) ?? 0
                        return QuizQuestion(text: q.text, choices: q.answers, correctAnswer: correctIndex)
                    }
                    localQuestions[remote.title] = questions
                }

                DispatchQueue.main.async {
                    self.quizTopics = localTopics
                    self.quizQuestionsByTopic = localQuestions
                    self.tableView.reloadData()
                }

            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "JSON Error", message: "Failed to parse quiz data.")
                }
            }
        }

        task.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = quizTopics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath)
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.description

        // Assign icon based on title dynamically:
        let iconName: String
        switch topic.title.lowercased() {
        case "science!", "science":
            iconName = "science_icon"
        case "marvel super heroes":
            iconName = "marvel_icon"
        case "mathematics":
            iconName = "math_icon"
        default:
            iconName = "default_icon"
        }

        cell.imageView?.image = UIImage(named: iconName)
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

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
