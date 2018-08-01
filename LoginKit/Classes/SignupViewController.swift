//
//  SignupViewController.swift
//  LoginKit
//
//  Created by Daniel Lozano Valdés on 12/8/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import UIKit
import Validator

protocol SignupViewControllerDelegate: class {

    func didSelectSignup(_ viewController: UIViewController, email: String, name: String, password: String, gender: String, birthday: String)

    func signupDidSelectBack(_ viewController: UIViewController)
    
    func didPressedTerms(_ viewController: UIViewController)
    func didPressedPrivacy(_ viewController: UIViewController)
}

class SignupViewController: UIViewController, KeyboardMovable, BackgroundMovable, UITextViewDelegate {

    // MARK: - Properties

    weak var delegate: SignupViewControllerDelegate?

    weak var configurationSource: ConfigurationSource?

    var signupAttempted = false

    var signupInProgress = false {
        didSet {
            signupButton.isEnabled = !signupInProgress
        }
    }

    // MARK: Keyboard Movable

    var selectedField: UITextField?

    var offset: CGFloat = 0.0

    // MARK: Background Movable

    var movableBackground: UIView {
        get {
            return backgroundImageView
        }
    }

    // MARK: Outlet's

    @IBOutlet var fields: [SkyFloatingLabelTextField]!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var repeatPasswordTextField: UITextField!

    @IBOutlet weak var backgroundImageView: GradientImageView!

    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var signupButton: Buttn!
    
    @IBOutlet weak var genderSwitch: UISegmentedControl!
    
    @IBOutlet weak var textSignup: UITextView!

    @IBOutlet weak var btnTermsOfUse: UIButton!
    // MARK: - UIViewController

    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var birthDayTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var stackViewCenterConstraint : NSLayoutConstraint!
    @IBOutlet weak var signupStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupValidation()
        initKeyboardMover()
        initBackgroundMover()
        customizeAppearance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func loadView() {
        self.view = viewFromNib()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destroyKeyboardMover()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Setup

    func customizeAppearance() {
        configureFromSource()
        setupFonts()
    }
    
    func configureFromSource() {
        guard let config = configurationSource else {
            return
        }
        
        
        view.backgroundColor = config.tintColor
        signupButton.setTitle(config.signupButtonText, for: .normal)

        backgroundImageView.image = config.backgroundImage
        logoImageView.image = config.secondaryLogoImage

        emailTextField.placeholder = config.emailPlaceholder
        //emailTextField.errorColor = config.errorTintColor
        //nameTextField.placeholder = config.namePlaceholder
        //nameTextField.errorColor = config.errorTintColor
        passwordTextField.placeholder = config.passwordPlaceholder
        //passwordTextField.errorColor = config.errorTintColor
        repeatPasswordTextField.placeholder = config.repeatPasswordPlaceholder
        //repeatPasswordTextField.errorColor = config.errorTintColor
        //birthDayTextField.placeholder = config.birthdayPlaceholder
        //birthDayTextField.errorColor = config.errorTintColor
        
        //birthDayTextField.selectedTitle = NSLocalizedString("Birthday", comment: "")
        //emailTextField.selectedTitle = NSLocalizedString("E-Mail", comment: "")
        //nameTextField.selectedTitle = NSLocalizedString("Name", comment: "")
        //passwordTextField.selectedTitle = NSLocalizedString("Password!", comment: "")
        //repeatPasswordTextField.selectedTitle = NSLocalizedString("Re-enter password!", comment: "")
        
        lblTerms.text = NSLocalizedString("TermsText", comment: "")
    }

    func setupFonts() {
        //nameTextField.font = Font.montserratRegular.get(size: 13)
        emailTextField.font = Font.montserratRegular.get(size: 13)
        passwordTextField.font = Font.montserratRegular.get(size: 13)
        repeatPasswordTextField.font = Font.montserratRegular.get(size: 13)
        signupButton.titleLabel?.font = Font.montserratRegular.get(size: 15)
        //birthDayTextField.font = Font.montserratRegular.get(size: 13)
    }

    // MARK: - Action's

    @IBAction func didSelectBack(_ sender: AnyObject) {
        delegate?.signupDidSelectBack(self)
    }

    @IBAction func didSelectSignup(_ sender: AnyObject) {
        
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else {
            return
        }
        signupAttempted = true
        if email == "" || password  == "" || password != repeatPasswordTextField.text {
            //shake
            if #available(iOS 10.0, *) {
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.error)
            }
            
            if password != repeatPasswordTextField.text {
                //show red borders of the passwords are not the same
                repeatPasswordTextField.layer.borderColor = UIColor.red.cgColor
                repeatPasswordTextField.layer.borderWidth = 1.0
            }
            
            shake()
        } else {
            repeatPasswordTextField.layer.borderColor = UIColor.clear.cgColor
            repeatPasswordTextField.layer.borderWidth = 0.0
            
            delegate?.didSelectSignup(self, email: email, name: "", password: password, gender: "", birthday: "")
        }
    }
    @IBAction func didPressedTerms(_ sender: Any) {
        delegate?.didPressedTerms(self)
    }
    @IBAction func didPressedPrivacy(_ sender: Any) {
        delegate?.didPressedPrivacy(self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

    }
    
    func shake(){
        signupStackView.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.signupStackView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

// MARK: - Validation

extension SignupViewController {

    var equalPasswordRule: ValidationRuleEquality<String> {
        return ValidationRuleEquality<String>(dynamicTarget: { self.passwordTextField.text ?? "" },
                                              error: ValidationError.passwordNotEqual)
    }

    func setupValidation() {
        //setupValidationOn(field: nameTextField, rules: ValidationService.nameRules)
        //setupValidationOn(field: emailTextField, rules: ValidationService.emailRules)
        //setupValidationOn(field: birthDayTextField, rules: ValidationService.birthRules)


        var passwordRules = ValidationService.passwordRules
        //setupValidationOn(field: passwordTextField, rules: passwordRules)
        passwordRules.add(rule: equalPasswordRule)
        //setupValidationOn(field: repeatPasswordTextField, rules: passwordRules)
    }

    func setupValidationOn(field: SkyFloatingLabelTextField, rules: ValidationRuleSet<String>) {
        field.validationRules = rules
        field.validateOnInputChange(enabled: true)
        field.validationHandler = validationHandlerFor(field: field)
    }

    func validationHandlerFor(field: SkyFloatingLabelTextField) -> ((ValidationResult) -> Void) {
        return { result in
            switch result {
            case .valid:
                guard self.signupAttempted == true else {
                    break
                }
                field.errorMessage = nil
            case .invalid(let errors):
                guard self.signupAttempted == true else {
                    break
                }
                if let errors = errors as? [ValidationError] {
                    field.errorMessage = errors.first?.message
                }
            }
        }
    }

    func validateFields(success: () -> Void) {
        var errorFound = false
        for field in fields {
            let result = field.validate()
            switch result {
            case .valid:
                field.errorMessage = nil
            case .invalid(let errors):
                errorFound = true
                if let errors = errors as? [ValidationError] {
                    field.errorMessage = errors.first?.message
                }
            }
        }
        if !errorFound {
            success()
        }
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        UIView.animate(withDuration: 5.0) {
            self.logoImageView.alpha = 0.0
            self.stackViewCenterConstraint.constant = -180
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        UIView.animate(withDuration: 5.0) {
            self.logoImageView.alpha = 1.0
            self.stackViewCenterConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

}

// MARK: - UITextField Delegate

extension SignupViewController : UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedField = textField
        
        if (selectedField?.placeholder == NSLocalizedString("Birthday", comment: "")){
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            selectedField?.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(SignupViewController.setDate(sender:)), for: .valueChanged)
        }
        
        addAccessoryView(textField)
    }
    
    func addAccessoryView(_ textField: UITextField) -> Void {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .done, target: self, action: #selector(SignupViewController.doneButtonTapped(button:)))
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.items = [flexItem, doneButton]
        toolBar.tintColor = .black
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
        // do you stuff with done here
        selectedField?.resignFirstResponder()
        selectedField = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        selectedField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        let nextResponder = view.viewWithTag(nextTag) as UIResponder!

        if nextResponder != nil {
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            //didSelectSignup(self)
        }
        
        return false
    }
    
    @objc func setDate(sender: UIDatePicker){
        self.birthDayTextField.text = formatDate(date: sender.date)
    }
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let birthDay = formatter.string(from: date)
        return birthDay
    }
    
}
