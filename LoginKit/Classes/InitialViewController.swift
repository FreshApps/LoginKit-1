//
//  InitialViewController.swift
//  LoginKit
//
//  Created by Daniel Lozano Valdés on 12/8/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import UIKit

protocol InitialViewControllerDelegate: class {

    func didSelectSignup(_ viewController: UIViewController)

    func didSelectLogin(_ viewController: UIViewController)

    func didSelectFacebook(_ viewController: UIViewController)

}

class InitialViewController: UIViewController, BackgroundMovable {

    // MARK: - Properties

    weak var delegate: InitialViewControllerDelegate?

    weak var configurationSource: ConfigurationSource?

    // MARK: Background Movable

    var movableBackground: UIView {
        get {
            return backgroundImageView
        }
    }

    // MARK: Outlet's

    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var welcomeDetailLbl: UILabel!

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = loadFonts
        initBackgroundMover()
        customizeAppearance()
    }

    override func loadView() {
        self.view = viewFromNib()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Setup

    func customizeAppearance() {
        configureFromSource()
        setupFonts()
        addShadows()

        navigationController?.isNavigationBarHidden = true
        navigationController?.delegate = self
    }

    func configureFromSource() {
        guard let config = configurationSource else {
            return
        }

        backgroundImageView.image = config.backgroundImage
        logoImageView.image = config.mainLogoImage

        signupButton.setTitle(config.signupButtonText, for: .normal)
        signupButton.setTitleColor(config.tintColor, for: .normal)
        //signupButton.borderColor = config.tintColor.withAlphaComponent(0.25)
        signupButton.titleLabel?.font = UIFont(name: "SanFranciscoText-Bold", size: 20.0)

        loginButton.setTitle(config.loginButtonText, for: .normal)
        loginButton.setTitleColor(config.tintColor, for: .normal)
        //loginButton.borderColor = config.tintColor.withAlphaComponent(0.25)
        loginButton.titleLabel?.font = UIFont(name: "SanFranciscoText-Bold", size: 20.0)

        facebookButton.setTitle(config.facebookButtonText, for: .normal)
        welcomeLbl.text = config.welcomeHeaderText
        welcomeDetailLbl.text = config.welcomeDetailText
    }

    func setupFonts() {
        loginButton.titleLabel?.font = Font.montserratRegular.get(size: 13)
        signupButton.titleLabel?.font = Font.montserratRegular.get(size: 13)
        facebookButton.titleLabel?.font = Font.montserratRegular.get(size: 15)
        
        welcomeLbl.font = Font.montserratRegular.get(size: 30)
        welcomeDetailLbl.font = Font.montserratRegular.get(size: 19)

    }

    func addShadows() {
        facebookButton.layer.shadowOpacity = 0.3
        facebookButton.layer.shadowColor = UIColor(red: 89.0/255.0, green: 117.0/255.0, blue: 177.0/255.0, alpha: 1).cgColor
        facebookButton.layer.shadowOffset = CGSize(width: 15, height: 15)
        facebookButton.layer.shadowRadius = 7
        facebookButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        loginButton.layer.shadowOpacity = 0.3
        loginButton.layer.shadowColor = UIColor(red: 89.0/255.0, green: 117.0/255.0, blue: 177.0/255.0, alpha: 1).cgColor
        loginButton.layer.shadowOffset = CGSize(width: 15, height: 15)
        loginButton.layer.shadowRadius = 7
        loginButton.layer.masksToBounds = false
        loginButton.layer.cornerRadius = 15

        
        signupButton.layer.shadowOpacity = 0.3
        signupButton.layer.shadowColor = UIColor(red: 89.0/255.0, green: 117.0/255.0, blue: 177.0/255.0, alpha: 1).cgColor
        signupButton.layer.shadowOffset = CGSize(width: 15, height: 15)
        signupButton.layer.shadowRadius = 7
        signupButton.layer.masksToBounds = false
        signupButton.layer.cornerRadius = 15
    }

    // MARK: - Action's

    @IBAction func didSelectSignup(_ sender: AnyObject) {
        delegate?.didSelectSignup(self)
    }

    @IBAction func didSelectLogin(_ sender: AnyObject) {
        delegate?.didSelectLogin(self)
    }

    @IBAction func didSelectFacebook(_ sender: AnyObject) {
        delegate?.didSelectFacebook(self)
    }

}

// MARK: - UINavigationController Delegate

extension InitialViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CrossDissolveAnimation()
    }

}
