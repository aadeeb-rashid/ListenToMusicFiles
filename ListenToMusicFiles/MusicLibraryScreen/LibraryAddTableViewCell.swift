//
//  LibraryAddTableViewCell.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 2/1/23.
//

import UIKit

protocol AddSongButtonDelegate : UIViewController
{
    func addSongTapped()
}

class LibraryAddTableViewCell: UITableViewCell
{
    @IBOutlet weak var label: UILabel!
    
    var delegate : AddSongButtonDelegate? = nil
    
    static let identifier = "myCustomLibraryAddCell"
    static func nib() -> UINib
    {
        return UINib(nibName: "LibraryAddTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func setDelegate(viewController : AddSongButtonDelegate)
    {
        delegate = viewController
    }

    @IBAction func addSongButtonTapped(_ sender: UIButton)
    {
        delegate?.addSongTapped()
    }
}
