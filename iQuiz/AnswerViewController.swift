//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by Iverson Li on 5/12/25.
//


import UIKit

class AnswerViewController: UIViewController {
    var questions: [QuizQuestion] = []
    var currentQuestionIndex = 0
    var correctAnswers = 0
    var selectedAnswerIndex: Int = -1

    var questionLabel = UILabel()
    var correctAnswerLabel = UILabel()
    var feedbackLabel = UILabel()
    var nextButton = UIButton()

    let mainStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Answer"

        setupUI()
        loadAnswer()
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
        correctAnswerLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        correctAnswerLabel.textColor = .systemGreen
        correctAnswerLabel.numberOfLines = 0
        mainStack.addArrangedSubview(correctAnswerLabel)

        feedbackLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        feedbackLabel.textColor = .systemRed
        feedbackLabel.numberOfLines = 0
        mainStack.addArrangedSubview(feedbackLabel)
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 8
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)
        mainStack.addArrangedSubview(nextButton)

        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.centerXAnchor.constraint(equalTo: mainStack.centerXAnchor)
        ])
    }

    func loadAnswer() {
        let question = questions[currentQuestionIndex]
        questionLabel.text = question.text
        correctAnswerLabel.text = "Correct answer: \(question.choices[question.correctAnswer])"
        feedbackLabel.text = selectedAnswerIndex == question.correctAnswer ? "Correct!" : "Wrong!"
    }

    @objc func nextTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if currentQuestionIndex + 1 < questions.count {
            if let nextQuestionVC = storyboard.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController {
                nextQuestionVC.questions = questions
                nextQuestionVC.currentQuestionIndex = currentQuestionIndex + 1
                nextQuestionVC.correctAnswers = correctAnswers
                navigationController?.pushViewController(nextQuestionVC, animated: true)
            }
        } else {
            if let finishedVC = storyboard.instantiateViewController(withIdentifier: "FinishedViewController") as? FinishedViewController {
                finishedVC.totalQuestions = questions.count
                finishedVC.correctAnswers = correctAnswers
                navigationController?.pushViewController(finishedVC, animated: true)
            }
        }
    }
}
