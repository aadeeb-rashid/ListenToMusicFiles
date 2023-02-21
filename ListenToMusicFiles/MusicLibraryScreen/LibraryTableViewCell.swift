//
//  LibraryTableViewCell.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 2/1/23.
//

import UIKit

protocol SongButtonDelegate : UIViewController
{
    func tappedCellAtPosition(position : Int)
}

class LibraryTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    
    private var delegate : SongButtonDelegate? = nil
    private var localFile : LocalFile? = nil
    private var position : Int = 0
    static let identifier = "myCustomLibraryCell"
    
    static func nib() -> UINib
    {
        return UINib(nibName: "LibraryTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        titleLabel.text = self.localFile?.fileName
    }
    
    func initLibraryCell(newFile: LocalFile, position : Int)
    {
        self.localFile = newFile
        self.titleLabel.text = newFile.fileName;
        self.position = position
        self.selectionStyle = .none
    }
    
    func setDelegate(viewController : SongButtonDelegate)
    {
        delegate = viewController
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func getTitle() -> String
    {
        return titleLabel.text ?? "";
    }
    
    @IBAction func didPressPlayButton(_ sender: UIButton)
    {
        self.delegate?.tappedCellAtPosition(position: self.position)
    }
    @IBAction func didPressDeleteButton(_ sender: UIButton)
    {
        AppDelegate.sharedManagers()?.errorManager.prepareFileDeletePrompt(fileToBeDeleted: titleLabel.text ?? "")
    }
}
