//
//  BookShelfDAO.m
//  這是一個Singleton 類別
//  CathayBookShelf
//
//  Created by dev1 on 2011/10/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
//  參考此一網站的Singleton撰寫方法
//  http://www.duckrowing.com/2010/05/21/using-the-singleton-pattern-in-objective-c/

#import "BookShelfDAO.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "CathayGlobalVariable.h"
#import "DocumentCell.h"

//-------------------------------------------------------------------------
//define

@interface BookShelfDAO ()
@property (retain) FMDatabase *db;  //atomic執行緒安全的設定
@end


//-------------------------------------------------------------------------
//implement


static BookShelfDAO *sharedInstance = nil;


@implementation BookShelfDAO
@synthesize db;

+ (BookShelfDAO *)sharedDAO
{
	@synchronized (self) {
		if (sharedInstance == nil) {
			[[self alloc] init]; // assignment not done here, see allocWithZone
		}
	}
	
	return sharedInstance;
}

//----------------------------------------
//overwirte 以下方法，確保每次記憶分配都會在同一塊

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//----------------------------------------
//overwirte 以下方法，protect our object from deallocation

- (id)retain
{
    return self;
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  // This is sooo not zero
}


//----------------------------------------

- (id) init
{
    @synchronized(self) {
        
        if (self = [super init])
        {
            
            //NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *docDBPath = [documentsDirectory stringByAppendingPathComponent:@"DOC_LOCAL.sqlite"];
            #ifdef IS_DEBUG
            NSLog(@"open DB Path:%@",docDBPath);
            #endif
            self.db = [FMDatabase databaseWithPath:docDBPath];
            //[db goodConnection]
            if (![db open]) {
                
                #ifdef IS_DEBUG
                NSLog(@"Could not open db.");
                #endif
                
                self.db = nil;
                return nil;
                
            }else {
                
                return self;
            }
            
        }
        return self;		
    
    }
    

}

/*
//Singleton 無需釋放，因為當Application terminate時，自然會被收走 
- (void)dealloc {
    [db release];
	[super dealloc];
}
*/
//-----------------------------

-(void)closeDatabase {
    
    [db close];
}

-(NSString *) getUserID {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return [prefs objectForKey:@"idFiled"];
    
}

#pragma mark - Transaction Method

-(void) beginTransaction {
    
    [db beginTransaction];
}

-(void) commitTransaction {
    
    [db commit];
}


-(void) rollbackTransaction {
    
    [db rollback];
}



#pragma mark - Query Method

-(int) getCountsOfCompanyByPK:(NSString *)cpyCode {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_COMPANY where USER=? and CPY_CODE=?", [self getUserID], cpyCode];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}

-(int) getCountsOfCategoryByPK:(NSString *)categoryID {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_CATEGORY where USER=? and CATEGORY_ID=?", [self getUserID], categoryID];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}


-(int) getCountsOfCategoryByUpperCategoryID:(NSString *)categoryID {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_CATEGORY where USER=? and UPPER_CATEGORY=?", [self getUserID], categoryID];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}

-(int) getCountsOfCategoryByCompanyCode:(NSString *)cpyCode {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_CATEGORY where USER=? and CPY_CODE=?", [self getUserID], cpyCode];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}


-(int) getCountsOfBooksByPK:(NSString *)bookID {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_BOOKS where USER=? and BOOK_ID=?", [self getUserID], bookID];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}

-(int) getCountsOfBooksByCategoryID:(NSString *)categoryID {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_BOOKS where USER=? and CATEGORY_ID=?", [self getUserID], categoryID];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}

-(int) getCountsOfBooksByuserID:(NSString *)userID {
    
    FMResultSet *rs = [db executeQuery:@"select count(1) from DTMT_BOOKS where USER=? ", userID];
    
    [rs next];
    int rowNum = [rs intForColumnIndex:0];
    [rs close];
    
    return rowNum;
}


-(NSMutableDictionary *) queryBookDicByBookId:(NSString *)bookID {

    FMResultSet *rs = [db executeQuery:@"select * from DTMT_BOOKS where USER=? and BOOK_ID=?", [self getUserID], bookID];
    NSMutableDictionary *outDic = nil;
    
    if ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        outDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@, value:%@", columnName, [rs objectForColumnIndex:i]);
            [outDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryBookDicByBookId 查詢完成！");
    #endif
    return outDic;
}


//查詢目前使用者本機端的所有公司別
-(NSMutableDictionary *) queryAllCompanies {
    FMResultSet *rs = [db executeQuery:@"select * from DTMT_COMPANY where USER=?", [self getUserID]];
    NSMutableDictionary *outDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    while ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@", columnName);
            [dataDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
        NSString *pk = [dataDic objectForKey:@"CPY_CODE"];
        #ifdef IS_DEBUG
        NSLog(@"rs -> CPY_CODE:%@", pk);
        #endif
        
        [outDic setValue:dataDic forKey:pk];
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryAllCompanies 查詢完成！ 筆數：%d", [outDic count] );
    #endif
    return outDic;
}

//查詢目前使用者本機端的所有書本編號
-(NSMutableArray *) queryAllBookIDs {
    FMResultSet *rs = [db executeQuery:@"select BOOK_ID from DTMT_BOOKS where USER=?", [self getUserID]];
    NSMutableArray *outArray = [NSMutableArray arrayWithCapacity:10];
    
    while ([rs next]) {
        
        [outArray addObject:[rs objectForColumnIndex:0]];
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryAllBookIDs 查詢完成！ 筆數：%d", [outArray count] );
    #endif
    return outArray;
}



//查詢目前使用者本機端的第一層類別
//@param cpyCode 公司別代碼
//
-(NSMutableDictionary *) queryCategoriesOfLevelOneByCpyCode:(NSString *)cpyCode {
    FMResultSet *rs = [db executeQuery:@"select * from DTMT_CATEGORY where USER=? AND CPY_CODE=? AND (UPPER_CATEGORY == '' or UPPER_CATEGORY IS NULL)", [self getUserID],cpyCode];
    NSMutableDictionary *outDic = [NSMutableDictionary dictionaryWithCapacity:20];
    
    while ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@", columnName);
            [dataDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
        NSString *pk = [dataDic objectForKey:@"CATEGORY_ID"];
        #ifdef IS_DEBUG
        NSLog(@"rs -> CATEGORY_ID:%@", pk);
        #endif
        
        [outDic setValue:dataDic forKey:pk];
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryCategoriesOfLevelOneByCpyCode 查詢完成！ 筆數：%d", [outDic count] );
    #endif
    return outDic;
}


//查詢目前使用者本機端的所有第二層類別
-(NSMutableDictionary *) queryCategoriesOfLevelTwoByCpyCode:(NSString *)cpyCode upperCategoryID:(NSString *)categoryID {
    FMResultSet *rs = [db executeQuery:@"select * from DTMT_CATEGORY where USER=? AND CPY_CODE=? AND UPPER_CATEGORY=?", 
                       [self getUserID], cpyCode, categoryID];
    NSMutableDictionary *outDic = [NSMutableDictionary dictionaryWithCapacity:20];
    
    while ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@", columnName);
            [dataDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
        NSString *pk = [dataDic objectForKey:@"CATEGORY_ID"];
        #ifdef IS_DEBUG
        NSLog(@"rs -> CATEGORY_ID:%@", pk);
        #endif
        
        [outDic setValue:dataDic forKey:pk];
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryCategoriesOfLevelTwoByCpyCode upperCategoryID 查詢完成！ 筆數：%d", [outDic count] );
    #endif
    return outDic;
}


//根據類別ID查詢目前使用者本機端類別資料
-(NSMutableDictionary *) queryCategoryByCategoryID:(NSString *)categoryID {
    
    #ifdef IS_DEBUG
    NSLog(@"queryCategoryByCategoryID:%@", categoryID);
    #endif
    
    FMResultSet *rs = [db executeQuery:@"select * from DTMT_CATEGORY where USER=? and CATEGORY_ID=?", [self getUserID], categoryID];
    NSMutableDictionary *outDic = nil;
    
    if ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        outDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@, value:%@", columnName, [rs objectForColumnIndex:i]);
            [outDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryCategoryByCategoryID 查詢完成！");
    #endif
    return outDic;
}


//根據類別ID及USERid查詢書本資料
-(NSMutableDictionary *) queryBooksDicByCategoryId:(NSString *)categoryID {
    #ifdef IS_DEBUG
    NSLog(@"queryBooksByCategoryId:%@", categoryID);
    #endif
    
    FMResultSet *rs = [db executeQuery:@"select * from DTMT_BOOKS where USER=? and CATEGORY_ID=?", [self getUserID], categoryID];
    NSMutableDictionary *outDic = [NSMutableDictionary dictionaryWithCapacity:10];
    
    while ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@", columnName);
            [dataDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
        NSString *bookID = [dataDic objectForKey:@"BOOK_ID"];
        NSNumber *order = [dataDic objectForKey:@"ORDER"];
        #ifdef IS_DEBUG
        NSLog(@"rs -> BOOK_ID:%@", bookID);
        NSLog(@"rs -> ORDER:%d", [order intValue]);
        [dataDic setValue:order forKey:@"ORDER"];
        #endif
        
        [outDic setValue:dataDic forKey:bookID];

    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryBooksDicByCategoryId 查詢完成！ 筆數：%d", [outDic count] );
    #endif
    return outDic;
}

//根據類別ID及USERid查詢書本資料
-(NSMutableArray *) queryBooksArrayByCategoryId:(NSString *)categoryID {
    #ifdef IS_DEBUG
    NSLog(@"queryBooksByCategoryId:%@", categoryID);
    #endif
    
    FMResultSet *rs = [db executeQuery:@"select * from DTMT_BOOKS where USER=? and CATEGORY_ID=?", [self getUserID], categoryID];
    NSMutableArray *outArray = [NSMutableArray arrayWithCapacity:10];
    
    while ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            //NSLog(@"key:%@", columnName);
            [dataDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
        }
        
        NSString *bookID = [dataDic objectForKey:@"BOOK_ID"];
        #ifdef IS_DEBUG
        NSLog(@"rs -> BOOK_ID:%@", bookID);
        #endif
        
        //設定書本狀態
        RemoteStatus status = [[dataDic objectForKey:@"STATUS"] intValue]; //取得本地書本狀態
        
        switch (status) {
            case RemoteStatusInUse:
                [dataDic setObject:[NSNumber numberWithInt:GridStatusAlreadyDowloaded] forKey:@"BookGridStatus"];
                break;
            case RemoteStatusDeprecated:
                [dataDic setObject:[NSNumber numberWithInt:GridStatusInvalid] forKey:@"BookGridStatus"];
                break;
            default:
                break;
        }
        
        [outArray addObject:dataDic];
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryBooksArrayByCategoryId 查詢完成！ 筆數：%d", [outArray count] );
    #endif
    return outArray;
}


//根據關鍵字及USERid查詢書本資料
-(NSMutableArray *) queryBooksArrayByKeyword:(NSString *)keyword {
    #ifdef IS_DEBUG
    NSLog(@"queryBooksArrayByKeyword:%@", keyword);
    #endif
    
    if (!keyword || [keyword length] == 0) {
        return nil;
    }
    
    //TODO 類別跟公司別只要放ID就好，因為不會下載，只會刪除
    
    /*
     select A.*
     , COALESCE(B.CATEGORY_ID,'') as _CAT_CATEGORY_ID
     , COALESCE(C.CATEGORY_ID,'') as _UPP_CATEGORY_ID
     , COALESCE(D.CPY_CODE,'') as _CPY_CPY_CODE
     from DTMT_BOOKS A
     join DTMT_CATEGORY B
     on A.TITLE like '%新安心保%'
     and A.USER = 'P122777254'
     and A.CATEGORY_ID = B.CATEGORY_ID
     left join DTMT_CATEGORY C
     on B.UPPER_CATEGORY = C.CATEGORY_ID
     join DTMT_COMPANY D
     on B.CPY_CODE = D.CPY_CODE
     group by A.BOOK_ID
     */
     
    NSString *sql = [NSString stringWithFormat:                  
    @"select A.*"
    " , COALESCE(B.CATEGORY_ID,'') as _CAT_CATEGORY_ID"
    " , COALESCE(C.CATEGORY_ID,'') as _UPP_CATEGORY_ID"
    " , COALESCE(D.CPY_CODE,'') as _CPY_CPY_CODE"
    " from DTMT_BOOKS A"
    " join DTMT_CATEGORY B"
    " on A.TITLE like '%%%@%%'"
    " and A.USER = '%@'"
    " and A.CATEGORY_ID = B.CATEGORY_ID"
    " left join DTMT_CATEGORY C"
    " on B.UPPER_CATEGORY = C.CATEGORY_ID"
    " join DTMT_COMPANY D"
    " on B.CPY_CODE = D.CPY_CODE" 
    " group by A.BOOK_ID",keyword , [self getUserID]];

    
    #ifdef IS_DEBUG
    NSLog(@"exec sql==> :%@", sql);
    #endif
    
    FMResultSet *rs = [db executeQuery:sql];
    
    
    NSMutableArray *outArray = [NSMutableArray arrayWithCapacity:10];
    
    while ([rs next]) {
        
        //取得Table所有欄位，並塞入對應資料
        int columnCount = [rs columnCount];
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:columnCount];
        
        for (int i = 0; i<columnCount ; i++) {
            NSString *columnName = [rs columnNameForIndex:i];
            NSString *prefix = [columnName substringToIndex:4]; //取前四碼
            //NSLog(@"prefix:%@", prefix);
            
            if ([prefix isEqualToString:@"_CAT"]) { //組類別資訊
                
                NSMutableDictionary *catDict = [dataDic objectForKey:@"CATEGORY_MAP"];
                if(!catDict){
                    catDict = [NSMutableDictionary dictionaryWithCapacity:5];
                    [dataDic setValue:catDict forKey:@"CATEGORY_MAP"];                    
                }
                
                columnName = [columnName substringFromIndex:5]; //從第五碼開始截
                [catDict setValue:[rs objectForColumnIndex:i] forKey:columnName];
                
                
            }else if ([prefix isEqualToString:@"_UPP"]) { //組上層類別資訊，但不一定會有上一層
                
                NSMutableDictionary *uppDict = [dataDic objectForKey:@"UPPER_FOLDER"];
                if(!uppDict){
                    uppDict = [NSMutableDictionary dictionaryWithCapacity:5];
                    [dataDic setValue:uppDict forKey:@"UPPER_FOLDER"];                    
                }
                
                columnName = [columnName substringFromIndex:5]; //從第五碼開始截
                [uppDict setValue:[rs objectForColumnIndex:i] forKey:columnName];
                
                
            }else if ([prefix isEqualToString:@"_CPY"]) { //組公司資訊

                NSMutableDictionary *cpyDict = [dataDic objectForKey:@"CPY_MAP"];
                if(!cpyDict){
                    cpyDict = [NSMutableDictionary dictionaryWithCapacity:5];
                    [dataDic setValue:cpyDict forKey:@"CPY_MAP"];                    
                }
                
                columnName = [columnName substringFromIndex:5]; //從第五碼開始截
                [cpyDict setValue:[rs objectForColumnIndex:i] forKey:columnName];
                
            }else { //書本資訊
                
                [dataDic setValue:[rs objectForColumnIndex:i] forKey:columnName];
            }
            
            
        }
        
        NSString *bookID = [dataDic objectForKey:@"BOOK_ID"];
        #ifdef IS_DEBUG
        NSLog(@"rs -> BOOK_ID:%@", bookID);
        #endif
        
        //設定書本狀態
        RemoteStatus status = [[dataDic objectForKey:@"STATUS"] intValue]; //取得本地書本狀態
        
        switch (status) {
            case RemoteStatusInUse:
                [dataDic setObject:[NSNumber numberWithInt:GridStatusAlreadyDowloaded] forKey:@"BookGridStatus"];
                break;
            case RemoteStatusDeprecated:
                [dataDic setObject:[NSNumber numberWithInt:GridStatusInvalid] forKey:@"BookGridStatus"];
                break;
            default:
                break;
        }
        
        //NSLog(@"####:%@", dataDic);
        
        [outArray addObject:dataDic];
        
    }
    [rs close];
    
    #ifdef IS_DEBUG
    NSLog(@"queryBooksArrayByKeyword 查詢完成！ 筆數：%d", [outArray count] );
    #endif
    return outArray;
}



#pragma mark - Insert Method

-(BOOL) insertCompanyWithDic:(NSDictionary *)dataDic {
    
    NSString *USER = [self getUserID];
    NSString *CPY_CODE = [dataDic valueForKey:@"CPY_CODE"];
    NSString *CPY_NAME = [dataDic valueForKey:@"CPY_NAME"];
    NSNumber *ORDER = [dataDic valueForKey:@"ORDER"];
    NSNumber *UPDATE_TIME = [dataDic valueForKey:@"UPDATE_TIME"];
    
    #ifdef IS_DEBUG
    NSLog(@"insertCompanyWithDic pass param....\n"  
          "USER:%@, CPY_CODE:%@, CPY_NAME:%@, ORDER:%d, UPDATE_TIME:%d"
          ,USER, CPY_CODE, CPY_NAME, [ORDER intValue], [UPDATE_TIME intValue]
          );
    #endif

    
    
    NSString * sql = @"INSERT INTO DTMT_COMPANY (USER,CPY_CODE,CPY_NAME,\"ORDER\", UPDATE_TIME) VALUES (?,?,?,?,?)";
    
    BOOL success = [db executeUpdate:sql
                    , USER
                    , CPY_CODE
                    , CPY_NAME
                    , ORDER
                    , UPDATE_TIME
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"insert CPY_CODE:%@ failed! errorCode:%d, errorMsg:%@", CPY_CODE, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"insert CPY_CODE:%@ success!",CPY_CODE);
        #endif
    }
    
    return success;
}


-(BOOL) insertCategoryWithDic:(NSDictionary *)dataDic {
    
    NSString *USER = [self getUserID];
    NSString *CATEGORY_ID = [dataDic valueForKey:@"CATEGORY_ID"];
    NSString *CATEGORY_NAME = [dataDic valueForKey:@"CATEGORY_NAME"];
    NSString *TYPE = [dataDic valueForKey:@"TYPE"];
    NSNumber *ORDER = [dataDic valueForKey:@"ORDER"];
    NSString *UPPER_CATEGORY = [dataDic valueForKey:@"UPPER_CATEGORY"];
    NSString *CPY_CODE = [dataDic valueForKey:@"CPY_CODE"];
    NSNumber *UPDATE_TIME = [dataDic valueForKey:@"UPDATE_TIME"];
    
    #ifdef IS_DEBUG
    /*
    NSLog(@"insertCategoryWithDic pass param....\n"  
          "USER:%@, CATEGORY_ID:%@, CATEGORY_NAME:%@, TYPE:%@, ORDER:%d, UPPER_CATEGORY:%@, CPY_CODE:%@, UPDATE_TIME:%d"
          ,USER, CATEGORY_ID, CATEGORY_NAME, TYPE, [ORDER intValue], UPPER_CATEGORY, CPY_CODE, [UPDATE_TIME intValue]
          );
    */
    #endif
    
    
    NSString * sql = @"INSERT INTO DTMT_CATEGORY (USER,CATEGORY_ID,CATEGORY_NAME,TYPE,\"ORDER\",UPPER_CATEGORY,CPY_CODE,UPDATE_TIME) "
                      "VALUES (?,?,?,?,?,?,?,?)";
    
    BOOL success = [db executeUpdate:sql
                    , USER
                    , CATEGORY_ID
                    , CATEGORY_NAME
                    , TYPE
                    , ORDER
                    , UPPER_CATEGORY
                    , CPY_CODE
                    , UPDATE_TIME
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"insert CATEGORY_ID:%@ failed! errorCode:%d, errorMsg:%@", CATEGORY_ID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"insert CATEGORY_ID:%@ success!",CATEGORY_ID);
        #endif
    }
    
    return success;    
}


-(BOOL)insertBookWithDic:(NSDictionary *)dataDic {
    
    NSString *USER = [self getUserID];
    NSString *BOOK_ID = [dataDic valueForKey:@"BOOK_ID"];
    NSString *TITLE = [dataDic valueForKey:@"TITLE"];
    NSString *FILE_EXT = [dataDic valueForKey:@"FILE_EXT"];
    NSString *OPEN_URL = [dataDic valueForKey:@"IOS_OPEN_URL"];
    NSString *STATUS = [dataDic valueForKey:@"STATUS"];
    NSNumber *UPDATE_TIME = [dataDic valueForKey:@"UPDATE_TIME"];
    NSNumber *ORDER = [dataDic valueForKey:@"ORDER"];
    NSString *CATEGORY_ID = [dataDic valueForKey:@"CATEGORY_ID"];
    NSString *FORCEDELETE = [dataDic valueForKey:@"FORCEDELETE"];
    NSString *SHARABLE = [dataDic valueForKey:@"SHARABLE"];
    
    
    #ifdef IS_DEBUG
    NSLog(@"insertCategoryWithDic pass param....\n"  
          "USER:%@, BOOK_ID:%@, TITLE:%@, FILE_EXT:%@, OPEN_URL:%@, STATUS:%@, UPDATE_TIME:%f, ORDER:%d, CATEGORY_ID:%@, \n"
          "FORCE_DELETE:%@, ALLOW_SHARE:%@"
          ,USER, BOOK_ID, TITLE, FILE_EXT, OPEN_URL, STATUS, [UPDATE_TIME floatValue], [ORDER intValue], CATEGORY_ID, FORCEDELETE, SHARABLE
          );
    #endif
    
    
    NSString * sql = @"INSERT INTO DTMT_BOOKS (USER,BOOK_ID,TITLE,FILE_EXT,IOS_OPEN_URL,STATUS,UPDATE_TIME,\"ORDER\",CATEGORY_ID, FORCE_DELETE, ALLOW_SHARE ) "
    "VALUES (?,?,?,?,?,?,?,?,?,?,?)";
    
    BOOL success = [db executeUpdate:sql
                    , USER
                    , BOOK_ID
                    , TITLE
                    , FILE_EXT
                    , OPEN_URL?OPEN_URL:@"" 
                    , STATUS
                    , UPDATE_TIME
                    , ORDER
                    , CATEGORY_ID
                    , FORCEDELETE
                    , SHARABLE
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"insert BOOK_ID:%@ failed! errorCode:%d, errorMsg:%@", BOOK_ID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"insert BOOK_ID:%@ success!",BOOK_ID);
        #endif
    }
    
    return success;
    
}

#pragma mark - Update Method

-(BOOL) updateCompanyWithDic:(NSDictionary *)dataDic {
    
    NSString *USER = [self getUserID];
    NSString *CPY_CODE = [dataDic valueForKey:@"CPY_CODE"];
    NSString *CPY_NAME = [dataDic valueForKey:@"CPY_NAME"];
    NSNumber *ORDER = [dataDic valueForKey:@"ORDER"];
    NSNumber *UPDATE_TIME = [dataDic valueForKey:@"UPDATE_TIME"];
    
    #ifdef IS_DEBUG
    NSLog(@"updateCompanyWithDic pass param....\n"  
          "USER:%@, CPY_CODE:%@, CPY_NAME:%@, ORDER:%d, UPDATE_TIME:%d"
          ,USER, CPY_CODE, CPY_NAME, [ORDER intValue], [UPDATE_TIME intValue]
          );
    #endif

    
    NSString * sql = @"UPDATE DTMT_COMPANY SET CPY_NAME = ?, \"ORDER\" = ?, UPDATE_TIME = ? WHERE USER = ? AND CPY_CODE = ? ";
    
    BOOL success = [db executeUpdate:sql
                    , CPY_NAME
                    , ORDER
                    , UPDATE_TIME
                    , USER
                    , CPY_CODE
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE CPY_CODE:%@ failed! errorCode:%d, errorMsg:%@", CPY_CODE, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE CPY_CODE:%@ success!",CPY_CODE);
        #endif
    }
    
    return success;
}


-(BOOL) updateCategoryWithDic:(NSDictionary *)dataDic {
    
    NSString *USER = [self getUserID];
    NSString *CATEGORY_ID = [dataDic valueForKey:@"CATEGORY_ID"];
    NSString *CATEGORY_NAME = [dataDic valueForKey:@"CATEGORY_NAME"];
    NSString *TYPE = [dataDic valueForKey:@"TYPE"];
    NSNumber *ORDER = [dataDic valueForKey:@"ORDER"];
    NSString *UPPER_CATEGORY = [dataDic valueForKey:@"UPPER_CATEGORY"];
    NSString *CPY_CODE = [dataDic valueForKey:@"CPY_CODE"];
    NSNumber *UPDATE_TIME = [dataDic valueForKey:@"UPDATE_TIME"];
    
    
    NSString * sql = @"UPDATE DTMT_CATEGORY SET CATEGORY_NAME = ? ,TYPE = ?, \"ORDER\" = ? ,UPPER_CATEGORY = ? ,CPY_CODE = ? ,UPDATE_TIME = ?"
    " WHERE USER = ? AND CATEGORY_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , CATEGORY_NAME
                    , TYPE
                    , ORDER
                    , UPPER_CATEGORY
                    , CPY_CODE
                    , UPDATE_TIME
                    , USER
                    , CATEGORY_ID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE CATEGORY_ID:%@ failed! errorCode:%d, errorMsg:%@", CATEGORY_ID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE CATEGORY_ID:%@ success!",CATEGORY_ID);
        #endif
    }
    
    return success;    
}


-(BOOL) updateBookWithDic:(NSDictionary *)dataDic {
    
    NSString *USER = [self getUserID];
    NSString *BOOK_ID = [dataDic valueForKey:@"BOOK_ID"];
    NSString *TITLE = [dataDic valueForKey:@"TITLE"];
    NSString *FILE_EXT = [dataDic valueForKey:@"FILE_EXT"];
    NSString *IOS_OPEN_URL = [dataDic valueForKey:@"IOS_OPEN_URL"];
    NSString *STATUS = [dataDic valueForKey:@"STATUS"];
    NSNumber *UPDATE_TIME = [dataDic valueForKey:@"UPDATE_TIME"];
    NSNumber *ORDER = [dataDic valueForKey:@"ORDER"];
    NSString *CATEGORY_ID = [dataDic valueForKey:@"CATEGORY_ID"];
    NSString *FORCEDELETE = [dataDic valueForKey:@"FORCEDELETE"];
    NSString *SHARABLE = [dataDic valueForKey:@"SHARABLE"];
    
    NSString * sql = @"UPDATE DTMT_BOOKS SET TITLE = ? ,FILE_EXT = ? ,IOS_OPEN_URL = ? ,STATUS = ? ,UPDATE_TIME = ? ,\"ORDER\" = ? "
    " ,CATEGORY_ID = ?  ,FORCE_DELETE = ? ,ALLOW_SHARE = ?"
    " WHERE USER = ? AND BOOK_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , TITLE
                    , FILE_EXT
                    , IOS_OPEN_URL?IOS_OPEN_URL:@"" 
                    , STATUS
                    , UPDATE_TIME
                    , ORDER
                    , CATEGORY_ID
                    , FORCEDELETE
                    , SHARABLE
                    , USER
                    , BOOK_ID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE BOOK_ID:%@ failed! errorCode:%d, errorMsg:%@", BOOK_ID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE BOOK_ID:%@ success!",BOOK_ID);
        #endif
    }
    
    return success;
    
}

//更新書本標題、排序、狀態、強迫刪除、允許分享
-(BOOL) updateBookByBookID:(NSString *) bookID WithTitle:(NSString *) title Order:(NSNumber *)order Status:(RemoteStatus) status 
ForceDelete:(NSString *) deletable Sharable:(NSString *) sharable{
    
    
    NSString *USER = [self getUserID];

    NSString * sql = @"UPDATE DTMT_BOOKS SET TITLE = ? ,STATUS = ? ,\"ORDER\" = ? ,FORCE_DELETE = ? ,ALLOW_SHARE = ?"
    " WHERE USER = ? AND BOOK_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , title
                    , [NSNumber numberWithInt:status]
                    , order
                    , deletable
                    , sharable
                    , USER
                    , bookID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE BOOK_ID:%@ failed! errorCode:%d, errorMsg:%@", bookID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"UPDATE BOOK_ID:%@ success!",bookID);
        #endif
    }
    
    return success;
    
}


//依類別id更新書本狀態
-(BOOL) updateBookStatus:(RemoteStatus) status ByCategoryID:(NSString *) categoryID {
    
    NSString *USER = [self getUserID];
    
    NSString * sql = @"UPDATE DTMT_BOOKS SET STATUS = ?"
    " WHERE USER = ? AND CATEGORY_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , [NSNumber numberWithInt:status]
                    , USER
                    , categoryID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"updateBookStatus categoryID:%@ failed! errorCode:%d, errorMsg:%@", categoryID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"updateBookStatus categoryID:%@ success!",categoryID);
        #endif
    }
    
    return success;
    
}

-(BOOL) updateBookStatus:(RemoteStatus) status withBookIDs:(NSMutableSet *) bookIDs {
        
    for (NSString *bookID in bookIDs) {
        [self updateBookStatus:status ByBookID:bookID];
    }

}


-(BOOL) updateBookStatus:(RemoteStatus) status ByBookID:(NSString *)bookID {

    
    NSString *USER = [self getUserID];
    
    NSString * sql = @"UPDATE DTMT_BOOKS SET STATUS = ?"
    " WHERE USER = ? AND BOOK_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , [NSNumber numberWithInt:status]
                    , USER
                    , bookID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"updateBookStatus BOOK_ID:%@ failed! errorCode:%d, errorMsg:%@", bookID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"updateBookStatus BOOK_ID:%@ success!",bookID);
        #endif
    }
    
    return success;
    
}


#pragma mark - Update Method

-(BOOL) deleteBookWithBookID:(NSString *) bookID {
    
    NSString *USER = [self getUserID];
    
    NSString * sql = @"DELETE FROM DTMT_BOOKS"
    " WHERE USER = ? AND BOOK_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , USER
                    , bookID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"deleteBookWithBookID BOOK_ID:%@ failed! errorCode:%d, errorMsg:%@", bookID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"deleteBookWithBookID BOOK_ID:%@ success!",bookID);
        #endif
    }
    
    return success;
    
}


-(BOOL) deleteCategoryWithCategoryID:(NSString *) categoryID {
    
    NSString *USER = [self getUserID];
    
    NSString * sql = @"DELETE FROM DTMT_CATEGORY"
    " WHERE USER = ? AND CATEGORY_ID = ?";
    
    BOOL success = [db executeUpdate:sql
                    , USER
                    , categoryID
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"deleteCategoryWithCategoryID CATEGORY_ID:%@ failed! errorCode:%d, errorMsg:%@", categoryID, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"deleteCategoryWithCategoryID CATEGORY_ID:%@ success!",categoryID);
        #endif
    }
    
    return success;
}


-(BOOL) deleteCompanyWithCompanyCode:(NSString *) cpyCode {
    
    NSString *USER = [self getUserID];
    
    NSString * sql = @"DELETE FROM DTMT_COMPANY"
    " WHERE USER = ? AND CPY_CODE = ?";
    
    BOOL success = [db executeUpdate:sql
                    , USER
                    , cpyCode
                    ];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"deleteCompanyWithCompanyCode CPY_CODE:%@ failed! errorCode:%d, errorMsg:%@", cpyCode, [db lastErrorCode], [db lastErrorMessage] );
        #endif
    }else {
        #ifdef IS_DEBUG
        NSLog(@"deleteCompanyWithCompanyCode CPY_CODE:%@ success!",cpyCode);
        #endif
    }
    
    return success;
}

@end
