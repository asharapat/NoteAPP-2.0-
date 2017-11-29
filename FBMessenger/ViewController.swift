//
//  ViewController.swift
//  FBMessenger
//
//  Created by Saulebekov Azamat on 21.09.17.
//  Copyright © 2017 Saulebekov Azamat. All rights reserved. Aza lu4wi
//

import UIKit
import CoreData


class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout,  UIImagePickerControllerDelegate, UINavigationControllerDelegate,TableViewDelegate,TableViewDelegateImage{
    
    var informations = Dictionary<String,Array<NSManagedObject>>()
    var sortedSections = [String]()
    var selectedIndexPath: IndexPath?
    
    
    var messages: [NSManagedObject] = []
    private let cellId = "cellId"
    private let cellid = "cellid"
    private let headerId = "headerId"
    var bottomConstraint: NSLayoutConstraint?
    var imagePicker = UIImagePickerController()
    
    let messageInputContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter note..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    
    func handleSend(){
        if inputTextField.text != ""{
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)!
            let message = NSManagedObject(entity: entity, insertInto: context)
            let date = Date()
            message.setValue(inputTextField.text!, forKey: "text")
            message.setValue(date, forKey: "date")
            do{
                try context.save()
                //messages.append(message)
                let date = message.value(forKey: "date") as? Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: date!)
                if self.informations.index(forKey: dateString) == nil{
                    informations[dateString] = [message]
                }
                else{
                    self.informations[dateString]?.append(message)
                }
                self.sortedSections = Array(informations.keys).sorted(by: <)
                
                inputTextField.text = nil
                collectionView?.reloadData()
            }
            catch let error as NSError{
                    print("couldn't save \(error)")
            }
        }
    }
    
    lazy var attachButton: UIButton = {
        let image = UIImage(named: "attachment") as UIImage?
        let button = UIButton(type: UIButtonType.custom) as UIButton
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleAttach), for: .touchUpInside)
        return button
    }()
    
    func handleAttach(){
        self.attachButton.isUserInteractionEnabled = true
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera :(", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)!
            let message = NSManagedObject(entity: entity, insertInto: context)
            let date = Date()
            let imageData = UIImagePNGRepresentation(image)! as NSData
            message.setValue(imageData, forKey: "image")
            message.setValue(date, forKey: "date")
            do{
                try context.save()
                let date = message.value(forKey: "date") as? Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: date!)
                if self.informations.index(forKey: dateString) == nil{
                    informations[dateString] = [message]
                }
                else{
                    self.informations[dateString]?.append(message)
                }
                self.sortedSections = Array(informations.keys).sorted(by: <)
                collectionView?.reloadData()
                //print(informations[dateString])
            }catch let error as NSError{
                print("couldn't save \(error)")
            }
        }
        else{
            print("tipa error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Messages")
            do {
                messages = try context.fetch(fetchRequest)
                print(messages.count)
                
            }catch let error as NSError{
                print("Couldn't fetch \(error)")
            }
        }
        
        if messages.count > 0{
            for message in messages{
                let date = message.value(forKey: "date") as? Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: date!)
                if self.informations.index(forKey: dateString) == nil{
                    informations[dateString] = [message]
                }
                else{
                    self.informations[dateString]?.append(message)
                }
            }
            self.sortedSections = Array(informations.keys).sorted(by: <)
            print(informations["30.10.2017"])
            //print(sortedSections[sortedSections.count-1])
        }
    }
    
    func clearData(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
            do{
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Messages")
                let message = try context.fetch(fetchRequest)
                for mess in message{
                        context.delete(mess)
                }
                try context.save()
            }catch let err{
                print(err)
            }
        }
    }
    
    func clearDataAt(indexPath: IndexPath){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
            do{
                context.delete((informations[sortedSections[indexPath.section]]?[indexPath.row])!)
                try context.save()
            }catch let err{
                print(err)
            }
        }
    }
    
    
    func handleKeyboardNotification(notification: Notification){
        if let userInfo = notification.userInfo{
            let keyBoardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            //print(keyBoardFrame)
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyBoardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:{
                self.view.layoutIfNeeded()
            }, completion: {(completed) in
                
                //Do something with the senderCell
                if self.informations.count > 0{
                    let length = (self.informations[self.sortedSections[self.sortedSections.count - 1]]?.count)! - 1
                    self.collectionView?.scrollToItem(at: IndexPath(item: length, section: self.sortedSections.count - 1), at: .bottom, animated: true)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        
        let btn1 = UIButton()
        btn1.setTitle("Edit", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        btn1.setTitleColor(titleColor, for: .normal)
        btn1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(showDelete), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: btn1), animated: true);
        
        
        
        super.viewDidLoad()
        navigationItem.title = "Storage"
        // Do any additional setup after loading the view, typically from a nib.
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(ChatLogImageCell.self, forCellWithReuseIdentifier: cellid)
        collectionView?.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        //clearData()
        loadData()
    }
    
    func showDelete(){
        print("hey yo")
//        for i in 0..<sortedSections.count{
//            for j in 0..<informations[sortedSections[i]]!.count{
//                let indexPath = IndexPath(row: j, section: i)
//                if let cell = collectionView?.cellForItem(at: indexPath) as? ChatLogMessageCell{
//                    cell.attachButton.isHidden = false
//                }
//                else{
//                    let cell = collectionView?.cellForItem(at: indexPath) as? ChatLogImageCell
//                    cell?.attachButton.isHidden = false
//                }
//            }
//        }
        //cell.imageViewDelete.isHidden = false
    }
    
    private func setupInputComponents(){
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addSubview(attachButton)
        
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0(30)]-4-[v1][v2(60)]|", views: attachButton, inputTextField,sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|-10-[v0(30)]|", views: attachButton)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.75)]", views: topBorderView)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return informations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (informations[sortedSections[section]]?.count)!
        //return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = informations[sortedSections[indexPath.section]]
        let item = section![indexPath.row]
        let date = item.value(forKey: "date") as? Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
    
        if let messageText = item.value(forKey: "text") as? String{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
            cell.messageTextView.text = messageText
            cell.date.text = dateFormatter.string(from: date!)
            cell.imageViewMark.image = UIImage(named: "checkmark")
            cell.delegate = self
            cell.indexPath = indexPath
            
            //cell.imageViewDelete.image = UIImage(named: "delete")
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            cell.messageTextView.frame = CGRect(x: view.frame.width-estimatedFrame.width-16-16-40, y: 0, width: estimatedFrame.width+16, height: estimatedFrame.height + 20) // view.frame.width-estimatedFrame.width-16-16-40
            cell.textBubleView.frame = CGRect(x: view.frame.width-estimatedFrame.width-16-16-8-70, y: 0, width: estimatedFrame.width+16+8+48+30, height: estimatedFrame.height + 20) // fvw-16-16-8-40 width +30
            cell.date.frame = CGRect(x: view.frame.width-60, y: estimatedFrame.height-10, width: 50, height: 30)
            cell.imageViewMark.frame = CGRect(x:view.frame.width-estimatedFrame.width-16-16-40-30, y: 5, width: 30, height: 30)
            cell.attachButton.frame = CGRect(x:view.frame.width-40,y: 2, width: 15, height: 15)
            //cell.imageViewDelete.frame = CGRect(x:view.frame.width-40,y: 2, width: 15, height: 15)
            //-estimatedFrame.width-16-16-40-30-30-10
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! ChatLogImageCell
        let imageData = item.value(forKey: "image")
        let image = UIImage(data: imageData as! Data)
        cell.imageView.image = image
        cell.delegate = self
        cell.indexPath = indexPath
        cell.date.frame = CGRect(x: view.frame.width-60, y: 130, width: 50, height: 30)
        cell.textBubleView.frame = CGRect(x: view.frame.width-270, y: 0, width: 260, height: 160) // vfw-230 width +40
        cell.imageView.frame = CGRect(x: view.frame.width-220, y: 10, width: 140, height: 140) // x vfw - 220
        cell.date.text = dateFormatter.string(from: date!)
        cell.attachButton.frame = CGRect(x:view.frame.width-40,y: 2, width: 15, height: 15)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        inputTextField.endEditing(true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ChatLogMessageCell else{
                return
        }
        if cell.imageViewMark.isHidden{
            cell.imageViewMark.isHidden = false
        }
        else{
            
            cell.imageViewMark.isHidden = true
        }
        
    }
    
    
    func didTouchButtonAt(_ indexPath: IndexPath) {
        print("Hello world!")
        self.selectedIndexPath = indexPath
        //informations.removeValue(forKey: sortedSections[indexPath.row])
        clearDataAt(indexPath: indexPath)
        informations[sortedSections[indexPath.section]]?.remove(at: indexPath.row)
        collectionView?.reloadData()
        
    }
    
    func didTouchImageButtonAt(_ indexPath: IndexPath) {
        print("image deleted")
        self.selectedIndexPath = indexPath
        clearDataAt(indexPath: indexPath)
        informations[sortedSections[indexPath.section]]?.remove(at: indexPath.row)
        collectionView?.reloadData()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView? = nil
        if kind == UICollectionElementKindSectionHeader{
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderCell
            //headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 35)
            headerView.frame.size.height = 30
//            print("$$$$$$")
//            print(headerView.frame)
            headerView.textLabel.text = sortedSections[indexPath.section]
            headerView.textLabel.frame = CGRect(x: view.frame.width/2-50, y: 0, width: 100, height: 30)
            reusableView = headerView
        }
        
        return reusableView!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = informations[sortedSections[indexPath.section]]
        let item = section![indexPath.row]
        
        if let messageText = item.value(forKey: "text") as? String{
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height+20)
        }
        if (item.value(forKey: "image") as? NSData) != nil{
            return CGSize(width: view.frame.width, height: 160)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(36, 0, 50, 8)   // top left bottom right
    }
    
    
    
    
}

extension UIView{
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index,view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}






