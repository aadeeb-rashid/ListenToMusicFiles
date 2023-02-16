//
//  LibraryTableViewCell.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 2/1/23.
//

import UIKit

class LibraryTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    
    private var localFile : LocalFile? = nil
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
    
    func configureLibraryCellFromFile(newFile: LocalFile)
    {
        self.localFile = newFile
        self.titleLabel.text = newFile.fileName;
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    
    func getTitle() -> String
    {
        return titleLabel.text ?? "";
    }
    
    @IBAction func didPressDeleteButton(_ sender: UIButton)
    {
        
        AppDelegate.sharedManagers()?.errorManager.prepareFileDeletePrompt(fileToBeDeleted: titleLabel.text ?? "")
    }
}
