//
//	ReaderDocument.h
//	Reader v2.5.3
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

//----------------------------
//  2011/11/24
//  Yu Jen Wang
//  增加標題欄位
//----------------------------



#import <Foundation/Foundation.h>

@interface ReaderDocument : NSObject <NSCoding>
{
@private // Instance variables

	NSString *_guid;

	NSDate *_fileDate;

	NSDate *_lastOpen;

	NSNumber *_fileSize;

	NSNumber *_pageCount;

	NSNumber *_pageNumber;

	NSMutableIndexSet *_bookmarks;

	NSString *_fileName;

	NSString *_password;

	NSURL *_fileURL;
    
  	NSString *_title;
    
    NSString *_bookid;
}

@property (nonatomic, retain, readonly) NSString *guid;
@property (nonatomic, retain, readonly) NSDate *fileDate;
@property (nonatomic, retain, readwrite) NSDate *lastOpen;
@property (nonatomic, retain, readonly) NSNumber *fileSize;
@property (nonatomic, retain, readonly) NSNumber *pageCount;
@property (nonatomic, retain, readwrite) NSNumber *pageNumber;
@property (nonatomic, retain, readonly) NSMutableIndexSet *bookmarks;
@property (nonatomic, retain, readonly) NSString *fileName;
@property (nonatomic, retain, readonly) NSString *password;
@property (nonatomic, retain, readonly) NSURL *fileURL;
@property (nonatomic, retain, readwrite) NSString *title;
@property (nonatomic, retain, readwrite) NSString *bookid;

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filename password:(NSString *)phrase;

- (id)initWithFilePath:(NSString *)fullFilePath password:(NSString *)phrase;

- (void)saveReaderDocument;

- (void)updateProperties;

@end
