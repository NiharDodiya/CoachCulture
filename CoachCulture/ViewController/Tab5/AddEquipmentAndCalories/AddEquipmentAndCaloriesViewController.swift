//
//  AddEquipmentAndCaloriesViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 07/12/21.
//

import UIKit
import KMPlaceholderTextView

class AddEquipmentAndCaloriesViewController: BaseViewController {
    
    static func viewcontroller() -> AddEquipmentAndCaloriesViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AddEquipmentAndCaloriesViewController") as! AddEquipmentAndCaloriesViewController
        return vc
    }
    
    @IBOutlet weak var tblAddEquipment: UITableView!
    @IBOutlet weak var tblEquipmentList: UITableView!
    
    @IBOutlet weak var lblCharCount: UILabel!

    
    @IBOutlet weak var lctAddEquipmentTableHeight: NSLayoutConstraint!
    @IBOutlet weak var lctEquipmentListTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viwBurntCalories: UIView!
    
    @IBOutlet weak var txtCalories: UITextField!
    @IBOutlet weak var txtDescription: KMPlaceholderTextView!

    
    var arrEquipmentList = [EquipmentList]()
    var arrAddedEquipment = [EquipmentList]()
    var currentSelectedIndForEquipment = 0
    var currentSelectedIndForCell = 0
    var paramDic = [String : Any]()
    var isFromEdit = false
    var classDetailDataObj = ClassDetailData()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - methods
    func setUpUI() {
        getEquipmentList()
        tblAddEquipment.register(UINib(nibName: "AddEquipmentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "AddEquipmentItemTableViewCell")
        tblAddEquipment.delegate = self
        tblAddEquipment.dataSource = self
        
        tblEquipmentList.register(UINib(nibName: "ClassTypeListItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassTypeListItemTableViewCell")
        tblEquipmentList.delegate = self
        tblEquipmentList.dataSource = self
        tblEquipmentList.isHidden = true
        txtDescription.delegate = self
        viwBurntCalories.applyBorder(8.0, borderColor: hexStringToUIColor(hex: "#CC2936"))
        
    }
    
    func addSelectedDataToCell() {
        let selectedObj = arrEquipmentList[currentSelectedIndForEquipment]
        arrAddedEquipment.remove(at: currentSelectedIndForCell)
        arrAddedEquipment.insert(selectedObj, at: currentSelectedIndForCell)
        tblAddEquipment.reloadData()
        tblAddEquipment.scrollToBottom()
    }
    
    func setData() {
        for temp in  classDetailDataObj.arrEquipmentList {
            let obj = EquipmentList()
            obj.id = temp.equipment_id
            obj.equipment_name = temp.equipment_name
            arrAddedEquipment.append(obj)
        }
        txtCalories.text = classDetailDataObj.burn_calories
        txtDescription.text = classDetailDataObj.description
        self.tblAddEquipment.layoutIfNeeded()
        self.tblAddEquipment.reloadData()
        self.lctAddEquipmentTableHeight.constant = self.tblAddEquipment.contentSize.height
        lblCharCount.text = "\(txtDescription.text.count)" + "/300"
        
    }
    
    // MARK: - Click Events
    @IBAction func clickToBTnAddEquipment( _ sender : UIButton) {
        let obj = EquipmentList()
        obj.equipment_name = "Select Equipment"
        arrAddedEquipment.append(obj)
        self.tblAddEquipment.layoutIfNeeded()
        self.tblAddEquipment.reloadData()
        self.lctAddEquipmentTableHeight.constant = self.tblAddEquipment.contentSize.height
        
        self.tblAddEquipment.layoutIfNeeded()
        self.tblAddEquipment.reloadData()
        self.lctAddEquipmentTableHeight.constant = self.tblAddEquipment.contentSize.height
        
    }
    
    @IBAction func clickToBTnSelectEquipment( _ sender : UIButton) {
        
        tblEquipmentList.isHidden = false
        currentSelectedIndForCell = sender.tag
    }
    
    // MARK: - Click Events
    @IBAction func clickToBTnAddDeleteEquipment( _ sender : UIButton) {
        
        arrAddedEquipment.remove(at: sender.tag)
        self.tblAddEquipment.layoutIfNeeded()
        self.tblAddEquipment.reloadData()
        self.lctAddEquipmentTableHeight.constant = self.tblAddEquipment.contentSize.height
        
    }
    
    @IBAction func clickToBTnCreateCoachClass( _ sender : UIButton) {
        
        var equipment = ""
        for temp in arrAddedEquipment {
            if equipment.isEmpty {
                equipment = temp.id
            } else {
                equipment += "," + temp.id
            }
        }
       
        if equipment.isEmpty {
            Utility.shared.showToast("Please add equipment")
        } else if txtCalories.text!.isEmpty {
            Utility.shared.showToast("Calories required")
        } else if txtDescription.text!.isEmpty {
            Utility.shared.showToast("Description required")
        } else {
            paramDic["equipment"] = equipment
            paramDic["burn_calories"] = txtCalories.text!
            paramDic["description"] = txtDescription.text!
            
            createClass()
        }
        
       
        
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AddEquipmentAndCaloriesViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblEquipmentList {
            return arrEquipmentList.count
        }
        return arrAddedEquipment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblEquipmentList {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeListItemTableViewCell", for: indexPath) as! ClassTypeListItemTableViewCell
            let obj = arrEquipmentList[indexPath.row]
            cell.lblTitle.text = obj.equipment_name
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddEquipmentItemTableViewCell", for: indexPath) as! AddEquipmentItemTableViewCell
            let obj = arrAddedEquipment[indexPath.row]
            cell.lblTitle.text = obj.equipment_name
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(self.clickToBTnAddDeleteEquipment(_:)), for: .touchUpInside)
            
            cell.btnSelectItem.tag = indexPath.row
            cell.btnSelectItem.addTarget(self, action: #selector(self.clickToBTnSelectEquipment(_:)), for: .touchUpInside)
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
        if tableView == tblEquipmentList {
            tblEquipmentList.isHidden = true
            currentSelectedIndForEquipment = indexPath.row
            addSelectedDataToCell()
        }
    }
}


// MARK: - API call
extension AddEquipmentAndCaloriesViewController {
    
    func getEquipmentList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.EQUIPMENT_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrEquipmentList = EquipmentList.getData(data: dataObj)
                if self.arrEquipmentList.count > 0 && self.isFromEdit == false {
                    self.arrAddedEquipment.append(self.arrEquipmentList.first!)
                    self.tblEquipmentList.layoutIfNeeded()
                    self.tblEquipmentList.reloadData()
                    self.lctEquipmentListTableHeight.constant = self.tblEquipmentList.contentSize.height
                }
                
                self.tblEquipmentList.layoutIfNeeded()
                self.tblEquipmentList.reloadData()
                self.lctEquipmentListTableHeight.constant = self.tblEquipmentList.contentSize.height
                
                if self.isFromEdit {
                    self.setData()
                }
                
                
                
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    
    func createClass() {
        showLoader()
        var url = API.CREATE_COACH_CLASS
        if self.isFromEdit {
            paramDic["id"] = self.classDetailDataObj.id
            url = API.EDIT_COACH_CLASS
        }
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: url, parameters: paramDic, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()                
            }
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}


extension UITableView {
    
    func scrollToBottom(isAnimated:Bool = true){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }
    
    func scrollToTop(isAnimated:Bool = true) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}


// MARK: - UITextViewDelegate
extension AddEquipmentAndCaloriesViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let finalString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if finalString.count < 300 {
                      
            lblCharCount.text = "\(finalString.count)" + "/300"
            return true
        } else {
            return false
        }
        
       
    }
    
}
