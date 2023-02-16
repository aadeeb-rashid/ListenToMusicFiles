//
//  UserManager.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 10/19/22.
//

import Foundation
import CoreData
import AVFoundation
import UIKit

class UserManager: Manager
{
    private var library : [LocalFile] = [];
    
    func getLibrary() -> [LocalFile]
    {
        return library;
    }
    
    func storeFileFromUrl(url: URL, completionHandler: () -> Void)
    {
        let name = url.lastPathComponent
        let context : NSManagedObjectContext = self.getContext()
        let entity = NSEntityDescription.entity(forEntityName: "LocalFile", in: context)
        let newLocalFile = LocalFile(entity: entity!, insertInto: context)
        newLocalFile.fileName = name;
        do
        {
            library.append(newLocalFile)
            try context.save()
            completionHandler()
        }
        catch
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: MusicLoadingError.noContext)
        }
    }
    
    func loadLibraryFromContext()
    {
        let context : NSManagedObjectContext = self.getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalFile")
        do
        {
            let files:NSArray = try context.fetch(request) as NSArray
            self.loadLibraryFromFiles(files: files)
        }
        catch
        {
            AppDelegate.sharedManagers()?.errorManager.handleError(error: MusicLoadingError.userLibraryLoadFailed)
        }
    }
    
    private func getContext() -> NSManagedObjectContext
    {
        return AppDelegate.sharedAppDelegate().persistentContainer.viewContext
    }
    
    private func loadLibraryFromFiles(files: NSArray)
    {
        for file in files
        {
            let fileToBeAdded = file as! LocalFile
            library.append(fileToBeAdded)
        }
    }
    
    func deleteFileFromLibrary(fileToBeDeletedName: String)
    {
        let context : NSManagedObjectContext = self.getContext()
        for file in library
        {
            if(file.fileName == fileToBeDeletedName)
            {
                context.delete(file as NSManagedObject)
                do { try context.save()} catch _ {}
            }
        }
        self.reloadLibrary()
    }
    
    private func reloadLibrary()
    {
        library = []
        self.loadLibraryFromContext()
    }
    
    //Debug Purposes Only
    /*private func deleteAllContext()
    {
        let context : NSManagedObjectContext = self.getContext()
        for file in library
        {
                context.delete(file as NSManagedObject)
                do { try context.save()} catch _ {}
        }
        self.reloadLibrary()
    }*/
}
