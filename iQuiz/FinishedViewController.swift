//
//  FinishedViewController.swift
//  iQuiz
//
//  Created by Iverson Li on 5/12/25.
//


import UIKit

class FinishedViewController: UIViewController {
    var totalQuestions = 0
    var correctAnswers = 0
    private let summaryLabel = UILabel()
    private let doneButton = UIButton()
    private let mainStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Finished"

        setupUI()
        displaySummary()
    }

    func setupUI() {
        mainStack.axis = .vertical
        mainStack.spacing = 40
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        summaryLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        summaryLabel.numberOfLines = 0
        summaryLabel.textAlignment = .center
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(summaryLabel)

        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
        mainStack.addArrangedSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    func displaySummary() {
        let performance: String
        if correctAnswers == totalQuestions {
            performance = "Perfect!"
        } else if correctAnswers > totalQuestions / 2 {
            performance = "Almost!"
        } else {
            performance = "Better luck next time!"
        }
        summaryLabel.text = "\(performance)\nYou got \(correctAnswers) out of \(totalQuestions) correct."
    }

    @objc func doneTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
