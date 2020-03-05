//
//  DidFinishPickingImageDelegate.h
//  CamScan
//
//  Created by Amit Kulkarni on 19/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#ifndef DidFinishPickingImageDelegate_h
#define DidFinishPickingImageDelegate_h

@class Document, File;
@protocol  DidFinishPickingImageDelegate <NSObject>
- (void)didDinishFlow:(File *)file;
@end

#endif /* DidFinishPickingImageDelegate_h */
