//
//  EditProfileViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import AWSS3
import AWSCognito

class EditProfileViewController: BaseViewController {
    
    static func viewcontroller() -> EditProfileViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        return vc
    }
    
    @IBOutlet weak var viwLine1: UIView!
    @IBOutlet weak var viwLine2: UIView!
    @IBOutlet weak var viwCoachContent: UIView!
    @IBOutlet weak var viwEditProfile: UIView!
    
    @IBOutlet weak var lblSubscriptionCurrentSym: UILabel!
    @IBOutlet weak var lblCoachTrailer: UILabel!

    
    @IBOutlet weak var btnCoachContent: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnUploadCoachBanner: UIButton!
    @IBOutlet weak var btnEditUserPhoto: UIButton!
    @IBOutlet weak var btnCoachTrailer: UIButton!
    
    @IBOutlet weak var imgCoachBanner: UIImageView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgCountryCode: UIImageView!
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMonthlySubscriptionFees: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRetypePassword: UITextField!
    @IBOutlet weak var txtCountryCode: UITextField!
    
    var countryCodeDesc = ""
    var addPhotoPopUp:AddPhotoPopUp!
    var userDataObj = UserData()
    var photoData:Data!
    var selectedButton = UIButton()
    var user_image = ""
    var coach_banner_file = ""
    var coach_trailer_file = ""
    var nationalityView : NationalityView!
    var arrNationalityData = [NationalityData]()
    var selectedCurrency = ""
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    //var uploadedUrl = ""
    
    
    
    // MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    func setUpUI() {
        clickToBtnCoachContentEdit(btnCoachContent)
        
        imgUserProfile.applyBorder(3, borderColor: hexStringToUIColor(hex: "#CC2936"))
        imgUserProfile.addCornerRadius(5)
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let strPhoneCode = getCountryPhonceCode(countryCode)
            self.imgCountryCode.image = UIImage.init(named: "\(countryCode).png")
            self.txtCountryCode.text = "+\(strPhoneCode)"
            self.countryCodeDesc = countryCode
        }
        
        addPhotoPopUp = Bundle.main.loadNibNamed("AddPhotoPopUp", owner: nil, options: nil)?.first as? AddPhotoPopUp
        addPhotoPopUp.tapToBtnCamera {
            self.loadCameraView()
            self.removeAddPhotoView()
        }
        
        addPhotoPopUp.tapToBtnGallery {
            self.loadPhotoGalleryView()
            self.removeAddPhotoView()
        }
        
        nationalityView = Bundle.main.loadNibNamed("NationalityView", owner: nil, options: nil)?.first as? NationalityView
        nationalityView.tapToBtnSelectItem { obj in
            
            self.lblSubscriptionCurrentSym.text = "S" + obj.currency_symbol
            
            self.selectedCurrency = obj.currency
            
        }
        
        getUserProfile()
        getNationality()
        hideTabBar()
    }
    
    func setAddPhotoView(){
        
        addPhotoPopUp.frame.size = self.view.frame.size
        
        self.view.addSubview(addPhotoPopUp)
    }
    
    func removeAddPhotoView(){
        if addPhotoPopUp != nil{
            addPhotoPopUp.removeFromSuperview()
        }
        
    }
    
    func setNationalityView(){
        nationalityView.frame.size = self.view.frame.size
        self.view.addSubview(nationalityView)
    }
    
    func removeNationalityView(){
        if nationalityView != nil{
            nationalityView.removeFromSuperview()
        }
    }
    
    func setData() {
        self.selectedCurrency = userDataObj.base_currency
        txtUserName.text = userDataObj.username
        txtEmail.text = userDataObj.email
        txtPhone.text = userDataObj.phoneno
        txtCountryCode.text = userDataObj.phonecode
        countryCodeDesc = userDataObj.countrycode
        self.imgCountryCode.image = UIImage.init(named: "\(countryCodeDesc).png")
        self.imgUserProfile.setImageFromURL(imgUrl: userDataObj.user_image, placeholderImage: nil)
        txtMonthlySubscriptionFees.text =   "10" //userDataObj.monthly_subscription_fee
        coach_trailer_file = userDataObj.coach_trailer_file
        if !userDataObj.coach_trailer_file.isEmpty {
            lblCoachTrailer.text = "Delete Coach Trailer"
        }
        
    }
    
    // MARK: - Click Event
    
    @IBAction func clickToBtnCoachContentEdit(_ sender : UIButton) {
        
        if sender == btnCoachContent  {
            viwLine1.isHidden = false
            viwCoachContent.isHidden = false
            viwLine2.isHidden = true
            viwEditProfile.isHidden = true
            
        } else {
            
            viwLine2.isHidden = false
            viwEditProfile.isHidden = false
            viwCoachContent.isHidden = true
            viwLine1.isHidden = true
        }
    }
    
    @IBAction func clickToBtnUploadCoachBanner(_ sender : UIButton) {
        selectedButton = btnUploadCoachBanner
        setAddPhotoView()
    }
    
    @IBAction func clickToBtnUploadCoachTrailer(_ sender : UIButton) {
        
        if userDataObj.coach_trailer_file.isEmpty {
            
            selectedButton = btnCoachTrailer
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.mediaTypes = [kUTTypeMovie as String]
            self.present(picker, animated: true, completion: nil)
        } else {
            deleteCoachTrailerFile()
        }
    }
    
    @IBAction func clickToBtnPlayCoachTrailer(_ sender : UIButton) {
        
        let videoURL = URL(string: userDataObj.coach_trailer_file)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func didTapCountryCode(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func clickTobBtnEditPhoto(_ sender: UIButton) {
        selectedButton = btnEditUserPhoto
        setAddPhotoView()
    }
    
    @IBAction func clickTobBtnSubmitProfile(_ sender: UIButton) {
        if txtUserName.text!.isEmpty {
            Utility.shared.showToast("User Name is a mandatory field.")
        } else if txtEmail.text!.isEmpty {
            Utility.shared.showToast("Email is a mandatory field.")
        } else  if !txtEmail.text!.isValidEmail {
            Utility.shared.showToast("Email is not valid.")
        }   else if txtPhone.text!.isEmpty {
            Utility.shared.showToast("Phone number is a mandatory field.")
        } else if txtMonthlySubscriptionFees.text!.isEmpty {
            Utility.shared.showToast("Enter your monthly subscription fee.")
        } else if txtPassword.text!.isEmpty {
            Utility.shared.showToast("Password is a mandatory field.")
        } else {
            editUserProfile()
        }
    }
    
    @IBAction func clickTobBtnCoachContentsButton(_ sender: UIButton) {
        if sender.tag == 0 { //on demand
            let vc = OnDemandVideoUploadViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if sender.tag == 1 {
            let vc = ScheduleLiveClassViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if sender.tag == 2 {
            let vc = CreateMealRecipeViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if sender.tag == 3 {
            let vc = PreviousUploadViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if sender.tag == 4 {
            let vc = RecipeDetailsViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickTobBtnSelectSubscriptionCurrency(_ sender: UIButton) {
        setNationalityView()
    }
    
}


extension EditProfileViewController: countryPickDelegate {
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        txtCountryCode.text = selectedCountry?.phoneCode
        self.imgCountryCode.image = selectedCountry?.flag
        countryCodeDesc = selectedCountry?.code ?? ""
    }
    
    
}

//MARK: - API CALL
extension EditProfileViewController {
    func getUserProfile() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.GET_PROFILE, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [String:Any] ?? [String:Any]()
                self.userDataObj = UserData(responseObj: dataObj)
                self.setData()
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func uploadUserPhoto() {
        showLoader()
        
        var finalDataParameters = [AnyObject]()
        if photoData != nil {
            var imageDic = [String:AnyObject]()
            
            imageDic["file_data"] = photoData as AnyObject?
            imageDic["param_name"] = selectedButton == btnEditUserPhoto ? "user_image" as AnyObject? : "coach_banner_file" as AnyObject?
            imageDic["file_name"] = "image.jpeg" as AnyObject?
            imageDic["mime_type"] = "image" as AnyObject?
            
            finalDataParameters.append(imageDic as AnyObject)
        }
        
        let param = [
            "type": selectedButton == btnEditUserPhoto ? "user_image" : "coach_banner_file"
        ] as [String : Any]
        
        ApiCallManager.callApiWithUpload(apiURL: API.UPLOAD_USER_IMAGE, method: .post, parameters: param, fileParameters: finalDataParameters, headers: nil, success: { (responseObj, code) in
            
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                if self.selectedButton == self.btnEditUserPhoto {
                    self.user_image = dataObj["user_image"] as? String ?? ""
                    
                } else {
                    self.coach_banner_file = dataObj["user_image"] as? String ?? ""
                }
            }
            
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
        }, failure: { error, code in
            self.hideLoader()
            return true
        })
    }
    
    func getNationality() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.NATIONALITY_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrNationalityData = NationalityData.getData(data: dataObj)
                self.nationalityView.arrNationalityData = self.arrNationalityData
                self.nationalityView.isFromCoachClass = true
                self.nationalityView.setUpUI()
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func editUserProfile() {
        
        showLoader()
        
        let param = [
            "countrycode": countryCodeDesc,
            "phonecode": txtCountryCode.text!,
            "phoneno" : txtPhone.text!,
            "password" : txtPassword.text!,
            "email" : txtEmail.text!,
            "username": txtUserName.text!,
            "user_image" : user_image,
            "coach_banner_file" : coach_banner_file,
            "first_name" : self.userDataObj.first_name,
            "last_name" : self.userDataObj.last_name,
            "monthly_subscription_fee" : txtMonthlySubscriptionFees.text!,
            "base_currency" : selectedCurrency,
            "coach_trailer_file" : coach_trailer_file

        ] as [String : Any]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.EDIT_COACH_PROFILE, parameters: param, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            if responseModel.success {
                let dataObj = responseObj["data"] as? [String:Any] ?? [String:Any]()
                self.userDataObj = UserData(responseObj: dataObj)
                self.setData()
            }
            
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    
    func deleteCoachTrailerFile() {
        
        showLoader()
        
        let param = [
            "type": "coach_trailer_file",
        ] as [String : Any]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.DELETE_USER_IMAGE, parameters: param, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            if responseModel.success {
               
                self.lblCoachTrailer.text = "Upload Coach Trailer"
                self.userDataObj.coach_trailer_file = ""
                
            }
            
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func uploadCoachTrailer(nameOfResource : String, Url : URL){   //1
        
        showLoader()
        
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            print(progress.fractionCompleted)   //2
            if progress.isFinished{           //3
                print("Upload Finished...")
                Utility.shared.showToast("Video uploaded successfully")
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(BUCKET_NAME).appendingPathComponent(nameOfResource)
                print("Uploaded to:\(String(describing: publicURL))")
                self.coach_trailer_file = publicURL?.absoluteString ?? ""
                self.hideLoader()
                //do any task here.
            }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")   //4
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        completionHandler = { (task:AWSS3TransferUtilityUploadTask, error:NSError?) -> Void in
            if(error != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(BUCKET_NAME).appendingPathComponent(nameOfResource)
                print("Uploaded to:\(String(describing: publicURL))")
            }
            
            self.hideLoader()
            
        } as? AWSS3TransferUtilityUploadCompletionHandlerBlock
        
        
        //5
        AWSS3TransferUtility.default().uploadFile(Url, bucket: BUCKET_NAME, key: nameOfResource, contentType: "video", expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
        
   
}


// MARK: - UIImagePickerControllerDelegate and Take a Photo or Choose from Gallery Methods
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var editedImage:UIImage?
        
        if selectedButton == btnCoachTrailer {
            
            guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                return
            }
            do {
                photoData = try Data(contentsOf: videoUrl, options: .mappedIfSafe)
                
            } catch  {
            }
            
            self.uploadCoachTrailer(nameOfResource: videoUrl.lastPathComponent, Url: videoUrl)
            
        } else {
            editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            if editedImage == nil {
                editedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
            
            photoData = editedImage!.jpegData(compressionQuality: 1.0)
            
            if selectedButton == btnEditUserPhoto {
                imgUserProfile.image = editedImage
            } else if selectedButton == btnUploadCoachBanner {
                imgCoachBanner.image = editedImage
            }
            
            
            
            self.uploadUserPhoto()
        }
        
        
        
    }
    
    
    func loadCameraView() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.navigationBar.tintColor =  #colorLiteral(red: 0.2352941176, green: 0.5098039216, blue: 0.6666666667, alpha: 1)
            imagePickerController.sourceType = .camera
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            imagePickerController.showsCameraControls = true
            present(imagePickerController, animated: true, completion: nil)
        } else {
            
        }
    }
    
    func loadPhotoGalleryView() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            
        }
    }
}
