//
//  RecipeDetailsViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 11/12/21.
//

import UIKit

class RecipeDetailsViewController: BaseViewController {
    
    static func viewcontroller() -> RecipeDetailsViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetailsViewController") as! RecipeDetailsViewController
        return vc
    }
    
    @IBOutlet weak var lblMealType: UILabel!
    @IBOutlet weak var lblRecipeDuration: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblRecipeTitle: UILabel!
    @IBOutlet weak var lblRecipeSubTitle: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblDate: UILabel!

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgRecipeCover: UIImageView!
    @IBOutlet weak var imgBookmark: UIImageView!

    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    @IBOutlet weak var tblIntredienta: UITableView!
    
    @IBOutlet weak var viwSatFat: UIView!
    @IBOutlet weak var viwFat: UIView!
    @IBOutlet weak var viwCarbs: UIView!
    @IBOutlet weak var viwSugar: UIView!
    @IBOutlet weak var viwProtein: UIView!
    @IBOutlet weak var viwSodium: UIView!
    @IBOutlet weak var viwNutritionFacts: UIView!
    @IBOutlet weak var viwViewRecipe: UIView!
    
    var recipeDetailDataObj = RecipeDetailData()
    var dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecipeDetails()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viwNutritionFacts.roundCorners(corners: [.bottomLeft], radius: 30)
        viwViewRecipe.roundCorners(corners: [.bottomRight], radius: 30)
    }
    
    
    func setUpUI() {
        
        viwSatFat.applyBorder(4, borderColor: hexStringToUIColor(hex: "#CC2936"))
        viwFat.applyBorder(4, borderColor: hexStringToUIColor(hex: "#4DB748"))
        viwCarbs.applyBorder(4, borderColor: hexStringToUIColor(hex: "#1A82F6"))
        viwSugar.applyBorder(4, borderColor: hexStringToUIColor(hex: "#D5A82C"))
        viwProtein.applyBorder(4, borderColor: hexStringToUIColor(hex: "#FEDC31"))
        viwSodium.applyBorder(4, borderColor: hexStringToUIColor(hex: "#C731FA"))
                        
        clvDietaryRestriction.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        
        
        tblIntredienta.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientTableViewCell")
        tblIntredienta.delegate = self
        tblIntredienta.dataSource = self
        tblIntredienta.layoutIfNeeded()
        
        
        dropDown.dataSource  = ["Edit", "Delete", "Send", "Template", "Rating"]
        dropDown.anchorView = btnMore
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 { //Edit
                let vc = CreateMealRecipeViewController.viewcontroller()
                vc.isFromEdit = true
                vc.recipeDetailDataObj = self.recipeDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if index == 1 { //Delete
                
            }
            
            if index == 4 { //Rating
                let vc = GiveRecipeRattingViewController.viewcontroller()
                vc.recipeDetailDataObj = self.recipeDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        dropDown.selectionBackgroundColor = .clear
        
        
        hideTabBar()
    }
    
    func setData() {
        lblMealType.text = recipeDetailDataObj.arrMealTypeString
        lblRecipeDuration.text = recipeDetailDataObj.duration
        clvDietaryRestriction.reloadData()
        imgRecipeCover.setImageFromURL(imgUrl: recipeDetailDataObj.thumbnail_image, placeholderImage: nil)
        
        if recipeDetailDataObj.bookmark.lowercased() == "no".lowercased() {
            imgBookmark.image = UIImage(named: "BookmarkLight")
        } else {
            imgBookmark.image = UIImage(named: "Bookmark")
        }
        
        lblUserName.text = recipeDetailDataObj.coachDetailsObj.username
        imgUserProfile.setImageFromURL(imgUrl: recipeDetailDataObj.coachDetailsObj.user_image, placeholderImage: nil)
        lblRecipeTitle.text = recipeDetailDataObj.title
        lblRecipeSubTitle.text = recipeDetailDataObj.sub_title
        lblViews.text = recipeDetailDataObj.total_viewers + "Views"
        lblDate.text = recipeDetailDataObj.created_at
        
        tblIntredienta.reloadData()
        
    }

    // MARK: - Click events
    @IBAction func clickToBtnAddIngredient(_ sender : UIButton) {
       
    }
    
    @IBAction func clickToBtnNutritionFacts(_ sender : UIButton) {
       
    }
    
    @IBAction func clickToBtnViewRecipe(_ sender : UIButton) {
       
    }
    
    @IBAction func clickToBtnBookMark(_ sender : UIButton) {
        
        if recipeDetailDataObj.bookmark.lowercased() == "no".lowercased() {
            addOrRemoveFromBookMark(bookmark: "yes")
        } else {
            addOrRemoveFromBookMark(bookmark: "no")
        }
        
    }
    
    @IBAction func clickToBtn3Dots( _ sender: UIButton) {
        dropDown.show()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension RecipeDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return recipeDetailDataObj.arrDietaryRestrictionListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj = recipeDetailDataObj.arrDietaryRestrictionListData[indexPath.row]
        cell.lblTitle.text = obj.dietary_restriction_name
        cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#061424")
       
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvDietaryRestriction.frame.width - 20 ) / 2
        return CGSize(width: width, height: 40)
    }
        
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RecipeDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDetailDataObj.arrQtyIngredient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientTableViewCell", for: indexPath) as! RecipeIngredientTableViewCell
        let obj = recipeDetailDataObj.arrQtyIngredient[indexPath.row]
        cell.lblQty.text = obj.quantity
        cell.lblIngredient.text = obj.ingredients
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


// MARK: - API CALL
extension RecipeDetailsViewController {
    func getRecipeDetails() {
        showLoader()
        let param = ["id" : "9"]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.RECIPE_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_recipe"] as? [String:Any] ?? [String:Any]()
            self.recipeDetailDataObj = RecipeDetailData(responseObj: dataObj)
            self.setData()
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    
    func addOrRemoveFromBookMark(bookmark : String) {
        showLoader()
        let param = ["coach_recipe_id" : "9","bookmark" : bookmark]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_REMOVE_BOOKMARK, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            self.getRecipeDetails()
            Utility.shared.showToast(responseModel.message)
           
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}
