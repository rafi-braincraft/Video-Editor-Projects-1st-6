// ViewController.swift
import UIKit
import SafariServices

class ViewController: UIViewController {
    
    // UI Elements - you'll need to connect these in Interface Builder
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Your Pinterest app credentials - you'll need to replace these with your actual values
    private let clientId = "YOUR_CLIENT_ID" // Replace with your actual client ID
    private let appSecret = "YOUR_APP_SECRET" // Replace with your actual app secret
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Check if we're already authenticated
        if PinterestAPI.shared.isAuthenticated {
            navigateToPinsViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        // Set up the UI elements
        appTitleLabel?.text = "Pinterest Explorer"
        descriptionLabel?.text = "View and explore your Pinterest pins in a beautiful interface."
        loginButton?.layer.cornerRadius = 8
    }
    
    @IBAction func logInWithPinterestTapped(_ sender: UIButton) {
        // For a real app, you would use OAuth flow through a web view
        // But for simplicity, we'll use a token input method
        showTokenInputAlert()
    }
    
    @IBAction func alternativeLoginTapped(_ sender: Any) {
        // This is a backup method if the OAuth doesn't work
        showTokenInputAlert()
    }
    
    func showTokenInputAlert() {
        let alert = UIAlertController(title: "Enter Access Token",
                                     message: "Enter your Pinterest access token",
                                     preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Access token"
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let token = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
                PinterestAPI.shared.setAccessToken(token)
                self?.navigateToPinsViewController()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // This method would be used for a proper OAuth flow, but requires a redirect URL setup in the Pinterest Developer Portal
    func startOAuthFlow() {
        // This requires a redirect URL registered with Pinterest
        // Since you mentioned you don't have a redirect URL, we're using the token input method instead
        
        // For reference, a proper OAuth flow would look like this:
        /*
        let scopes = "pins:read,user_accounts:read"
        let authURLString = "https://www.pinterest.com/oauth/?client_id=\(clientId)&redirect_uri=YOUR_REDIRECT_URI&response_type=code&scope=\(scopes)"
        
        if let authURL = URL(string: authURLString) {
            let safariVC = SFSafariViewController(url: authURL)
            present(safariVC, animated: true)
        }
        */
    }
    
    func navigateToPinsViewController() {
        if let pinsVC = storyboard?.instantiateViewController(withIdentifier: "PinsViewController") as? PinsViewController {
            navigationController?.pushViewController(pinsVC, animated: true)
        }
    }
}

// This extension would be used for handling the redirect URL in a proper OAuth flow
// It's included for reference, but won't be used in your current implementation
extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
