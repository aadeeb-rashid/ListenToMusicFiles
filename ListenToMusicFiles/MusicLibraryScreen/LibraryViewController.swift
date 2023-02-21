//
//  LibraryViewController.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 10/20/22.
//

import UIKit
import UniformTypeIdentifiers


class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, NeedsDeviceFileInfoDelegate, AddSongButtonDelegate, SongButtonDelegate
{
    
    @IBOutlet weak var libraryTable: UITableView!
    
    override func viewDidLoad()
    {
        AppDelegate.sharedManagers()?.errorManager.setDelegate(viewController: self)
        AppDelegate.sharedManagers()?.deviceDataManager.setDeviceInfoDelegate(viewController: self)
        self.initializeTable()
        super.viewDidLoad()
    }
    
    private func initializeTable()
    {
        libraryTable.register(LibraryTableViewCell.nib(), forCellReuseIdentifier: LibraryTableViewCell.identifier)
        libraryTable.register(LibraryAddTableViewCell.nib(), forCellReuseIdentifier: LibraryAddTableViewCell.identifier)
        libraryTable.backgroundColor = UIColor.clear
        libraryTable.refreshControl = UIRefreshControl()
        libraryTable.refreshControl?.tintColor = UIColor.black
        libraryTable.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh(refreshControl: UIRefreshControl)
    {
        self.dataUpdated()
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        libraryTable.reloadData()
    }
    
    func dataUpdated()
    {
        libraryTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (AppDelegate.sharedManagers()?.userManager.getLibrary().count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(indexPath.row == 0)
        {
            return getLibraryAddCellForIndexPath(indexPath: indexPath)
        }
        return getLibraryTableViewCellForIndexPath(indexPath: indexPath)
    }
    
    private func getLibraryAddCellForIndexPath(indexPath: IndexPath) -> LibraryAddTableViewCell
    {
        let cell = libraryTable.dequeueReusableCell(withIdentifier: LibraryAddTableViewCell.identifier, for: indexPath) as! LibraryAddTableViewCell
        cell.setDelegate(viewController: self)
        return cell
    }
    
    private func getLibraryTableViewCellForIndexPath(indexPath: IndexPath) -> LibraryTableViewCell
    {
        let cell = libraryTable.dequeueReusableCell(withIdentifier: LibraryTableViewCell.identifier, for: indexPath) as! LibraryTableViewCell
        cell.initLibraryCell(newFile: AppDelegate.sharedManagers()?.userManager.getLibrary()[indexPath.row - 1] ?? LocalFile(), position: indexPath.row - 1)
        cell.setDelegate(viewController: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        libraryTable.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0)
        {
            self.addSongTapped()
            return
        }
        self.tappedCellAtPosition(position: indexPath.row - 1)
    }
    
    func tappedCellAtPosition(position : Int)
    {
        self.performSegue(withIdentifier: "libraryToPlayerSegue", sender: self)
        AppDelegate.sharedManagers()?.audioManager.playAudioFromPosition(position: position)
    }
    
    func addSongTapped()
    {
        let documentPicker = self.getFileChooseView()
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    private func getFileChooseView() -> UIDocumentPickerViewController
    {
        let supportedTypes: [UTType] = [UTType.audio]
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        return documentPicker
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        guard let url = urls.first else
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: MusicLoadingError.shouldNotBeSeen)
            return
        }
        AppDelegate.sharedManagers()?.deviceDataManager.addAudioFileFromURL(audioUrl: url)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90
    }
    
    @IBAction func unwindToLibrary(_ segue: UIStoryboardSegue)
    {
        AppDelegate.sharedManagers()?.audioManager.clearShuffleQueue()
    }

}
