//
//  BookShelfDAO.h
//  CathayBookShelf
//
//  Created by dev1 on 2011/10/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CathayMeetingViewController.h"

@class FMDatabase;
@interface BookShelfDAO : NSObject {

}

/**
 Returns an instance to the shared singleton which governs access to the
 BookShelfDAO.
 @returns The shared BookShelfDAO object
 */
+ (BookShelfDAO *)sharedDAO;


//other
-(NSString *) getUserID;
-(void) closeDatabase;

//Transaction
-(void) beginTransaction;
-(void) commitTransaction;
-(void) rollbackTransaction;

//Query
-(int) getCountsOfCompanyByPK:(NSString *)cpyCode;
-(int) getCountsOfCategoryByPK:(NSString *)categoryID;
-(int) getCountsOfCategoryByUpperCategoryID:(NSString *)categoryID;
-(int) getCountsOfCategoryByCompanyCode:(NSString *)cpyCode;
-(int) getCountsOfBooksByPK:(NSString *)bookID;
-(int) getCountsOfBooksByCategoryID:(NSString *)categoryID;
-(int) getCountsOfBooksByuserID:(NSString *)userID;
-(NSMutableDictionary *) queryBooksDicByCategoryId:(NSString *)categoryID;
-(NSMutableArray *)      queryBooksArrayByCategoryId:(NSString *)categoryID;
-(NSMutableArray *)      queryBooksArrayByKeyword:(NSString *)keyword;
-(NSMutableDictionary *) queryBookDicByBookId:(NSString *)bookID;
-(NSMutableDictionary *) queryAllCompanies;
-(NSMutableArray *)      queryAllBookIDs;
-(NSMutableDictionary *) queryCategoriesOfLevelOneByCpyCode:(NSString *)cpyCode ;
-(NSMutableDictionary *) queryCategoriesOfLevelTwoByCpyCode:(NSString *)cpyCode upperCategoryID:(NSString *)categoryID;
-(NSMutableDictionary *) queryCategoryByCategoryID:(NSString *)categoryID;


//Insert
-(BOOL) insertBookWithDic:(NSDictionary *)dataDic;
-(BOOL) insertCompanyWithDic:(NSDictionary *)dataDic;
-(BOOL) insertCategoryWithDic:(NSDictionary *)dataDic;

//Update
-(BOOL) updateBookWithDic:(NSDictionary *)dataDic;
-(BOOL) updateBookByBookID:(NSString *) bookID WithTitle:(NSString *) title
Order:(NSNumber *)order Status:(RemoteStatus) status ForceDelete:(NSString *) deletable Sharable:(NSString *) sharable;
-(BOOL) updateCompanyWithDic:(NSDictionary *)dataDic;
-(BOOL) updateCategoryWithDic:(NSDictionary *)dataDic;
-(BOOL) updateBookStatus:(RemoteStatus) status ByCategoryID:(NSString *) categoryID;
-(BOOL) updateBookStatus:(RemoteStatus) status withBookIDs:(NSMutableSet *) bookIDs;
-(BOOL) updateBookStatus:(RemoteStatus) status ByBookID:(NSString *)bookID;

//Delete
-(BOOL) deleteBookWithBookID:(NSString *) bookID;
-(BOOL) deleteCategoryWithCategoryID:(NSString *) categoryID;
-(BOOL) deleteCompanyWithCompanyCode:(NSString *) cpyCode;

@end
