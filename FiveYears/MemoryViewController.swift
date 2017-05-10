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


class MemoryViewController: UIViewController {
    
    /// The images that will be loaded into the imageSlideShow as an ImageSource.
    var images: [ImageSource]? {
        didSet {
            if let imgs = images {
                imageSlideShow.setImageInputs(imgs)
                
                // loveRain(pieces: 20)
            }
        }
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
    var imageSlideShow = ImageSlideshow()
    
    /// textView shows the text assigned in the text variable.
    var textView: UITextView = {
        let txtvw = UITextView()
        txtvw.backgroundColor = BACKGROUND_COLOR
        txtvw.textColor = TEXT_COLOR
        txtvw.font = TEXT_FONT
        txtvw.textAlignment = .justified
        txtvw.textContainerInset = TEXTVIEW_CONTAINER_INSETS
        txtvw.isEditable = false
        return txtvw
    }()
    
    var rainRoses = false {
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
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        // Show Images selected
        case 0:
            // Remove all subviews first
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            // Set frame for imageSlideShow to size of contentView
            imageSlideShow.frame = contentView.bounds
            // Add a GestureRecognizer to support tapping on the image and showing it fullscreen
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemoryViewController.imgFullscreen))
            imageSlideShow.addGestureRecognizer(gestureRecognizer)
            // Add the slideshow to the contentView
            contentView.addSubview(imageSlideShow)
            
        // Show Text selected
        case 1:
            // Remove all subviews first then add textView to contentView with right size
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            textView.frame = contentView.bounds
            contentView.addSubview(textView)
        default:
            break
        }
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        // Nothing happening here. See MemoryTableViewController's prepareforsegue.
    }
    
    /// The segment control enables to switch between Images and Text indexes: images - 0; text - 1
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BACKGROUND_COLOR
        contentView.backgroundColor = BACKGROUND_COLOR
        
        
        // TODO: REMOVE LATER
        insertTestContent()
        
        authenticateFirebase()
        
        newNotification()
        
        rainRoses = true
        
        segmentChanged(segmentCtrl)
    }
    
    /// Causes the imageSlideShow take over the entire screen.
    func imgFullscreen() {
        imageSlideShow.presentFullScreenController(from: self)
    }
    
    // TODO: REMOVE LATER
    func insertTestContent() {
        let image = #imageLiteral(resourceName: "Eva_Test")
        
        images = [ImageSource(image: image), ImageSource(image: image), ImageSource(image: image)]
        
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
        
        let text = snapshot.childSnapshot(forPath: DataBaseKeys.text).value as? String ?? "No text available."
        self.text = text
        let images = snapshot.childSnapshot(forPath: DataBaseKeys.images).children
        
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
        FIRAuth.auth()?.signIn(withEmail: credentials.email, password: credentials.password) { (user, error) in
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
    }
    
    private func animateReloadButton() {
        if loading {
            self.reloadButton.customView!.tintColor = RELOAD_BUTTON_ANIMATION_COLOR
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .curveEaseIn, .repeat], animations: {
                self.reloadButton.customView!.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
            }, completion: { (completed) in
                self.reloadButton.customView!.tintColor = UIColor.white
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
}

