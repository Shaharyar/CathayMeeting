//
//  CathayGlobalVariable.h
//
//  Created by dev1 on 2011/4/19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

//--------------------
//網路

//系統連線設定，需要連線的目標不要註解
//例：要連至測試環境，就將STAG及PROD註解
//#define TEST_URL
#define PROD_URL

//--------------------
//其他

//是否開啟DEBUG模式，註解掉便不開啟
//#define IS_DEBUG


//
#define DOCUMENT_PLIST_NAME @"DocumentsList.plist"

//訊息
#define MSG_LOADING @"資料載入中..."

//錯誤訊息
#define ERROR_MSG_DEFAULT @"很抱歉發生了點問題，請重試！"
#define ERROR_MSG_NET @"網路連線異常或速度緩慢，請重試！"
#define ERROR_MSG_DATA_NOT_FOUND @"很抱歉，查無資料！"

//App TimeOut強迫重新登入時間設定，未真正關閉程式時有效
#define TIMEOUT_MINS 18