//
//  ViewController.swift
//  iQuiz
//
//  Created by Iverson Li on 5/4/25.
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
}
