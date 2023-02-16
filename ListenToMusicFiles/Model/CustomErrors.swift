//
//  CustomErrors.swift
//  ListenToMusicFiles
//
//  Created by aadeeb rashid on 10/19/22.
//

import Foundation
enum MusicLoadingError: LocalizedError
{
    case userFileLoadFailed
    case userLibraryLoadFailed
    case fileAlreadyExists
    case noContext
    case failedToSaveData
    case shouldNotBeSeen
    case noPermission
    
    public var errorDescription: String?
    {
            switch self
        {
            case .userFileLoadFailed:
                return NSLocalizedString("Your music is Not Composible", comment: "File Load Failed")
            case .userLibraryLoadFailed:
                return NSLocalizedString("Error Loading Library", comment: "UserManager blocked")
            case .fileAlreadyExists:
                return NSLocalizedString("The file is already in your library!", comment: "File Exists")
            case .noContext:
                return NSLocalizedString("Something went Wrong!", comment: "No Context")
            case .failedToSaveData:
                return NSLocalizedString("Something Went Wrong When Saving Your Data.", comment: "Data Save Failure")
            case .shouldNotBeSeen:
                return NSLocalizedString("This Messsage should not be seen", comment: "")
            case .noPermission:
                return NSLocalizedString("We don't have permissions to write to your phone", comment: "Security Scope Access")
                
        }
            
            
    }
    
}

enum MusicPlayerError: LocalizedError
{
    case playerMalfunctioned
    
    public var errorDescription: String?
    {
            switch self
        {
            case .playerMalfunctioned:
                return NSLocalizedString("The audio player is experiencing difficulties right now", comment: "Check Audio")
                
        }
            
            
    }
    
}

