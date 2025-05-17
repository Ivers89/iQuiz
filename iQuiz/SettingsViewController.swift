import UIKit
import SystemConfiguration
import Network

protocol SettingsViewControllerDelegate: AnyObject {
    func didUpdateQuizURL(_ urlString: String)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    
    let urlTextField = UITextField()
    let checkNowButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    
    let quizURLKey = "quizDataURL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        setupUI()
        loadSavedURL()
    }
    
    func setupUI() {
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Enter URL"
        urlTextField.autocapitalizationType = .none
        urlTextField.keyboardType = .URL
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlTextField)
        
        checkNowButton.setTitle("Check Now", for: .normal)
        checkNowButton.addTarget(self, action: #selector(checkNowTapped), for: .touchUpInside)
        checkNowButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkNowButton)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            urlTextField.heightAnchor.constraint(equalToConstant: 40),
            
            checkNowButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            checkNowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            checkNowButton.widthAnchor.constraint(equalToConstant: 100),
            checkNowButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func loadSavedURL() {
        let savedURL = UserDefaults.standard.string(forKey: quizURLKey) ?? "https://tednewardsandbox.site44.com/questions.json"
        urlTextField.text = savedURL
    }
    
    @objc func checkNowTapped() {
        guard let urlString = urlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !urlString.isEmpty else {
            showAlert(title: "Invalid URL", message: "Please enter a valid URL.")
            return
        }
        
        isNetworkAvailable { isAvailable in
            DispatchQueue.main.async {
                if !isAvailable {
                    self.showAlert(title: "Network Unavailable", message: "Please check your internet connection and try again.")
                    return
                }
                
                guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                    self.showAlert(title: "Invalid URL", message: "The URL provided is not valid.")
                    return
                }
                
                UserDefaults.standard.set(urlString, forKey: self.quizURLKey)
                
                self.delegate?.didUpdateQuizURL(urlString)
                
                self.dismiss(animated: true)
            }
        }
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func isNetworkAvailable(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { path in
            completion(path.status == .satisfied)
            monitor.cancel()
        }
        
        monitor.start(queue: queue)
    }
}
