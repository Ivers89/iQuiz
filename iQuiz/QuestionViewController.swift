//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Iverson Li on 5/11/25.
//

import UIKit

class QuestionViewController: UIViewController {
    var topicTitle: String?
    var questions: [QuizQuestion] = []
    var currentQuestionIndex = 0
    var correctAnswers = 0

    var questionLabel = UILabel()
    var choiceButtons: [UIButton] = []
    var submitButton = UIButton()
    var selectedAnswerIndex: Int?

    let mainStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = topicTitle ?? "Quiz"

        setupUI()
        loadQuestion()
    }

    func setupUI() {
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

        questionLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        questionLabel.numberOfLines = 0
        mainStack.addArrangedSubview(questionLabel)

        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.setTitle("Choice \(i + 1)", for: .normal)
            button.backgroundColor = .systemGray5
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.tag = i
            button.addTarget(self, action: #selector(choiceTapped(_:)), for: .touchUpInside)
            choiceButtons.append(button)
            mainStack.addArrangedSubview(button)
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        submitButton.addTarget(self, action: #selector(submitTapped(_:)), for: .touchUpInside)
        mainStack.addArrangedSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.centerXAnchor.constraint(equalTo: mainStack.centerXAnchor)
        ])
    }

    func loadQuestion() {
        let question = questions[currentQuestionIndex]
        questionLabel.text = question.text

        for (i, button) in choiceButtons.enumerated() {
            if i < question.choices.count {
                button.setTitle(question.choices[i], for: .normal)
                button.isHidden = false
                button.backgroundColor = .systemGray5
                button.setTitleColor(.label, for: .normal)
            } else {
                button.isHidden = true
            }
        }

        selectedAnswerIndex = nil
    }

    @objc func choiceTapped(_ sender: UIButton) {
        selectedAnswerIndex = sender.tag
        for button in choiceButtons {
            button.backgroundColor = .systemGray5
            button.setTitleColor(.label, for: .normal)
        }
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
    }

    @objc func submitTapped(_ sender: UIButton) {
        guard let selected = selectedAnswerIndex else { return }

        if selected == questions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
        }

        let answerVC = AnswerViewController()
        answerVC.questions = questions
        answerVC.currentQuestionIndex = currentQuestionIndex
        answerVC.correctAnswers = correctAnswers
        answerVC.selectedAnswerIndex = selected
        navigationController?.pushViewController(answerVC, animated: true)
    }
}
