//打開cmd
//cd到專案下
//輸入pod init產生Podfile檔案
//貼上 pod 'TesseractOCRiOS', '4.0.0' 於Podfile
//於cmd輸入 pod install,產生workspace檔案
//打開workspace,於Build Settings將兩個Bitcode改成No
//在Build Phases的Link Binary 加入 libz.tbd
//若能正確import TesseractOCR則成功
import UIKit
import TesseractOCR
import CropViewController
import GPUImage
import AVFoundation

class ViewController: UIViewController ,G8TesseractDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate{
    var originalPicture : UIImage?
    @IBOutlet weak var testImg: UIImageView!
    @IBAction func testSlide(_ sender: UISlider) {
       
        //let originalPicture : UIImage
        //contrastAdj(original: originalPicture!)
        sharpnessAdj(original: originalPicture!)
    }
    
    @IBOutlet weak var ctrlSlide: UISlider!
    @IBOutlet weak var textLab: UILabel!
    @IBAction func cropButton(_ sender: UIButton) {
       presentCropViewController()
    }
    
    
    @IBAction func optimizeQuality(_ sender: UIButton) {
       BrightnessAdj()
        
        
    }
    @IBAction func chooseImg(_ sender: UIButton) {
        chooseImage()
       
    }
    @IBAction func startAlz(_ sender: UIButton) {
        if  let tesseract = G8Tesseract(language:"eng")
        {
            tesseract.delegate = self
            tesseract.image = testImg.image?.g8_blackAndWhite()
            tesseract.recognize()
            textLab.text = tesseract.recognizedText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ctrlSlide.minimumValue = -4.0
        ctrlSlide.value = 0.0
        ctrlSlide.maximumValue = 4.0
    }
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Recognition Progress\(tesseract.progress) %")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        originalPicture = info[UIImagePickerControllerOriginalImage] as? UIImage
        //let selectImg = info[UIImagePickerControllerOriginalImage] as? UIImage
       self.testImg.image = originalPicture
       
        picker.dismiss(animated: true, completion: nil)
        
        
        
    }
    //裁切
    func presentCropViewController() {
        
        
        let cropViewController = CropViewController(image: self.testImg.image!)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.testImg.image = image
        dismiss(animated: true, completion: nil)
    }
    func chooseImage()
    {
        let photoPicker: UIImagePickerController = UIImagePickerController()
        //設定資料來源的型別為「相簿」
        photoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        photoPicker.delegate = self
        //開啟相簿
        self.present(photoPicker,animated: true,completion: nil)    }
      // 設置圖片的亮度
    func BrightnessAdj()
    {
      
        // 创建一个BrightnessAdjustment颜色处理滤镜
        let brightnessAdjustment = BrightnessAdjustment()
        brightnessAdjustment.brightness = 0.2

        // 创建一个ExposureAdjustment颜色处理滤镜
        let exposureAdjustment = ExposureAdjustment()
        exposureAdjustment.exposure = 0.5


        // 1.使用GPUImage对UIImage的扩展方法进行滤镜处理
        var filteredImage: UIImage

        // 1.1单一滤镜
        filteredImage = testImg.image!.filterWithOperation(brightnessAdjustment)



        // 不建议的
        testImg.image = filteredImage
    }
    //調整對比
    func contrastAdj(original oripic : UIImage)
    {

        let controllContrast = ContrastAdjustment()
        
        controllContrast.contrast = ctrlSlide.value
        var newpic : UIImage
        
        //拿原圖作濾鏡處理
        newpic = oripic.filterWithOperation(controllContrast)
        testImg.image = newpic
        print("contrast:",controllContrast.contrast)
        
    }
    //調整銳利度
    func sharpnessAdj(original oripic : UIImage)
    {
        let controllSharpen = Sharpen()
        
        controllSharpen.sharpness = ctrlSlide.value
        var newpic : UIImage
        
        //拿原圖作濾鏡處理
        newpic = oripic.filterWithOperation(controllSharpen)
        testImg.image = newpic
        print("sharpen:",controllSharpen.sharpness)
       
       
        
       
        
    }
   
}

//新增協定UIImagePickerControllerDelegate/UINavigationControllerDelegate
//選擇Img方法如下
//let photoPicker: UIImagePickerController = UIImagePickerController()
////設定資料來源的型別為「相簿」
//photoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//photoPicker.delegate = self
////開啟相簿
//self.present(photoPicker,animated: true,completion: nil)
//新增自動調用方法
//func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
//{
//    let selectImg = info[UIImagePickerControllerOriginalImage] as? UIImage
//    self.imageView.image = selectImg
//    picker.dismiss(animated: true, completion: nil)
//
//}
