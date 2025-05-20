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

    private var quizTopics: [QuizTopic] = []
    private var quizQuestionsByTopic: [String: [QuizQuestion]] = [:]

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
        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    func didUpdateQuizURL(_ urlString: String) {
        loadQuizData(from: urlString)
    }

    func loadQuizData(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                self.loadLocalQuizData() // fallback
                return
            }

            do {
                try data.write(to: self.localQuizFileURL()) // save locally
                print("Saved quiz data to: \(self.localQuizFileURL().path)")
                self.parseQuizData(data)
            } catch {
                print("Failed to save or parse data: \(error)")
                self.loadLocalQuizData()
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
    
    func loadLocalQuizData() {
        let fileURL = localQuizFileURL()
        do {
            let data = try Data(contentsOf: fileURL)
            parseQuizData(data)
        } catch {
            print("Failed to load local quiz data: \(error)")
        }
    }

    func parseQuizData(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let remoteTopics = try decoder.decode([RemoteQuizTopic].self, from: data)

            var localTopics: [QuizTopic] = []
            var localQuestions: [String: [QuizQuestion]] = [:]

            for remote in remoteTopics {
                let questions = remote.questions.map {
                    QuizQuestion(
                        text: $0.text,
                        choices: $0.answers,
                        correctAnswer: (Int($0.answer) ?? 1) - 1
                    )
                }

                let topic = QuizTopic(title: remote.title, description: remote.desc, iconName: "")
                localTopics.append(topic)
                localQuestions[topic.title] = questions
            }

            DispatchQueue.main.async {
                self.quizTopics = localTopics
                self.quizQuestionsByTopic = localQuestions
                self.tableView.reloadData()
            }
        } catch {
            print("JSON parsing failed: \(error)")
        }
    }

    func localQuizFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("quizdata.json")
    }
    
}
