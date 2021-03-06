//
//  ScheduleLiveClassViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 15/12/21.
//

import UIKit
import MobileCoreServices

class ScheduleLiveClassViewController: BaseViewController {

    static func viewcontroller() -> ScheduleLiveClassViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "ScheduleLiveClassViewController") as! ScheduleLiveClassViewController
        return vc
    }
    
    var arrClassTypeList = [ClassTypeList]()
    var arrClassDifficultyList = [ClassDifficultyList]()
    var selectClassTypeObj = ClassTypeList()
    var selectClassDifficultyObj = ClassDifficultyList()
    
    @IBOutlet weak var tblClassTypeList : UITableView!
    @IBOutlet weak var tblClassDifficulty : UITableView!
    
    @IBOutlet weak var imgThumbnail : UIImageView!
    
    @IBOutlet weak var lctTableClassTypeHeight : NSLayoutConstraint!
    @IBOutlet weak var lctClassDifficultyHeight : NSLayoutConstraint!
    
    @IBOutlet weak var lblClassDuration : UILabel!
    @IBOutlet weak var lblClassType : UILabel!
    @IBOutlet weak var lblClassDifficulty : UILabel!
    @IBOutlet weak var lblUploadThumbnail : UILabel!
    @IBOutlet weak var lblSubscriptionCurrentSym : UILabel!
    @IBOutlet weak var lblNonSubscriptionCurrentSym : UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblHour: UILabel!
    @IBOutlet weak var lblMin: UILabel!
    
    @IBOutlet weak var btnUploadthumbnail : UIButton!
    
    @IBOutlet weak var txtClassSubTitile : UITextField!
    @IBOutlet weak var txtSubscriberFee : UITextField!
    @IBOutlet weak var txtNonSubscriberFee : UITextField!
    @IBOutlet weak var txtDummyDate: UITextField!
    @IBOutlet weak var txtDummyTime: UITextField!

    
    var classDuration : ClassDuration!
    var selectedButton = UIButton()
    var addPhotoPopUp:AddPhotoPopUp!
    var photoData:Data!
    var uploadedUrl = ""
    var thumbailUrl = ""
    var nationalityView : NationalityView!
    var arrNationalityData = [NationalityData]()
    var selectedCurrency = ""
    var customDatePickerForSelectDate:CustomDatePickerViewForTextFeild!
    var customDatePickerForSelectTime:CustomDatePickerViewForTextFeild!
    var selectedDate = ""
    var selectedTime = ""
    var isFromEdit = false
    var classDetailDataObj = ClassDetailData()

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = true
        tblClassTypeList.register(UINib(nibName: "ClassTypeListItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassTypeListItemTableViewCell")
        tblClassTypeList.delegate = self
        tblClassTypeList.dataSource = self
        
        tblClassDifficulty.register(UINib(nibName: "ClassTypeListItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassTypeListItemTableViewCell")
        tblClassDifficulty.delegate = self
        tblClassDifficulty.dataSource = self
        
        tblClassTypeList.isHidden = true
        tblClassDifficulty.isHidden = true
        
        classDuration = Bundle.main.loadNibNamed("ClassDuration", owner: nil, options: nil)?.first as? ClassDuration
        classDuration.tapToBtnSelectItem { obj in
            self.lblClassDuration.text = obj + " mins"
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
            self.lblNonSubscriptionCurrentSym.text = "S" + obj.currency_symbol
            self.selectedCurrency = obj.currency
            
        }
        
        customDatePickerForSelectDate = CustomDatePickerViewForTextFeild(textField: txtDummyDate, format: "yyyy-MM-dd", mode: .date)
        customDatePickerForSelectDate.pickerView { (str, date) in
            let arrStr = str.components(separatedBy: "-")
            self.selectedDate = str
            self.lblDate.text = arrStr.last
            self.lblMonth.text = arrStr[1]
            self.lblYear.text = arrStr.first
        }
        
        customDatePickerForSelectTime = CustomDatePickerViewForTextFeild(textField: txtDummyTime, format: "HH:mm", mode: .time)
        customDatePickerForSelectTime.pickerView { (str, date) in
            let arrStr = str.components(separatedBy: ":")
            self.selectedTime = str
            self.lblMin.text = arrStr.last
            self.lblHour.text = arrStr.first
        }
        
        
        getClassType()
        
        
    }
    
    func setData() {
        lblClassType.text = classDetailDataObj.class_type
        selectClassTypeObj = arrClassTypeList.first { obj in
            return classDetailDataObj.class_type.lowercased() == obj.class_type_name.lowercased()
        } ?? ClassTypeList()
        
        txtClassSubTitile.text = classDetailDataObj.class_subtitle
        lblClassDifficulty.text = classDetailDataObj.class_difficulty
        
        
        selectClassDifficultyObj = arrClassDifficultyList.first { obj in
            return classDetailDataObj.class_difficulty.lowercased() == obj.class_difficulty_name.lowercased()
        } ?? ClassDifficultyList()
        
        self.lblClassDuration.text = classDetailDataObj.duration
        txtSubscriberFee.text = classDetailDataObj.feesDataObj.base_subscriber_fee
        txtNonSubscriberFee.text = classDetailDataObj.feesDataObj.base_non_subscriber_fee
        
        let ind = arrNationalityData.firstIndex { obj in
            return classDetailDataObj.feesDataObj.base_currency == obj.currency
        }
        
        if ind != nil {
            let obj = arrNationalityData[ind!]
            self.lblSubscriptionCurrentSym.text = "S" + obj.currency_symbol
            self.lblNonSubscriptionCurrentSym.text = "S" + obj.currency_symbol
        }
        
        self.selectedCurrency = classDetailDataObj.feesDataObj.base_currency
        thumbailUrl = classDetailDataObj.thumbnail_image
        imgThumbnail.setImageFromURL(imgUrl: classDetailDataObj.thumbnail_image, placeholderImage: nil)
        
        let arrStr = classDetailDataObj.class_date.components(separatedBy: "-")
        self.selectedDate = classDetailDataObj.class_date
        self.lblDate.text = arrStr.last
        self.lblMonth.text = arrStr[1]
        self.lblYear.text = arrStr.first
        
        let arrtime = classDetailDataObj.class_time.components(separatedBy: ":")
        self.selectedTime = classDetailDataObj.class_time
        self.lblMin.text = arrtime.last
        self.lblHour.text = arrtime.first
        
    }
    
    func setClassDurationView(){
        
        classDuration.frame.size = self.view.frame.size
        
        self.view.addSubview(classDuration)
    }
    
    func removeClassDurationView(){
        if classDuration != nil{
            classDuration.removeFromSuperview()
        }
        
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
    
    
    // MARK: - Click Event
    @IBAction func clickToBtnClassType(_ sender : UIButton) {
        tblClassTypeList.isHidden = !tblClassTypeList.isHidden
    }
    
    @IBAction func clickToBtnClassDifficulty(_ sender : UIButton) {
        tblClassDifficulty.isHidden = !tblClassDifficulty.isHidden
    }
    
    @IBAction func clickToBtnClassDuration(_ sender : UIButton) {
        setClassDurationView()
    }
    
    @IBAction func clickTobBtnSelectSubscriptionCurrency(_ sender: UIButton) {
        setNationalityView()
    }
    
    @IBAction func clickToBtnNext(_ sender : UIButton) {
        
        
         if  thumbailUrl.isEmpty {
            Utility.shared.showToast("Please select thumbnail Image")
        } else if selectClassTypeObj.id.isEmpty {
            Utility.shared.showToast("Class type is required")
        } else if txtClassSubTitile.text!.isEmpty {
            Utility.shared.showToast("Class subtitle is required")
        } else if selectClassDifficultyObj.id.isEmpty {
            Utility.shared.showToast("Class difficulty level is required")
        } else if selectedDate.isEmpty {
            Utility.shared.showToast("Date is required")
        }else if selectedTime.isEmpty {
            Utility.shared.showToast("Time is required")
        }else if lblClassDuration.text!.lowercased() == "0 mins" {
            Utility.shared.showToast("Class duration is required")
        } else if txtSubscriberFee.text!.isEmpty {
            Utility.shared.showToast("Subscriber fee is required")
        } else if txtNonSubscriberFee.text!.isEmpty {
            Utility.shared.showToast("Non-Subscriber fee is required")
        } else {
            var param = [String : Any]()
            param["coach_class_type"] = "live"
            param["class_subtitle"] = txtClassSubTitile.text!
            param["class_type_id"] = "\(selectClassTypeObj.id)"
            param["class_difficulty_id"] = "\(selectClassDifficultyObj.id)"
            param["class_date"] = selectedDate
            param["class_time"] = selectedTime
            param["duration"] = lblClassDuration.text!
            param["subscriber_fee"] = txtSubscriberFee.text!
            param["non_subscriber_fee"] = txtNonSubscriberFee.text!
            param["thumbnail_image"] = thumbailUrl
            param["base_currency"] = selectedCurrency
                    
            let vc = UserMusclesForLiveClassViewController.viewcontroller()
            vc.paramDic = param
            vc.isFromEdit = self.isFromEdit
            vc.classDetailDataObj = self.classDetailDataObj
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
        
    }
        
    @IBAction func clickToBtnUplaodThumbnail(_ sender : UIButton) {
        
        //goToPerticularTab(index: 3)
        selectedButton = btnUploadthumbnail
        setAddPhotoView()
    }
    
}



// MARK: - API call
extension ScheduleLiveClassViewController {
    
    func getClassType() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.CLASS_TYPE_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrClassTypeList = ClassTypeList.getData(data: dataObj)
                self.tblClassTypeList.layoutIfNeeded()
                self.tblClassTypeList.reloadData()
                self.lctTableClassTypeHeight.constant =  self.tblClassTypeList.contentSize.height
//                if !self.arrClassTypeList.isEmpty {
//                    self.tableView(self.tblClassTypeList, didSelectRowAt: IndexPath(item: 0, section: 0))
//                }
            }
            
            self.hideLoader()
            self.getClassDifficultyList()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func getClassDifficultyList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.CLASS_DIFFICULTY_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrClassDifficultyList = ClassDifficultyList.getData(data: dataObj)
                self.tblClassDifficulty.layoutIfNeeded()
                self.tblClassDifficulty.reloadData()
                self.lctClassDifficultyHeight.constant =  self.tblClassDifficulty.contentSize.height
//                if !self.arrClassDifficultyList.isEmpty {
//                    self.tableView(self.tblClassDifficulty, didSelectRowAt: IndexPath(item: 0, section: 0))
//                }
            }
            
            self.hideLoader()
            self.getNationality()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
        
    func uploadVideoThumbnail() {
        showLoader()
        
        var finalDataParameters = [AnyObject]()
        if photoData != nil {
            var imageDic = [String:AnyObject]()
            
            imageDic["file_data"] = photoData as AnyObject?
            imageDic["param_name"] = "thumbnail_image" as AnyObject?
            imageDic["file_name"] = UUID().uuidString + ".jpeg" as AnyObject?
            imageDic["mime_type"] = "image" as AnyObject?
            
            finalDataParameters.append(imageDic as AnyObject)
        }
        
        let param = [
            "coach_class_type":  "live"
        ] as [String : Any]
        
        ApiCallManager.callApiWithUpload(apiURL: API.UPLOAD_VIDEO_THUMBNAIL, method: .post, parameters: param, fileParameters: finalDataParameters, headers: nil, success: { (responseObj, code) in
            
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
            self.thumbailUrl = dataObj["thumbnail_image"] as? String ?? ""
            
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
            
            if self.isFromEdit {
                self.setData()
            }
            
            self.hideLoader()
            
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}


extension ScheduleLiveClassViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblClassDifficulty {
            return arrClassDifficultyList.count
        }
        return arrClassTypeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblClassDifficulty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeListItemTableViewCell", for: indexPath) as! ClassTypeListItemTableViewCell
            let obj = arrClassDifficultyList[indexPath.row]
            cell.lblTitle.text = obj.class_difficulty_name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeListItemTableViewCell", for: indexPath) as! ClassTypeListItemTableViewCell
            let obj = arrClassTypeList[indexPath.row]
            cell.lblTitle.text = obj.class_type_name
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblClassDifficulty {
            selectClassDifficultyObj = arrClassDifficultyList[indexPath.row]
            self.lblClassDifficulty.text = selectClassDifficultyObj.class_difficulty_name
            tblClassDifficulty.isHidden = true
        } else {
            selectClassTypeObj = arrClassTypeList[indexPath.row]
            self.lblClassType.text = selectClassTypeObj.class_type_name
            tblClassTypeList.isHidden = true
        }
        
        
    }
}



// MARK: - UIImagePickerControllerDelegate and Take a Photo or Choose from Gallery Methods
extension ScheduleLiveClassViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var editedImage:UIImage?
        
            editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            if editedImage == nil {
                editedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
            
            photoData = editedImage!.jpegData(compressionQuality: 1.0)
            self.imgThumbnail.image = editedImage
            self.uploadVideoThumbnail()
        
        
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

