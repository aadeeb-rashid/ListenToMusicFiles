//
//  ErrorManager.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 10/19/22.
//

import Foundation
import UIKit
protocol PresentAlertDelegate: UIViewController
{
    
}

extension UIViewController: PresentAlertDelegate
{
    
}

class ErrorManager: Manager
{
    
    private var delegate: PresentAlertDelegate?
    
    func setDelegate(viewController: PresentAlertDelegate)
    {
        delegate = viewController
    }
    
    func handleError(error: Error)
    {
        DispatchQueue.main.async
        {
            let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            }))
            self.delegate!.present(alertController, animated: true)
        }
    }
    
    func prepareFileRewritePromptWithURLs(fileUrl: URL, destinationUrl: URL)
    {
        let options = getOptionsForRewritePromptWithUrls(fileUrl: fileUrl, destinationUrl: destinationUrl)
        displayReWritePromptWithOptions(options: options)
    }
    
    private func getOptionsForRewritePromptWithUrls(fileUrl: URL, destinationUrl: URL) -> [UIAlertAction]
    {
        var actions: [UIAlertAction] = []
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let rewriteAction = UIAlertAction(title: "Overwrite File", style: .default, handler: AppDelegate.sharedManagers()?.deviceDataManager.getFunctionForRewriteFile(fileUrl: fileUrl, destinationUrl: destinationUrl))
        
        actions.append(cancelAction)
        actions.append(rewriteAction)
        return actions
    }
    
    private func displayReWritePromptWithOptions(options: [UIAlertAction])
    {
        DispatchQueue.main.async
        {
            let alertController = UIAlertController(title: nil, message: MusicLoadingError.fileAlreadyExists.localizedDescription, preferredStyle: .alert)
            for option in options
            {
                alertController.addAction(option)
            }
            self.delegate!.present(alertController, animated: true)
        }
    }
    
    func prepareFileDeletePrompt(fileToBeDeleted: String)
    {
        let options = getOptionsForDeletePrompt(fileName: fileToBeDeleted)
        displayDeletePromptWithOptions(options: options)
    }
    
    private func getOptionsForDeletePrompt(fileName : String) -> [UIAlertAction]
    {
        var actions: [UIAlertAction] = []
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete File", style: .default)
        {_ in
            AppDelegate.sharedManagers()?.deviceDataManager.deleteFileWithName(name: fileName)
        }
        
        actions.append(cancelAction)
        actions.append(deleteAction)
        return actions
    }
    
    private func displayDeletePromptWithOptions(options: [UIAlertAction])
    {
        DispatchQueue.main.async
        {
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete this song?", preferredStyle: .alert)
            for option in options
            {
                alertController.addAction(option)
            }
            self.delegate!.present(alertController, animated: true)
        }
    }
}
