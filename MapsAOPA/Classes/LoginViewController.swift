//
//  LoginViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/14/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import Sugar
import ReactiveCocoa
import Result

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var progressView : UIProgressView?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView?
    
    private lazy var viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.state.producer.startWithNext({ [weak self] (value) in
            self?.descriptionLabel?.text = value.stateDescription()
            switch value
            {
            case .Loading, .Processing: self?.loadingIndicator?.startAnimating()
            default: self?.loadingIndicator?.stopAnimating()
            }
        })
        viewModel.progress.producer.startWithNext({ [weak self] (value) in
            self?.progressView?.progress = value
        })
        self.loadData()
    }
    
    private func loadData()
    {
        viewModel.loadSignal().on(failed: { [weak self] error in
            print(error)
            if error.domain == Error.domain
            {
                if let errorCode = Error(rawValue: error.code)
                {
                    switch errorCode
                    {
                    case .ApiKeyRequired:
                        let alertController = UIAlertController(title: "title_api_key_required".localized(), message: "message_api_key_required".localized(), preferredStyle: .Alert)
                        let saveAction = UIAlertAction(title: "button_save".localized(), style: UIAlertActionStyle.Default, handler: { (action) in
                            if let textField = alertController.textFields?.first
                            {
                                let text = textField.text ?? ""
                                DataLoader.apiKey = text
                                self?.loadData()
                            }
                        })
                        saveAction.enabled = false
                        alertController.addAction(saveAction)
                        alertController.addAction(UIAlertAction(title: "button_cancel".localized(), style: .Cancel, handler: { (action) in
                            // TODO: show reload button
                            alertController.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        alertController.addTextFieldWithConfigurationHandler({ [weak saveAction] (textField : UITextField) in
                            textField.rac_textSignal().toSignalProducer().startWithNext({ (text) in
                                saveAction?.enabled = ((text as? String)?.length ?? 0) > 0
                            })
                        })
                        self?.presentViewController(alertController, animated: true, completion: nil)
                    default: break
                    }
                }
            }
            else
            {
                let alert = UIAlertView(title: "title_error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "button_ok".localized())
                alert.show()
            }
        },
        completed: { [weak self] in
            self?.performSegueWithIdentifier(Segue.MapSegue.rawValue, sender: self)
        }).start()
    }
}
