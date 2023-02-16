//
//  DeviceDataManager.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 2/1/23.
//

import Foundation
import UIKit

protocol NeedsDeviceFileInfoDelegate: UIViewController
{
    func dataUpdated()
}

class DeviceDataManager : Manager
{
    private var delegate: NeedsDeviceFileInfoDelegate?
    
    func setDeviceInfoDelegate(viewController : NeedsDeviceFileInfoDelegate)
    {
        delegate = viewController
    }
    
    func deleteFileWithName(name: String)
    {
        do
        {
            let destinationUrl = getDestinationUrlForName(name: name)
            try FileManager.default.removeItem(at: destinationUrl)
            AppDelegate.sharedManagers()?.userManager.deleteFileFromLibrary(fileToBeDeletedName: name)
            delegate?.dataUpdated()
        }
        catch let error as NSError
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
        }
    }
    
    func addAudioFileFromURL(audioUrl: URL)
    {
        let fileName = audioUrl.lastPathComponent
        let destinationUrl = getDestinationUrlForName(name: fileName)
        guard audioUrl.startAccessingSecurityScopedResource() else
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: MusicLoadingError.noPermission)
            return
        }
        if FileManager.default.fileExists(atPath: destinationUrl.path)
        {
            self.promptForRewrite(audioUrl: audioUrl, destinationUrl: destinationUrl)
        }
        else
        {
            self.downloadFile(audioUrl: audioUrl, destinationUrl: destinationUrl)
        }
        audioUrl.stopAccessingSecurityScopedResource()
    }
    
    func getDestinationUrlForName(name: String) -> URL
    {
        let destinationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
        return destinationUrl
    }
    
    private func promptForRewrite(audioUrl: URL, destinationUrl: URL)
    {
        AppDelegate.sharedManagers()?.errorManager.prepareFileRewritePromptWithURLs(fileUrl: audioUrl, destinationUrl: destinationUrl)
    }
    
    func getFunctionForRewriteFile(fileUrl: URL, destinationUrl: URL) -> ((UIAlertAction)->Void)?
    {
        func rewrite(action:UIAlertAction) -> Void
        {
            do
            {
                try FileManager.default.removeItem(at: destinationUrl)
                AppDelegate.sharedManagers()?.userManager.deleteFileFromLibrary(fileToBeDeletedName: destinationUrl.lastPathComponent)
                self.downloadFile(audioUrl: fileUrl, destinationUrl: destinationUrl)
            }
            catch let error as NSError
            {
                AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
            }
        }
        return rewrite
    }
    
    private func downloadFile(audioUrl: URL, destinationUrl: URL)
    {
        guard audioUrl.startAccessingSecurityScopedResource() else
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: MusicLoadingError.noPermission)
            return
        }
        URLSession.shared.downloadTask(with: audioUrl, completionHandler:
        {
            location, _, error in
            self.handleFileDownload(location: location, error: error, destinationUrl: destinationUrl)
            audioUrl.stopAccessingSecurityScopedResource()
        }).resume()
    }
    
    private func handleFileDownload(location: URL?, error: Error?, destinationUrl: URL)
    {
        if let error = error
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
        }
        guard let location = location else { return }
        do
        {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            DispatchQueue.main.async
            {
                AppDelegate.sharedManagers()?.userManager.storeFileFromUrl(url: destinationUrl)
                {
                    self.delegate?.dataUpdated()
                }
            }
            
        }
        catch let error as NSError
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: error)
        }
        
    }
}
