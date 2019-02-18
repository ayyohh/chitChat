
import UIKit
import Firebase


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messageArray : [Message] = [Message]();
  
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set self as the delegate and datasource
        messageTableView.delegate = self;
        messageTableView.dataSource = self;
        
        
        //Set self as the delegate of the text field
        messageTextfield.delegate = self;
        
        
        //Set the tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped));
        messageTableView.addGestureRecognizer(tapGesture);
        

        //Register MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell");
        
        configureTableView();
        retrieveMessages();
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    //Declare cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell;
        
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody;
        cell.senderUsername.text = messageArray[indexPath.row].sender;
        
        
        return cell;
    
        
    }
    
    //Declare numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count;
        
    }
    
    //Declare tableViewTapped
    @objc func tableViewTapped() {
        
        messageTextfield.endEditing(true);
        
    }
    
    //Declare configureTableView
    func configureTableView() {
        
        messageTableView.rowHeight = UITableView.automaticDimension;
        messageTableView.estimatedRowHeight = 120.0;
        
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    //Declare textFieldDidBeginEditing
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.heightConstraint.constant = 358;
            self.view.layoutIfNeeded();
            
        })
        
    }
    
    //Declare textFieldDidEndEditing
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.heightConstraint.constant = 50;
            self.view.layoutIfNeeded();
            
        })
    }

    
    ///////////////////////////////////////////
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true);
        
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false;
        sendButton.isEnabled = false;
        
        let messagesDB = Database.database().reference().child("Messages");
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if (error != nil) {
                print(error!);
            } else {
                print("Message saved successfully");
                
                self.messageTextfield.isEnabled = true;
                self.sendButton.isEnabled = true;
                self.messageTextfield.text = "";
            }
        }
    }
    
    //retrieveMessages method
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages");
        
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message();
            message.messageBody = text;
            message.sender = sender;
            
            self.messageArray.append(message);
            self.configureTableView();
            self.messageTableView.reloadData();
            
        }
        
    }

    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut();
            navigationController?.popToRootViewController(animated: true);
            
        } catch {
            print("There was a problem logging out...");
        }
        
    }
    

}
