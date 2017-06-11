//
//  ViewController.swift
//  FiveYears
//
//  Created by Jan B on 21.04.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit
import ImageSlideshow
import FirebaseAuth
import FirebaseDatabase
import PopupDialog


class MemoryViewController: UIViewController, UITextViewDelegate {
    
    /// The images that will be loaded into the imageSlideShow as an ImageSource.
    var images: [ImageSource]? {
        didSet {
            if let imgs = images {
                imageSlideShow.setImageInputs(imgs)
            }
        }
    }
    
    var userSettings: UserSettings {
        let settings = UserDefaults.standard.getUserSettings()
        return settings
    }
    
    @IBOutlet weak var reloadButton: UIBarButtonItem! {
        didSet {
            // Do setup of the button
            let icon = #imageLiteral(resourceName: "heart_reload-40")
            let iconSize = CGRect(origin: .zero, size: icon.size)
            let iconButton = UIButton(frame: iconSize)
            iconButton.setBackgroundImage(icon, for: .normal)
            reloadButton.customView = iconButton
            
            iconButton.addTarget(self, action: #selector(reloadContent(_:)), for: .touchUpInside)
        }
    }
    
    /// The text displayed in the textView.
    var text: String? {
        didSet {
            if let memoryText = text {
                textView.text = memoryText
            }
        }
    }
    
    /// Key to the database (as time stamp from 1970 on).
    /// In case it is nil the latest memory is loaded by default.
    var currentMemory: String? = nil {
        didSet {
            reloadContent(forTimestamp: currentMemory)
        }
    }
    
    /// Will cause to reload the content. See reloadContent(forTimestamp: ...) for more info.
    ///
    /// - Parameter sender: Button calling the function.
    func reloadContent(_ sender: UIBarButtonItem) {
        reloadContent(forTimestamp: currentMemory)
    }
    
    
    /// imageSlideShow shows the images assigned in the images variable.
    var imageSlideShow: ImageSlideshow = {
        let imageSlide = ImageSlideshow()
        imageSlide.backgroundColor = IMAGE_BACKGROUND_COLOR
        return imageSlide
    }()
    
    /// textView shows the text assigned in the text variable.
    lazy var textView: UITextView = {
        let txtvw = UITextView()
        txtvw.backgroundColor = BACKGROUND_COLOR
        txtvw.textColor = TEXT_COLOR
        txtvw.font = TEXT_FONT
        txtvw.textAlignment = .justified
        txtvw.textContainerInset = TEXTVIEW_CONTAINER_INSETS
        txtvw.isEditable = false
        txtvw.delegate = self
        return txtvw
    }()
    
    var rainRoses = true {
        didSet {
            if rainRoses {
                rosePlateRain()
            } else {
                if rainTimer != nil {
                    rainTimer!.invalidate()
                    rainTimer = nil
                }
            }
        }
    }
    
    var rainTimer: Timer? = nil
    
    private var loading = false {
        didSet {
            // check if bool value has changed
            if loading != oldValue {
                if loading {
                    // If loading start the reload animation
                    animateReloadButton()
                } else {
                    // stop animation if not loading anymore
                    reloadButton.customView?.layer.removeAllAnimations()
                }
            }
        }
    }
    
    
    /// The parent view of the textView and the imageSlideShow.
    @IBOutlet weak var contentView: UIView!
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        // Nothing happening here. See MemoryTableViewController's prepareforsegue.
    }
    
    /// The segment control enables to switch between Images and Text indexes: images - 0; text - 1
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view.backgroundColor = BACKGROUND_COLOR
        contentView.backgroundColor = BACKGROUND_COLOR
        
        // add the five logo to the navigationbar
        let titleImage = UIImageView(image: #imageLiteral(resourceName: "five_logo-40"))
        titleImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = titleImage
        
        // setup the contentView
        setupContentView()
        
        // insert default content until fully loaded
        insertDefaultContent()
        
        // try to authenticate the firebase account
        authenticateFirebase()
        
        // if auto reload is enabled reload content
        if let auto = userSettings.autoreloadEnabled {
            if auto {
                reloadContent()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newNotification()
        
        applyUserSettings()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPosition = scrollView.contentOffset
        
        // scroll over image
        if textView.frame.minY - scrollPosition.y >= contentView.bounds.minY && textView.frame.minY - scrollPosition.y <= imageSlideShow.frame.maxY {
            textView.frame = CGRect(x: textView.frame.minX, y: max(textView.frame.minY - scrollPosition.y, contentView.bounds.minY), width: textView.bounds.width, height: textView.bounds.height)
            imageSlideShow.alpha = textView.frame.minY / imageSlideShow.bounds.height
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        
    }
    
    /// Causes the imageSlideShow take over the entire screen.
    func imgFullscreen() {
        imageSlideShow.presentFullScreenController(from: self)
    }
    
    /// inserts a default picture and text
    private func insertDefaultContent() {
        let image = #imageLiteral(resourceName: "default-image")
        
        images = [ImageSource(image: image)]
        
        text = longTestText
    }
    
    func rosePlateRain() {
        let image = UIImageView(image: randomRosePlate())
        
        let path = randomPath(rect: view.bounds)
        image.frame = CGRect(origin: path.currentPoint, size: CGSize(width: 30.0, height: 30.0))
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        
        animation.path = path.cgPath
        animation.duration = 1.5 + drand48()
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        image.layer.add(animation, forKey: nil)
        
        view.addSubview(image)
        
        let timeTillNextDrop = drand48() * 3
        
        rainTimer = Timer.scheduledTimer(timeInterval: timeTillNextDrop, target: self, selector: #selector(rosePlateRain), userInfo: nil, repeats: false)
    }
    
    private func setupContentView() {
        let imageHeight = view.bounds.maxY / 3
        
        imageSlideShow.frame = CGRect(x: contentView.bounds.minX, y: contentView.bounds.minY, width: contentView.bounds.maxX, height: imageHeight)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemoryViewController.imgFullscreen))
        imageSlideShow.addGestureRecognizer(gestureRecognizer)
        textView.frame = CGRect(x: contentView.bounds.minX, y: contentView.bounds.minY + imageHeight, width: contentView.bounds.maxX, height: contentView.bounds.maxY)
        
        contentView.addSubview(imageSlideShow)
        contentView.addSubview(textView)
    }
    
    /// Creates a straight path from the top to the buttom of the given rectangle at a random x location.
    ///
    /// - Parameter rect: The rectangle the path will be created in.
    /// - Returns: Path straight down (90 degree) for a random x value.
    private func randomPath(rect: CGRect) -> UIBezierPath {
        let x = rect.width * CGFloat(drand48())
        let spawn = CGPoint(x: x, y: 0)
        let endpoint = CGPoint(x: x, y: rect.height)
        
        let path = UIBezierPath()
        path.move(to: spawn)
        path.addLine(to: endpoint)
        
        return path
    }
    
    private func randomRosePlate() -> UIImage {
        switch arc4random()%5 {
        case 0: return #imageLiteral(resourceName: "pink1")
        case 1: return #imageLiteral(resourceName: "pink2")
        case 3: return #imageLiteral(resourceName: "red1")
        case 4: return #imageLiteral(resourceName: "red2")
        case 5: return #imageLiteral(resourceName: "red3")
        default: return #imageLiteral(resourceName: "red1")
        }
    }
    
    /// Will load the content for the given timestamp from firebase. If no timestamp is given the latest memory will be loaded.
    ///
    /// - Parameter timestamp: Timestamp of the memory that is to be loaded.
    private func reloadContent(forTimestamp timestamp: String? = nil) {
        // Reload content
        loading = true
        if let key = timestamp {
            // Get the database entry for the given timestamp.
            DataService.ds.REF_MEMORIES.child(key).observe(.value, with: { (snapshot) in
                // Extract data from the database snapshot.
                self.extractData(from: snapshot)
            })
        } else {
            // Get the latest database entry.
            
            // get the current date and remove decimal (firebase won't accept floating point)
            let today = String(Int(Date().timeIntervalSince1970))
            
            DataService.ds.REF_MEMORIES.queryEnding(atValue: nil, childKey: today).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
                // The first child is the latest database entry.
                let childSnap = snapshot.children.allObjects[0] as! FIRDataSnapshot
                self.extractData(from: childSnap)
            })
        }
    }
    
    /// Extracts the data from a given Firebase Snapshot and assigns it to the text and images property.
    /// This will also load the images from the web. Make sure to call this function only if it's necessary.
    ///
    /// - Parameter snapshot: The snapshot the data is to be extracted from.
    private func extractData(from snapshot: FIRDataSnapshot) {
        
        let text = snapshot.childSnapshot(forPath: DataBaseMemoryKeys.text).value as? String ?? "No text available."
        self.text = text
        let images = snapshot.childSnapshot(forPath: DataBaseMemoryKeys.images).children
        
        var imgSources = [ImageSource]()
        
        let imageDownloadDispatchGroup = DispatchGroup()
        
        for image in images {
            if let imgURL = (image as? FIRDataSnapshot)?.value as? String {
                let imgREF = storage.reference(forURL: imgURL)
                loading = true
                imageDownloadDispatchGroup.enter()
                imgREF.data(withMaxSize: 10 * 1024 * 1024, completion: { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let img = UIImage(data: data!) {
                            imgSources.append(ImageSource(image: img))
                        }
                    }
                    imageDownloadDispatchGroup.leave()
                })
            }
        }
        
        imageDownloadDispatchGroup.notify(queue: DispatchQueue.main, execute: {
            self.images = imgSources
            self.loading = false
        })
    }
    
    /// Signes the account given in the credentials into Firebase if possible.
    /// Shows an alert with the error message if the login fails.
    private func authenticateFirebase() {
        if let mail = userSettings.loginEmail, let psswd = userSettings.loginPassword {
            FIRAuth.auth()?.signIn(withEmail: mail, password: psswd) { (user, error) in
                if error != nil {
                    print(error.debugDescription)
                    let message = error?.localizedDescription
                    let alert = UIAlertController(title: "Database Login Error", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (alert: UIAlertAction) in
                        self.authenticateFirebase()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Login Information Missing", message: "Your credentials could not be found. Enter your mail and password in settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Maybe ad showing settingsVC here
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    private func animateReloadButton() {
        if loading {
            self.reloadButton.customView!.tintColor = RELOAD_BUTTON_ANIMATION_COLOR
            let originalFrame = reloadButton.customView!.frame
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .curveEaseIn, .repeat], animations: {
                self.reloadButton.customView!.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.reloadButton.customView!.alpha = 0.7
                
            }, completion: { (completed) in
                self.reloadButton.customView!.tintColor = UIColor.white
                self.reloadButton.customView!.alpha = 1.0
                self.reloadButton.customView!.frame = originalFrame
            })
        }
    }
    
    private func newNotification() {
        // Only fetch database entries that are available today (not entries for future usage)
        let today = String(Int(Date().timeIntervalSince1970))
        
        DataService.ds.REF_NOTIFICATIONS.queryEnding(atValue: nil, childKey: today).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            // The first child is the latest database entry.
            let childSnap = snapshot.children.allObjects[0] as! FIRDataSnapshot
            if childSnap.hasChild(DataBaseNotificationKeys.dismissed) {
                if let dismissed = childSnap.childSnapshot(forPath: DataBaseNotificationKeys.dismissed).value as? Bool {
                    if !dismissed {
                        
                        let notificationDispatchGroup = DispatchGroup()
                        var image: UIImage? = nil
                        var message: String? = nil
                        
                        if childSnap.hasChild(DataBaseNotificationKeys.image) {
                            if let imgURL = childSnap.childSnapshot(forPath: DataBaseNotificationKeys.image).value as? String {
                                let imgREF = storage.reference(forURL: imgURL)
                                
                                notificationDispatchGroup.enter()
                                imgREF.data(withMaxSize: 10 * 1024 * 1024, completion: { data, error in
                                    if error == nil {
                                        if let img = UIImage(data: data!) {
                                            image = img
                                        }
                                    }
                                    notificationDispatchGroup.leave()
                                })
                            }
                        }
                        if let mssg = childSnap.childSnapshot(forPath: DataBaseNotificationKeys.message).value as? String {
                            notificationDispatchGroup.enter()
                            message = mssg
                            notificationDispatchGroup.leave()
                        }
                        notificationDispatchGroup.notify(queue: DispatchQueue.main, execute: {
                            // Create a PopupDialog from the snapshot data
                            let popover = PopupDialog(title: nil, message: message, image: image)
                            let button = PopupDialogButton(title: "Weiter", action: nil)
                            popover.addButton(button)
                            
                            // After displaying the notification is marked dismissed in the database
                            self.present(popover, animated: true, completion: {
                                DataService.ds.setNotificationAsSeen(timestamp: childSnap.key)
                            })
                        })
                        
                    }
                }
            }
        })
    }
    
    private func applyUserSettings() {
        if let rain = userSettings.rainEnabled {
            rainRoses = rain
        }
        if let size = userSettings.fontSize {
            textView.font = UIFont(name: TEXT_FONT_NAME, size: CGFloat(size))
        }
    }
    
}

