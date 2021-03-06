//
//  ForgotPassViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 26/10/21.
//

import UIKit

class ForgotPassViewController: BaseViewController {
    
    @IBOutlet weak var btnSendInstruction: UIButton! {
        didSet {
            btnSendInstruction.addTarget(self, action: #selector(didTapInstruction(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var btnResetPass: UIButton!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!

    
    @IBOutlet weak var viewMainBg: UIView!
    @IBOutlet weak var viewSignUpMain: UIView!
    @IBOutlet weak var viewCountryCode: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var viewTwitter: UIView!
    @IBOutlet weak var viewInstagram: UIView!
    @IBOutlet weak var viewFB: UIView!
    
    
    @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var viwEmail: UIView!
    
    @IBOutlet weak var btnByphone: UIButton!
    @IBOutlet weak var btnByEmail: UIButton!
    @IBOutlet weak var lblByphone: UILabel!
    @IBOutlet weak var lblByEmail: UILabel!
    
    @IBOutlet weak var txtCountryCode: UITextField!
    @IBOutlet weak var imgCountryCode: UIImageView!
    var countryCodeDesc = ""

    let txtPlaceholders = ["Phone Number",  "Email"]


    override func viewDidLoad() {
        super.viewDidLoad()
        localization()
        tabOnByPhoneEmail(isTapOnPhone: true)
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        
        if isDevelopmentMode {
            txtEmail.text = "anjalimendpara625@gmail.com"
        }
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let strPhoneCode = getCountryPhonceCode(countryCode)
            self.imgCountryCode.image = UIImage.init(named: "\(countryCode).png")
            self.txtCountryCode.text = "+\(strPhoneCode)"
            self.countryCodeDesc = countryCode
        }
        
        
        
        [txtPhone,
         txtEmail,
         
         ].enumerated().forEach { index, txt in
            let place = txtPlaceholders[index]
            txt?.attributedPlaceholder = NSAttributedString(string: place, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: COLORS.TEXT_COLOR])
            txt?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            txt?.textColor = COLORS.TEXT_COLOR
            txt?.tintColor = COLORS.TEXT_COLOR
            
            txt?.layer.cornerRadius = 10
            txt?.clipsToBounds = true
        }
    }
    
    func localization() {
//        btnSendInstruction.setTitle("Send Instructions".localized(), for: .normal)
//        btnResetPass.setTitle("Reset Password".localized(), for: .normal)
        
    }
    
    @IBAction func clickToBtnPhone(_ sender: UIButton) {
        tabOnByPhoneEmail(isTapOnPhone: true)
    }
    
    @IBAction func clickToBtnEmail(_ sender: UIButton) {
        tabOnByPhoneEmail(isTapOnPhone: false)
    }
    
    @IBAction func didTapCountryCode(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapInstruction(_ sender: UIButton) {
        
        if viwEmail.isHidden == false { // reset by email
            
            if (txtEmail.text!.isEmpty) {
               self.showAlert(withTitle: "Invalid Email", message: "Please enter valid email")
            } else if !(txtEmail.text!.isValidEmail) {
                self.showAlert(withTitle: "Invalid Email", message: "Please enter valid email")
             }
            else {
                resendOTP()
            }
        } else {
            if (txtPhone.text!.isEmpty) {
               self.showAlert(withTitle: "Invalid Phone Number", message: "Please enter valid phone number")
               
            }  else {
                resendOTP()
            }
        }
        
        
        
//        let vc = SignupCoachViewController.viewcontroller()
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tabOnByPhoneEmail(isTapOnPhone:Bool) {
        
        if isTapOnPhone {
            lblByphone.isHidden = false
            lblByEmail.isHidden = true
            viewPhoneNumber.isHidden = false
            viwEmail.isHidden = true
            
            lblByphone.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            lblByEmail.backgroundColor = hexStringToUIColor(hex: "#ffffff")
            btnByphone.setTitleColor(hexStringToUIColor(hex: "#CC2936"), for: .normal)
            btnByEmail.setTitleColor(hexStringToUIColor(hex: "#ffffff"), for: .normal)

        } else {
            lblByphone.isHidden = true
            lblByEmail.isHidden = false
            viewPhoneNumber.isHidden = true
            viwEmail.isHidden = false
            
            lblByEmail.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            lblByphone.backgroundColor = hexStringToUIColor(hex: "#ffffff")
            btnByEmail.setTitleColor(hexStringToUIColor(hex: "#CC2936"), for: .normal)
            btnByphone.setTitleColor(hexStringToUIColor(hex: "#ffffff"), for: .normal)


        }
        
    }

}


extension ForgotPassViewController {
    
    func resendOTP() {
        showLoader()
        
        var param = [String:Any]()
        
        if viwEmail.isHidden == false {
            
            param["email"] = txtEmail.text!
        
        } else {
            param["phonecode"] = txtCountryCode.text!
            param["phoneno"] = txtPhone.text!
            param["countrycode"] = countryCodeDesc

        }
        
         
        param["type"] = viwEmail.isHidden == false ? "email" : "phone"
            
                
      _ =  ApiCallManager.requestApi(method: .post, urlString: API.RESEND_OTP, parameters: param, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
          print(resObj)
          
          let responseModel = ResponseDataModel(responseObj: resObj)
          
          if responseModel.success {
              
              self.goToOtpScreen(dic: param)
          }
          
          Utility.shared.showToast(responseModel.message)
          self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    
    func goToOtpScreen(dic:[String:Any]) {
        let vc = OTPViewController.viewcontroller()
        vc.isFromForgotPassword = true
        if viwEmail.isHidden == false {
            vc.emaiOrPhone = txtEmail.text!
        } else {
            vc.emaiOrPhone = txtCountryCode.text! + " " + txtPhone.text!
        }
        vc.paramDic = dic
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}


extension ForgotPassViewController: countryPickDelegate {
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        txtCountryCode.text = selectedCountry?.phoneCode
        self.imgCountryCode.image = selectedCountry?.flag
        countryCodeDesc = selectedCountry?.code ?? ""
    }
    
    
}
