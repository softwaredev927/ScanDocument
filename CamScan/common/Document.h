//
//  Document.h
//  CamScan
//
//  Created by Amit Kulkarni on 22/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface File : RLMObject
@property NSString *originalFile;
@property NSString *modifiedFile;
@property NSString *thumbnailFile;
@property NSDate *createdDateTime;

@property (readonly) NSString *thumbnailPath;
@property (readonly) NSString *originalPath;
@property (readonly) NSString *modifiedPath;

@end

RLM_ARRAY_TYPE(File)
RLM_ARRAY_TYPE(Document)
@interface Document : RLMObject
@property BOOL isFolder;
@property NSString *documentName;
@property NSDate *createdDateTime;
@property RLMArray<File *><File> *documents;
@property RLMArray<Document *><Document> *documentArray;

@end

