//
//  SQLite.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/10.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//


#import "SQLite.h"

static SQLite *_SQLite;

@implementation SQLite
{
    NSString *_databaseFilePath; //SQLiteのファイルパス
}


//共有のデータベースを返す
+(SQLite *)sharedSQLite
{
    //共有するSQLiteをアプリケーション中に一つだけ作成。
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^{
        _SQLite = [[SQLite alloc] initWithPath:self.path];
        [_SQLite setup];
    });
    
    //NSLog(@"sharedSQLiteは正常に呼び出された");
    
    return _SQLite;
}


//pathのゲッタクラスメソッド
+(NSString *)path
{
    static NSString *databaseFilePath = nil;//SQLiteが利用するファイルパスのパス文字列
    if (databaseFilePath) {//nilでないなら
    
        NSLog(@"pathの中でdatabaseFilePathはnilでありませんでした (SQLite, path)");
        
        return databaseFilePath;
    }
    
    //NSDocumentationと間違えると、データベースは作成されないよ
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//Sandboxのドキュメントディレクトリを指定する
    NSString *directoryPath = [paths lastObject];
    //Sandboxのドキュメントディレクトリ直下にあるTrainey.sqliteという名前のファイルへのファイルパスを作成
    databaseFilePath = [directoryPath stringByAppendingPathComponent:@"Trainey.sqlite"];
    
    return databaseFilePath;
    
}


//SQLiteのファイルパスをこのクラスのパスに指定する
- (id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self) {
        _databaseFilePath = path;
    }
    
    NSLog(@"正常に呼び出された. (SQLite, initWithPath)");
    
    return self;
}


//SQLiteの利用開始
static sqlite3 *openDB(NSString *path)
{
    sqlite3 *database = nil;
    int result = sqlite3_open([path fileSystemRepresentation], &database);
    if (result != SQLITE_OK) {
        printf("SQLiteの利用に失敗(openDB) (%d) '%s' .\n", result, sqlite3_errmsg(database));
        return nil;
    }
    return database;
}


//日付を受け取り、指定されたフォーマットで返すメソッド
+(NSString *)createDate:(NSDate *)date
{
    
    // 日付フォーマットオブジェクトの生成
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // フォーマットを指定の日付フォーマットに設定
    [dateFormatter setDateFormat:@"yyyy/MM/dd (EEE)"];
    // 日付型の文字列を生成
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}


//SQLiteの利用終了
static BOOL closeDB(sqlite3 *database)
{
    int result = sqlite3_close(database);
    if (result != SQLITE_OK) {
        printf("SQLiteの利用に失敗(closeDB) (%d) '%s' .\n", result, sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}


//SQLiteのSQL文実行用ステートメントの破棄とエラー処理
static BOOL finalizeStatement(sqlite3 *database, sqlite3_stmt *statement)
{
    if (sqlite3_finalize(statement) != SQLITE_OK) {
        printf("sqlite3_finalizeに失敗 '%s' .\n", sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}


//SQLiteのSQL文実行とエラー処理
static BOOL stepStatement(sqlite3 *database, sqlite3_stmt *statement)
{
    if (sqlite3_step(statement) == SQLITE_ERROR) {
        printf("Failed to sqlite3_step　に失敗 '%s' .\n", sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}


//SQLiteのSQL文実行用ステートメントの準備とエラー処理
static BOOL prepareStatement(sqlite3 *database, const char *sql, sqlite3_stmt **statement)
{
    *statement = nil;
    int result = sqlite3_prepare_v2(database, sql, -1, statement, NULL);
    if (result != SQLITE_OK) {
        printf("sqlite3_prepare_v2に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}


//データベース用テーブルを作成
-(void)setup
{
    
    //SQLiteがデータベース用に利用するファイルを決める
    if ([[NSFileManager defaultManager]fileExistsAtPath:_databaseFilePath]) {
        //データベースファイルが存在するかチェク
        //存在した場合、テーブル作成は終わっているので何もしない
        
        NSLog(@"データベースファイルがあることは確認された. (SQLite, setup)");
        
        return;
    }
    
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) {
        //データベースのオープンに失敗した。
        
        NSLog(@"openDBに失敗した. (SQLite, setup)");
        
        return;
    }
    const char *sql ="create table menus(menu_pk integer primary key,  menuCategory integer, menuName text);"
    "create table records(record_pk integer primary key, date_pk integer, menu_pk integer, isTry integer, weight double, repeatCount integer);"
    "create table historys(history_pk integer primary key, date_pk integer, menu_pk integer, isTry integer, weight double, repeatCount integer);"
    "create table dates(date_pk integer primary key, dateText text)"
    ;
    const char* next_sql = sql;
    do {
        sqlite3_stmt *statement = nil;
        int result = sqlite3_prepare_v2(database, next_sql, -1, &statement, &next_sql);//ステートメント準備
        if (result != SQLITE_OK) {
            printf("テーブル作成に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
            finalizeStatement(database, statement);
            closeDB(database);
            return;
        }
        if (stepStatement(database, statement) == NO) { //失敗した。
            printf("テーブル作成に失敗 (setup)\n");
            finalizeStatement(database, statement);//SQLiteのSQL文実行用ステートメントの破棄とエラー処理
            closeDB(database);//利用終了
            return;
        }
        if (finalizeStatement(database, statement) == NO) { //失敗した。
            printf("テーブル作成に失敗 (setup)\n");
            closeDB(database);
            return;
        }
    }while (*next_sql != 0); //C文字終端コードでないならループ
    
    closeDB(database);
    
    NSLog(@"正常に呼び出された. (SQLite, setup)");
    
}


#pragma mark - Record


//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をrecordに追加する
-(id)addRecord:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu
{
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("recordの追加に失敗 (SQLite, addRecord)\n");
        return nil;
    }
    //dateの設定
    int date_pk = 0;
    NSString *dateText = nil;
    if (date) {
        date_pk = [date[@"date_pk"] intValue];
        dateText = date[@"dateText"];
    }
    
    //menuの設定
    int menu_pk = 0;
    int menuCategory = -1;
    NSString *menuName = nil;
    if (menu) { //menuがnilでないなら
        menu_pk = [menu[@"menu_pk"] intValue];
        menuCategory = [menu[@"menuCategory"] intValue];
        menuName = menu[@"menuName"];
    }
    
    id record = [self addRecordWithDatabase:database
                                    date_pk:date_pk
                                   dateText:dateText
                                    menu_pk:menu_pk
                               menuCategory:menuCategory
                                   menuName:menuName
                                      isTry:isTry
                                     weight:weight
                                repeatCount:repeatCount];
    
    if (closeDB(database) == NO) {
        printf("recordの追加に失敗 (SQLite, addRecord)\n");
        return nil;
    }
    if (record == nil) {
        printf("recordの追加に失敗 (SQLite, addRecord)\n");
    }
    return record;
                 
}


//データベースへの成績追加とrecord用NSDictionaryの作成
-(NSDictionary *)addRecordWithDatabase:(sqlite3 *)database date_pk:(int)date_pk dateText:(NSString *)dateText menu_pk:(int)menu_pk menuCategory:(int)menuCategory menuName:(NSString *)menuName isTry:(int)isTry weight:(double)weight repeatCount:(int)repeatCount
{
    sqlite3_stmt *statement;
    //登録用ステートメント準備
    if (prepareStatement(database, "insert into records(date_pk, menu_pk, isTry, weight, repeatCount) values(?, ?, ?, ?, ?)", &statement) == NO) {
        return nil;
    }
    
    //date_pkの設定
    int result = sqlite3_bind_int(statement, 1, date_pk);
    //menu_pk(FK)の設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(statement, 2, menu_pk);
    }
    //isTryの設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(statement, 3, isTry);
    }
    //weightの設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_double(statement, 4, weight);
    }
    //repeatCountの設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(statement, 5, repeatCount);
    }
    //失敗したら
    if (result != SQLITE_OK) {
        printf("insert into での値の準備に失敗 (%d) '%s' .\n",result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return nil;
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return nil;
    }
    //record_pk(PK)取り出し
    sqlite3_int64 record_pk = sqlite3_last_insert_rowid(database);
    if (finalizeStatement(database, statement) == NO) {
        return nil;
    }
    return recordWithPK(record_pk, date_pk, dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
    
}


//record_pk(PK)をつかって、Record情報NSDictionaryを作成しても戻す。
static id recordWithPK(sqlite3_int64 record_pk, int date_pk, NSString *dateText, int menu_pk, int menuCategory, NSString *menuName, int isTry, double weight, int repeatCount)
{
    NSMutableDictionary *mutableRecord = [@{
                                            @"record_pk":@(record_pk),
                                            @"date_pk":@(date_pk),
                                            @"dateText":dateText,
                                            @"menu_pk":@(menu_pk),
                                            @"menuCategory":@(menuCategory),
                                            @"menuName":menuName,
                                            @"isTry":@(isTry),
                                            @"weight":@(weight),
                                            @"repeatCount":@(repeatCount)
                                            } mutableCopy];
    
    return [mutableRecord copy];
}


//record_pkを利用してレコードを消す
-(BOOL)deleteRecordForPK:(long long)record_pk
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("record削除失敗 (deleteRecordForPK)");
        return NO;
    }
    sqlite3_stmt *statement;
    //contents削除用ステートメント準備
    if (prepareStatement(database, "delete from records where record_pk=?", &statement) == NO) {
        printf("record削除失敗 (deleteRecordForPK)");
        closeDB(database);
        return NO;
    }
    int result = sqlite3_bind_int64(statement, 1, record_pk);
    if (result != SQLITE_OK) {
        printf("delete from recordsでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    
    //実行
    if (stepStatement(database, statement) == NO) {
        printf("record削除失敗 (deleteRecordForPK)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("record削除失敗 (deleteRecordForPK)\n");
        closeDB(database);
        return NO;
    }
    return closeDB(database);
}


//record_pkを利用してレコードを消す
-(BOOL)deleteRecordAtdateText:(NSString *)dateText forPK:(long long)record_pk
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("record削除失敗 (deleteRecordAtdateText)");
        return NO;
    }
    sqlite3_stmt *statement;
    //contents削除用ステートメント準備
    if (prepareStatement(database, "delete from records where date_pk=? and record_pk=?", &statement) == NO) {
        printf("record削除失敗 (deleteRecordAtdateText)");
        closeDB(database);
        return NO;
    }
    
    long long date_pk = [self date:database dateText:dateText];
    
    
    int result = sqlite3_bind_int64(statement, 1, date_pk);
    if (result == SQLITE_OK) {
    result = sqlite3_bind_int64(statement, 2, record_pk);
    }
    if (result != SQLITE_OK) {
        printf("delete from recordsでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    
    //実行
    if (stepStatement(database, statement) == NO) {
        printf("record削除失敗 (deleteRecordForPK)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("record削除失敗 (deleteRecordForPK)\n");
        closeDB(database);
        return NO;
    }
    return closeDB(database);
}


//record_pk行目のkey値のカラム値を設定するメソッド
-(id)setRecordValue:(id)value forKey:(id)key record_pk:(long long)record_pk
{
    NSString *column = key;
    char *sql = nil;
    if (asprintf(&sql, "update records set %s=? where record_pk=?", [column UTF8String]) < 0) {
        printf("record設定用のSQL文を作れませんでした。(setRecordValue)\n");
        return nil;
    }
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) {  //データベースのオープンに失敗
        printf("record設定失敗 (setRecordValue)");
        free(sql);
        return nil;
    }
    sqlite3_stmt *statement;
    //record設定用ステートメント準備
    if (prepareStatement(database, sql, &statement) == NO) {
        printf("record設定失敗 (setRecordValue)");
        closeDB(database);
        free(sql);
        return nil;
    }
    
    int result = SQLITE_OK;
    if ([key isEqualToString:@"dateText"])
    {
        NSString *dateText = [SQLite createDate:(NSDate *)value];
        const char *valueText = [dateText UTF8String];
        result = sqlite3_bind_text(statement, 1, valueText, -1, SQLITE_STATIC);
    }
    else if ([key isEqualToString:@"menuCategory"])
    {
            result = sqlite3_bind_int(statement, 1, [value intValue]);
    }
    else if ([key isEqualToString:@"menuName"])
    {
            const char *valueText = [value UTF8String];
            result = sqlite3_bind_text(statement, 1, valueText, -1, SQLITE_STATIC);
    }
    else if ([key isEqualToString:@"isTry"])
    {
            result = sqlite3_bind_int(statement, 1, [value intValue]);
    }
    else if ([key isEqualToString:@"weight"])
    {
            result = sqlite3_bind_double(statement, 1, [value floatValue]);
    }
    else if ([key isEqualToString:@"repeatCount"])
    {
            result = sqlite3_bind_int(statement, 1, [value intValue]);
    }
    
    if(result == SQLITE_OK){
        
        result = sqlite3_bind_int64(statement, 2, record_pk);
        
    }
    if (result != SQLITE_OK) {
        printf("update recordsでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;
    }
    //  実行。
    if (stepStatement(database, statement) == NO) {
        printf("成績設定失敗 (setRecordValue)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;  //  失敗した。
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("record設定失敗 (setRecordValue)\n");
        closeDB(database);
        free(sql);
        return nil;
    }
    free(sql);
    
    
    //menu_pkの切り替えの場合、生徒や名前やクラスを取り出す必要がある。
    if ([key isEqualToString:@"menu_pk"]) {
        int menu_pk = [value intValue];
        if (menu_pk != 0) {
            value = [self menu:database menu_pk:menu_pk];
            if (value == nil) {
                printf("record設定失敗 (setRecordValue)");
                closeDB(database);
                return nil;
            }
        }
    }
    if (closeDB(database) == NO) {
        printf("record設定失敗 (setRecordValue)\n");
        return nil;
    }
    return value;
}


#pragma mark - History


//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をhistoryに追加する
-(id)addHistory:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu
{
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("historyの追加に失敗 (SQLite, addHistory)\n");
        return nil;
    }
    
    //dateの設定
    int date_pk = 0;
    NSString *dateText = nil;
    if (date) {
        date_pk = [date[@"date_pk"] intValue];
        dateText = date[@"dateText"];
    }
    
    //menuの設定
    int menu_pk = 0;
    int menuCategory = -1;
    NSString *menuName = nil;
    if (menu) { //menuがnilでないなら
        menu_pk = [menu[@"menu_pk"] intValue];
        menuCategory = [menu[@"menuCategory"] intValue];
        menuName = menu[@"menuName"];
    }
    
    id history = [self addHistoryWithDatabase:database
                                      date_pk:date_pk
                                   dateText:dateText
                                    menu_pk:menu_pk
                               menuCategory:menuCategory
                                   menuName:menuName
                                      isTry:isTry
                                     weight:weight
                                repeatCount:repeatCount];
    
    if (closeDB(database) == NO) {
        printf("historyの追加に失敗 (SQLite, addHistory)\n");
        return nil;
    }
    if (history == nil) {
        printf("historyの追加に失敗 (SQLite, addHistory)\n");
    }
    return history;
    
}


//データベースへの成績追加と成績用NSDictionaryの作成
-(NSDictionary *)addHistoryWithDatabase:(sqlite3 *)database date_pk:(int)date_pk dateText:(NSString *)dateText menu_pk:(int)menu_pk menuCategory:(int)menuCategory menuName:(NSString *)menuName isTry:(int)isTry weight:(double)weight repeatCount:(int)repeatCount
{
    sqlite3_stmt *statement;
    //登録用ステートメント準備
    if (prepareStatement(database, "insert into historys(date_pk, menu_pk, isTry, weight, repeatCount) values(?, ?, ?, ?, ?)", &statement) == NO) {
        return nil;
    }
    
    //date_pk(FK)の設定
    int result = sqlite3_bind_int(statement, 1, date_pk);
    //menu_pk(FK)の設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(statement, 2, menu_pk);
    }
    //isTryの設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(statement, 3, isTry);
    }
    //weightの設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_double(statement, 4, weight);
    }
    //repeatCountの設定
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(statement, 5, repeatCount);
    }
    //失敗したら
    if (result != SQLITE_OK) {
        printf("insert into での値の準備に失敗 (%d) '%s' .\n",result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return nil;
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return nil;
    }
    //record_pk(PK)取り出し
    sqlite3_int64 history_pk = sqlite3_last_insert_rowid(database);
    if (finalizeStatement(database, statement) == NO) {
        return nil;
    }
    return historyWithPK(history_pk, date_pk, dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
    
}


//history_pk(PK)をつかって、History情報NSDictionaryを作成しても戻す。
static id historyWithPK(sqlite3_int64 history_pk, int date_pk, NSString *dateText, int menu_pk, int menuCategory, NSString *menuName, int isTry, double weight, int repeatCount)
{
    //
    NSMutableDictionary *mutableRecord = [@{
                                            @"history_pk":@(history_pk),
                                            @"date_pk":@(date_pk),
                                            @"dateText":dateText,
                                            @"menu_pk":@(menu_pk),
                                            @"menuCategory":@(menuCategory),
                                            @"menuName":menuName,
                                            @"isTry":@(isTry),
                                            @"weight":@(weight),
                                            @"repeatCount":@(repeatCount)
                                            } mutableCopy];
    
    return [mutableRecord copy];
}


//record_pk行目のkey値のカラム値を設定するメソッド
-(id)setHistoryValue:(id)value forKey:(id)key history_pk:(long long)history_pk
{
    NSString *column = key;
    char *sql = nil;
    if (asprintf(&sql, "update historys set %s=? where history_pk=?", [column UTF8String]) < 0) {
        printf("history設定用のSQL文を作れませんでした。(setHistoryValue)\n");
        return nil;
    }
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) {  //データベースのオープンに失敗
        printf("history設定失敗 (setHistoryValue)");
        free(sql);
        return nil;
    }
    sqlite3_stmt *statement;
    //record設定用ステートメント準備
    if (prepareStatement(database, sql, &statement) == NO) {
        printf("history設定失敗 (setHistoryValue)");
        closeDB(database);
        free(sql);
        return nil;
    }
    
    int result = SQLITE_OK;
    if ([key isEqualToString:@"dateText"])
    {
        NSString *dateText = [SQLite createDate:(NSDate *)value];
        const char *valueText = [dateText UTF8String];
        result = sqlite3_bind_text(statement, 1, valueText, -1, SQLITE_STATIC);
    }
    else if ([key isEqualToString:@"menuCategory"])
    {
        result = sqlite3_bind_int(statement, 1, [value intValue]);
    }
    else if ([key isEqualToString:@"menuName"])
    {
        const char *valueText = [value UTF8String];
        result = sqlite3_bind_text(statement, 1, valueText, -1, SQLITE_STATIC);
    }
    else if ([key isEqualToString:@"isTry"])
    {
        result = sqlite3_bind_int(statement, 1, [value intValue]);
    }
    else if ([key isEqualToString:@"weight"])
    {
        result = sqlite3_bind_double(statement, 1, [value floatValue]);
    }
    else if ([key isEqualToString:@"repeatCount"])
    {
        result = sqlite3_bind_int(statement, 1, [value intValue]);
    }
    
    if(result == SQLITE_OK){
        
        result = sqlite3_bind_int64(statement, 2, history_pk);
        
    }
    if (result != SQLITE_OK) {
        printf("update historysでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;
    }
    //  実行。
    if (stepStatement(database, statement) == NO) {
        printf("成績設定失敗 (setHistoryValue)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;  //  失敗した。
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("record設定失敗 (setHistoryValue)\n");
        closeDB(database);
        free(sql);
        return nil;
    }
    free(sql);
    
    
    //menu_pkの切り替えの場合、生徒や名前やクラスを取り出す必要がある。
    if ([key isEqualToString:@"menu_pk"]) {
        int menu_pk = [value intValue];
        if (menu_pk != 0) {
            value = [self menu:database menu_pk:menu_pk];
            if (value == nil) {
                printf("record設定失敗 (setHistoryValue)");
                closeDB(database);
                return nil;
            }
        }
    }
    if (closeDB(database) == NO) {
        printf("record設定失敗 (setHistoryValue)\n");
        return nil;
    }
    return value;
}


//history_pkを利用してレコードを消す
-(BOOL)deleteHistoryForPK:(long long)history_pk
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("history削除失敗 (deleteRecordForPK)");
        return NO;
    }
    sqlite3_stmt *statement;
    //contents削除用ステートメント準備
    if (prepareStatement(database, "delete from historys where history_pk=?", &statement) == NO) {
        printf("history削除失敗 (deleteHistoryForPK)");
        closeDB(database);
        return NO;
    }
    int result = sqlite3_bind_int64(statement, 1, history_pk);
    if (result != SQLITE_OK) {
        printf("delete from historysでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    
    //実行
    if (stepStatement(database, statement) == NO) {
        printf("record削除失敗 (deleteHistoryForPK)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("record削除失敗 (deleteHistoryForPK)\n");
        closeDB(database);
        return NO;
    }
    return closeDB(database);
}


#pragma mark - Menu


//menuCategory、menuNameをmenuに追加する
-(id)addMenu:(int)menuCategory menuName:(NSString *)menuName
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("menuの追加に失敗 (addMenu)\n");
        return nil;
    }
    
    id menu = [self addMenuWithDatabase:database
                               menuCategory:menuCategory
                                   menuName:menuName];
    
    if (closeDB(database) == NO) {
        printf("menuの追加に失敗 (addMenu)\n");
        return nil;
    }
    if (menu == nil) {
        printf("menuの追加に失敗 (addMenu)\n");
    }
    return menu;
    
}


//データベースへのmenu追加とmenu用NSDictionaryの作成
-(NSDictionary *)addMenuWithDatabase:(sqlite3 *)database menuCategory:(int)menuCategory menuName:(NSString *)menuName
{
    
    sqlite3_stmt *statement;
    //登録用ステートメント準備
    if (prepareStatement(database, "insert into menus(menuCategory, menuName) values(?, ?)", &statement) == NO) {
        return nil;
    }
    
    //menuCategoryの設定
    int result = sqlite3_bind_int(statement, 1, menuCategory);
    //menuNameの設定
    if (result == SQLITE_OK) {
    const char *menuNameText = [menuName UTF8String];
    result = sqlite3_bind_text(statement, 2, menuNameText, -1, SQLITE_STATIC);
    }
    
    //失敗したら
    if (result != SQLITE_OK) {
        printf("insert into での値の準備に失敗 (%d) '%s' .\n",result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return nil;
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return nil;
    }
    //menu_pk(PK)取り出し
    sqlite3_int64 menu_pk = sqlite3_last_insert_rowid(database);
    //
    if (finalizeStatement(database, statement) == NO) {
        return nil;
    }
    return menuWithPK(menu_pk, menuCategory, menuName);
    
}


//menu_pk(PK)を使って、Menu情報NSDictionaryを作成して戻す。
static id menuWithPK(sqlite3_int64 menu_pk, int menuCategory, NSString *menuName)
{
    
    //
    NSMutableDictionary *mutableMenu = [@{
                                            @"menu_pk":@(menu_pk),
                                            @"menuCategory":@(menuCategory),
                                            @"menuName":menuName
                                            } mutableCopy];
    
    return [mutableMenu copy];
    
}


//menu_pkで指定されるMenusテーブルのレコードを削除する。失敗したらNOを戻す。
-(BOOL)deleteMenuForPK:(long long)menu_pk
{
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("menu削除失敗 (deleteMenuForPK)");
        return NO;
    }
    sqlite3_stmt *statement;
    //contents削除用ステートメント準備
    if (prepareStatement(database, "delete from menus where menu_pk=?", &statement) == NO) {
        printf("menu削除失敗 (deleteMenuForPK)");
        closeDB(database);
        return NO;
    }
    int result = sqlite3_bind_int64(statement, 1, menu_pk);
    if (result != SQLITE_OK) {
        printf("delete from menusでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    
    //実行
    if (stepStatement(database, statement) == NO) {
        printf("menu削除失敗 (deleteMenuForPK)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("menu削除失敗 (deleteMenuForPK)\n");
        closeDB(database);
        return NO;
    }
    return closeDB(database);
    
}


//menu_pk行目のkey値のカラム値を設定するメソッド
-(id)setMenuValue:(id)value forKey:(id)key menu_pk:(long long)menu_pk
{
    
    NSString *column = key;
    char *sql = nil;
    if (asprintf(&sql, "update menus set %s=? where menu_pk=?", [column UTF8String]) < 0) {
        printf("menu設定用のSQL文を作れませんでした。(setMenuValue)\n");
        return nil;
    }
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) {  //データベースのオープンに失敗
        printf("menu設定失敗 (setMenuValue)");
        free(sql);
        return nil;
    }
    sqlite3_stmt *statement;
    //record設定用ステートメント準備
    if (prepareStatement(database, sql, &statement) == NO) {
        printf("menu設定失敗 (setMenuValue)");
        closeDB(database);
        free(sql);
        return nil;
    }
    
    int result = SQLITE_OK;
    if (result == SQLITE_OK) {
        if ([key isEqualToString:@"menuCategory"]) {
            result = sqlite3_bind_int(statement, 5, [value intValue]);
        }
    }
    if (result == SQLITE_OK) {
        if ([key isEqualToString:@"menuName"]) {
            const char *valueText = [value UTF8String];
            result = sqlite3_bind_text(statement, 6, valueText, -1, SQLITE_OK);
        }
    }
    if (result != SQLITE_OK) {
        printf("update menusでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;
    }
    //  実行。
    if (stepStatement(database, statement) == NO) {
        printf("menu設定失敗 (setMenuValue)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;  //  失敗した。
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("menu設定失敗 (setMenuValue)\n");
        closeDB(database);
        free(sql);
        return nil;
    }
    free(sql);
    
    //menu_pkの切り替えの場合、生徒や名前やクラスを取り出す必要がある。
    if ([key isEqualToString:@"menu_pk"]) {
        int menu_pk = [value intValue];
        if (menu_pk != 0) {
            value = [self menu:database menu_pk:menu_pk];
            if (value == nil) {
                printf("menu設定失敗 (setMenuValue)");
                closeDB(database);
                return nil;
            }
        }
    }
    if (closeDB(database) == NO) {
        printf("menu設定失敗 (setMenuValue)\n");
        return nil;
    }
    return value;
    
}


#pragma mark - Date


//menuCategory、menuNameをmenuに追加する
-(id)addDate:(NSString *)dateText
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("dateTextの追加に失敗 (SQLite, addDate)\n");
        return nil;
    }
    
    id date = [self addDateWithDatabase:database
                           dateText:dateText];
    
    if (closeDB(database) == NO) {
        printf("dateの追加に失敗 (SQLite, addDate)\n");
        return nil;
    }
    if (date == nil) {
        printf("dateの追加に失敗 (SQLite, addDate)\n");
    }
    return date;
    
}


//データベースへのmenu追加とmenu用NSDictionaryの作成
-(NSDictionary *)addDateWithDatabase:(sqlite3 *)database dateText:(NSString *)dateText
{
    
    sqlite3_stmt *statement; //成績追加用に使用するステートメント
    //登録用ステートメント準備
    if (prepareStatement(database, "insert into dates(dateText) values(?)", &statement) == NO) {
        return nil;
    }
    
    //dateTextの設定
    const char *dateTextText = [dateText UTF8String];
    int result = sqlite3_bind_text(statement, 1, dateTextText, -1, SQLITE_STATIC);
    
    //失敗したら
    if (result != SQLITE_OK) {
        printf("insert into での値の準備に失敗 (%d) '%s' .\n",result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return nil;
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return nil;
    }
    //menu_pk(PK)取り出し
    sqlite3_int64 date_pk = sqlite3_last_insert_rowid(database);
    //
    if (finalizeStatement(database, statement) == NO) {
        return nil;
    }
    
    //menu情報NSDictionnaryを作成して戻す
    return dateWithPK(date_pk, dateText);
    
}


//menu_pk(PK)を使って、Menu情報NSDictionaryを作成して戻す。
static id dateWithPK(sqlite3_int64 date_pk, NSString *dateText)
{
    
    NSMutableDictionary *mutableDate = [@{
                                          @"date_pk":@(date_pk),
                                          @"dateText":dateText
                                          } mutableCopy];
    
    return [mutableDate copy];
    
}


//menu_pkで指定されるMenusテーブルのレコードを削除する。失敗したらNOを戻す。
-(BOOL)deleteDateForPK:(long long)date_pk
{
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("date削除失敗 (deleteDateForPK)");
        return NO;
    }
    sqlite3_stmt *statement;
    //contents削除用ステートメント準備
    if (prepareStatement(database, "delete from dates where date_pk=?", &statement) == NO) {
        printf("date削除失敗 (deleteDateForPK)");
        closeDB(database);
        return NO;
    }
    int result = sqlite3_bind_int64(statement, 1, date_pk);
    if (result != SQLITE_OK) {
        printf("delete from datesでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    
    //実行
    if (stepStatement(database, statement) == NO) {
        printf("date削除失敗 (deleteDateForPK)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        return NO;
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("date削除失敗 (deleteDateForPK)\n");
        closeDB(database);
        return NO;
    }
    return closeDB(database);
    
}


//menu_pk行目のkey値のカラム値を設定するメソッド
-(id)setDateValue:(id)value forKey:(id)key date_pk:(long long)date_pk
{
    
    NSString *column = key;
    char *sql = nil;
    if (asprintf(&sql, "update dates set %s=? where date_pk=?", [column UTF8String]) < 0) {
        printf("date設定用のSQL文を作れませんでした。(setDateValue)\n");
        return nil;
    }
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) {  //データベースのオープンに失敗
        printf("date設定失敗 (setDateValue)");
        free(sql);
        return nil;
    }
    sqlite3_stmt *statement;
    //record設定用ステートメント準備
    if (prepareStatement(database, sql, &statement) == NO) {
        printf("date設定失敗 (setDateValue)");
        closeDB(database);
        free(sql);
        return nil;
    }
    
    int result = SQLITE_OK;
    if (result == SQLITE_OK) {
        if ([key isEqualToString:@"dateText"]) {
            const char *valueText = [value UTF8String];
            result = sqlite3_bind_text(statement, 1, valueText, -1, SQLITE_OK);
        }
    }
    if (result != SQLITE_OK) {
        printf("update datesでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;
    }
    //  実行。
    if (stepStatement(database, statement) == NO) {
        printf("date設定失敗 (setDateValue)\n");
        finalizeStatement(database, statement);
        closeDB(database);
        free(sql);
        return nil;  //  失敗した。
    }
    if (finalizeStatement(database, statement) == NO) {
        printf("date設定失敗 (setDateValue)\n");
        closeDB(database);
        free(sql);
        return nil;
    }
    free(sql);
    
    if (closeDB(database) == NO) {
        printf("menu設定失敗 (setMenuValue)\n");
        return nil;
    }
    return value;
    
}


#pragma mark - fetchRecords


//recordsを全て取り出す
-(NSArray *)fetchRecords
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("record取り出し失敗 (SQLite, fetchRecords)");
        return nil;
    }
    sqlite3_stmt *statement; //成績取り出し用に使用するステートメント。
    //成績取り出し用ステートメント準備。日付順に取り出すようにする。
    if (prepareStatement(database, "select record_pk, records.date_pk, dateText, records.menu_pk, menuCategory, menuName, isTry, weight, repeatCount from (records inner join menus on records.menu_pk=menus.menu_pk) inner join dates on records.date_pk=dates.date_pk order by record_pk asc", &statement) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecords)\n");
        closeDB(database);
        return nil;
    }
    NSMutableArray *records = [[NSMutableArray alloc] init];
    while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
        //record_pkの取り出し。
        int record_pk = sqlite3_column_int(statement, 0);
        //date_pk
        int date_pk = sqlite3_column_int(statement, 1);
        //dateTextの取り出し
        NSString *dateText = nil;
        const unsigned char *str_1 = sqlite3_column_text(statement, 2);
        if (str_1 && strlen((const char *)str_1)) {
            dateText = [NSString stringWithUTF8String:(const char *)str_1];
        }
        //menu_pk
        int menu_pk = sqlite3_column_int(statement, 3);
        //menuCategory
        int menuCategory = sqlite3_column_int(statement, 4);
        //menuNameの取り出し
        NSString *menuName = nil;
        const unsigned char *str_2 = sqlite3_column_text(statement, 5);
        if (str_2 && strlen((const char *)str_2)) {
            menuName = [NSString stringWithUTF8String:(const char *)str_2];
        }
        //isTryの取り出し。
        int isTry = sqlite3_column_int(statement, 6);
        //weightの取り出し。
        double weight = sqlite3_column_int(statement, 7);
        //repeatCountの取り出し。
        int repeatCount = sqlite3_column_int(statement, 8);
        
        //record情報NSDictionaryを作成
        id record = recordWithPK(record_pk, date_pk, dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
        [records addObject:record];//追加
    }
    
    if (finalizeStatement(database, statement) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecords)\n");
        closeDB(database);
        return nil;
    }
    if (closeDB(database) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecords)\n");
        return nil;
    }
    
    NSLog(@"recordsの数は%d (SQLite, fetchRecords)",(int)[records count]);
    
    return records;
}


//dateTextと一致したrecordsを全て取り出す。
-(NSArray *)fetchRecordsFordateText:(NSString *)dateText
{
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)");
        return nil;
    }
    sqlite3_stmt *statement; //成績取り出し用に使用するステートメント。
    //成績取り出し用ステートメント準備。日付順に取り出すようにする。
    if (prepareStatement(database, "select record_pk, records.date_pk, dateText, records.menu_pk, menuCategory, menuName, isTry, weight, repeatCount from (records inner join menus on records.menu_pk=menus.menu_pk) inner join dates on records.date_pk=dates.date_pk where dateText=? order by dateText asc", &statement) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)\n");
        //closeDB(database);
        return nil;
    }
    
    const char *dateTextText = [dateText UTF8String];
    //?の数を(statement,*,:::)にはいれる
    int result = sqlite3_bind_text(statement, 1, dateTextText, -1, SQLITE_STATIC);
    if (result != SQLITE_OK) {
        printf("select * from recordsでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return nil;
    
    }
    NSMutableArray *records_dateText = [[NSMutableArray alloc] init];
    while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
        //record_pkの取り出し。
        int record_pk = sqlite3_column_int(statement, 0);
        //date_pk
        int date_pk = sqlite3_column_int(statement, 1);
        //menu_pk
        int menu_pk = sqlite3_column_int(statement, 3);
        //menuCategory
        int menuCategory = sqlite3_column_int(statement, 4);
        //menuNameの取り出し
        NSString *menuName = nil;
        const unsigned char *str_2 = sqlite3_column_text(statement, 5);
        if (str_2 && strlen((const char *)str_2)) {
            menuName = [NSString stringWithUTF8String:(const char *)str_2];
        }
        //isTryの取り出し。
        int isTry = sqlite3_column_int(statement, 6);
        //weightの取り出し。
        double weight = sqlite3_column_int(statement, 7);
        //repeatCountの取り出し。
        int repeatCount = sqlite3_column_int(statement, 8);
        
        //record情報NSDictionaryを作成
        id record = recordWithPK(record_pk, date_pk, dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
        [records_dateText addObject:record];//追加
    }
    
    if (finalizeStatement(database, statement) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)\n");
        closeDB(database);
        return nil;
    }
    if (closeDB(database) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)\n");
        return nil;
    }
    
    NSLog(@"records_dateTextの数は%d (SQLite, fetchRecordsFordateText)",(int)[records_dateText count]);
    
    return records_dateText;
    
}


//menu_pkと一致したrecordsを全て取り出す。
-(NSArray *)fetchRecordsForMenuPK:(int)menu_pk
{
    
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("record取り出し失敗 (SQLite, fetchRecordsForMenuPK)");
        return nil;
    }
    sqlite3_stmt *statement; //成績取り出し用に使用するステートメント。
    //成績取り出し用ステートメント準備。日付順に取り出すようにする。
    if (prepareStatement(database, "select record_pk, records.date_pk, dateText, records.menu_pk, menuCategory, menuName, isTry, weight, repeatCount from (records inner join menus on records.menu_pk=menus.menu_pk) inner join dates on records.date_pk=dates.date_pk where records.menu_pk=? order by dateText desc", &statement) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)\n");
        closeDB(database);
        return nil;
    }
    int result = sqlite3_bind_int(statement, 1, menu_pk);
    if (result != SQLITE_OK) {
        
        printf("select * from recordsでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        closeDB(database);
        return nil;
        
    }
    NSMutableArray *records = [[NSMutableArray alloc] init];
    while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
        //record_pkの取り出し。
        int record_pk = sqlite3_column_int(statement, 0);
        //date_pk
        int date_pk = sqlite3_column_int(statement, 1);
        //dateText
        const unsigned char* str = sqlite3_column_text(statement, 2);
        NSString* dateText = nil;
        if (str && strlen((const char*)str)) {
            dateText = [NSString stringWithUTF8String:(const char*)str];
        }
        //menuCategory
        int menuCategory = sqlite3_column_int(statement, 4);
        //menuNameの取り出し
        NSString *menuName = nil;
        const unsigned char *str_2 = sqlite3_column_text(statement, 5);
        if (str_2 && strlen((const char *)str_2)) {
            menuName = [NSString stringWithUTF8String:(const char *)str_2];
        }
        //isTryの取り出し。
        int isTry = sqlite3_column_int(statement, 6);
        //weightの取り出し。
        double weight = sqlite3_column_int(statement, 7);
        //repeatCountの取り出し。
        int repeatCount = sqlite3_column_int(statement, 8);
        
        //record情報NSDictionaryを作成
        id record = recordWithPK(record_pk, date_pk, dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
        [records addObject:record];//追加
    }
    
    if (finalizeStatement(database, statement) == NO) {
        printf("record取り出し失敗 (SQLite, SQLite, fetchRecordsForMenuPK)\n");
        closeDB(database);
        return nil;
    }
    if (closeDB(database) == NO) {
        printf("record取り出し失敗 (SQLite, SQLite, fetchRecordsForMenuPK)\n");
        return nil;
    }
    
    NSLog(@"recordsの数は%d (SQLite, SQLite, fetchRecordsForMenuPK)",(int)[records count]);
    
    return records;
    
}


//menusの数だけのmenu_pkで指定して配列をとってきて、配列に格納して返す。
-(NSMutableArray *)fetchRecordsSortingMenuPK:(NSMutableArray *)menus
{
    
    NSMutableArray *records_sorting_menu_pk = [[NSMutableArray alloc] init];
    
    for (int i=0;i<[menus count];i++) {
        
        NSMutableArray *records = [[NSMutableArray alloc] init];
        
        sqlite3 *database = openDB(_databaseFilePath);
        if (database == nil) { //データベースのオープンに失敗した。
            printf("record取り出し失敗 (SQLite, fetchRecordsSortingMenuPK)");
            return nil;
        }
        sqlite3_stmt *statement; //record取り出し用に使用するステートメント。
    
    
        //record取り出し用ステートメント準備。日付順に取り出すようにする。
        if (prepareStatement(database, "select record_pk, records.date_pk, dateText, records.menu_pk, menuCategory, menuName, isTry, weight, repeatCount from (records inner join menus on records.menu_pk=menus.menu_pk) inner join dates on records.date_pk=dates.date_pk where records.menu_pk=? order by dateText desc", &statement) == NO) {
            printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)\n");
            closeDB(database);
            return nil;
        }
        int result = sqlite3_bind_int(statement, 1, [menus[i][@"menu_pk"] intValue]);
        
        if (result != SQLITE_OK) {
            
            printf("select * from recordsでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
            finalizeStatement(database, statement);
            closeDB(database);
            return nil;
        }
        while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
            
            //record_pkの取り出し。
            int record_pk = sqlite3_column_int(statement, 0);
            
            //date_pk
            int date_pk = sqlite3_column_int(statement, 1);
            
            //dateText
            const unsigned char* str = sqlite3_column_text(statement, 2);
            NSString* dateText = nil;
            if (str && strlen((const char*)str)) {
                dateText = [NSString stringWithUTF8String:(const char*)str];
            }
            
            //menuCategory
            int menuCategory = sqlite3_column_int(statement, 4);
            
            //menuNameの取り出し
            NSString *menuName = nil;
            const unsigned char *str_2 = sqlite3_column_text(statement, 5);
            if (str_2 && strlen((const char *)str_2)) {
                menuName = [NSString stringWithUTF8String:(const char *)str_2];
            }
            
            //isTryの取り出し。
            int isTry = sqlite3_column_int(statement, 6);
            
            //weightの取り出し。
            double weight = sqlite3_column_int(statement, 7);
            
            //repeatCountの取り出し。
            int repeatCount = sqlite3_column_int(statement, 8);
        
            //record情報NSDictionaryを作成
            id record = recordWithPK(record_pk, date_pk, dateText, [menus[i][@"menu_pk"]intValue], menuCategory, menuName, isTry, weight, repeatCount);
            [records addObject:record];//追加
        
        }
        
        [records_sorting_menu_pk addObject:records];
    
        if (finalizeStatement(database, statement) == NO) {
            printf("record取り出し失敗 (SQLite, fetchRecordsSortingMenuPK)\n");
            closeDB(database);
            return nil;
        }
        if (closeDB(database) == NO) {
            printf("record取り出し失敗 (SQLite, fetchRecordsSortingMenuPK)\n");
            return nil;
        }
    }
    
    NSLog(@"records_sorting_menu_pkの数は%d (SQLite, fetchRecordsSortingMenuPK)",(int)[records_sorting_menu_pk count]);
    
    return records_sorting_menu_pk;
    
}


//datesの数だけのdate_pkで指定して配列をとってきて、配列に格納して返す。
-(NSMutableArray *)fetchRecordsSortingDatePK:(NSMutableArray *)dates
{
    NSMutableArray *records_sorting_date_pk = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[dates count]; i++) {
        
        NSMutableArray *records = [[NSMutableArray alloc] init];
        
        sqlite3 *database = openDB(_databaseFilePath);
        if (database == nil) { //データベースのオープンに失敗した。
            
            printf("record取り出し失敗 (SQLite, fetchRecordsSortingDatePK)");
            return nil;
        
        }
        sqlite3_stmt *statement; //成績取り出し用に使用するステートメント。
        //成績取り出し用ステートメント準備。日付順に取り出すようにする。
        if (prepareStatement(database, "select record_pk, records.date_pk, dateText, records.menu_pk, menuCategory, menuName, isTry, weight, repeatCount from (records inner join menus on records.menu_pk=menus.menu_pk) inner join dates on records.date_pk=dates.date_pk where records.date_pk=? order by records.menu_pk asc", &statement) == NO) {
            printf("record取り出し失敗 (SQLite, fetchRecordsFordateText)\n");
            //closeDB(database);
            return nil;
        }
        int result = sqlite3_bind_int(statement, 1, [dates[i][@"date_pk"] intValue]);
        if (result != SQLITE_OK) {
            
            printf("select * from recordsでの値の準備に失敗 (%d) '%s'.\n", result, sqlite3_errmsg(database));
            finalizeStatement(database, statement);
            closeDB(database);
            return nil;
        }
        while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
            
            //record_pkの取り出し。
            int record_pk = sqlite3_column_int(statement, 0);
            //dateText
            NSString *dateText = nil;
            const unsigned char *str_1 = sqlite3_column_text(statement, 2);
            if (str_1 && strlen((const char *)str_1)) {
                dateText = [NSString stringWithUTF8String:(const char *)str_1];
            }
        
            //menu_pk
            int menu_pk = sqlite3_column_int(statement, 3);
        
            //menuCategory
            int menuCategory = sqlite3_column_int(statement, 4);
           
            //menuNameの取り出し
            NSString *menuName = nil;
            const unsigned char *str_2 = sqlite3_column_text(statement, 5);
            if (str_2 && strlen((const char *)str_2)) {
                menuName = [NSString stringWithUTF8String:(const char *)str_2];
            }
            //isTryの取り出し。
            int isTry = sqlite3_column_int(statement, 6);
            
            //weightの取り出し。
            double weight = sqlite3_column_int(statement, 7);
            
            //repeatCountの取り出し。
            int repeatCount = sqlite3_column_int(statement, 8);
        
            //record情報NSDictionaryを作成
            id record = recordWithPK(record_pk, [dates[i][@"date_pk"] intValue], dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
            [records addObject:record];//追加
        }
        
        [records_sorting_date_pk addObject:records];
        
        if (finalizeStatement(database, statement) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecordsSortingDatePK)\n");
        closeDB(database);
        return nil;
        }
        if (closeDB(database) == NO) {
        printf("record取り出し失敗 (SQLite, fetchRecordsSortingDatePK)\n");
        return nil;
        }
    
    }
    
    NSLog(@"records_sorting_date_pkの数は%d (SQLite, fetchRecordsSortingDatePK)",(int)[records_sorting_date_pk count]);
    
    return records_sorting_date_pk;
    
}


#pragma mark - fetchHistorys


//historysを全て取り出す
-(NSArray *)fetchHistorys
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("record取り出し失敗 (SQLite, fetchHistorys)");
        return nil;
    }
    sqlite3_stmt *statement; //成績取り出し用に使用するステートメント。
    //成績取り出し用ステートメント準備。日付順に取り出すようにする。
    if (prepareStatement(database, "select history_pk, historys.date_pk, dateText, historys.menu_pk, menuCategory, menuName, isTry, weight, repeatCount from (historys inner join menus on historys.menu_pk=menus.menu_pk) inner join dates on historys.date_pk=dates.date_pk order by dateText asc", &statement) == NO) {
        printf("history取り出し失敗 (SQLite, fetchHistorys)\n");
        closeDB(database);
        return nil;
    }
    NSMutableArray *historys = [[NSMutableArray alloc] init];
    while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
        //record_pkの取り出し。
        int history_pk = sqlite3_column_int(statement, 0);
        //date_pk
        int date_pk = sqlite3_column_int(statement, 1);
        //dateTextの取り出し
        NSString *dateText = nil;
        const unsigned char *str_1 = sqlite3_column_text(statement, 2);
        if (str_1 && strlen((const char *)str_1)) {
            dateText = [NSString stringWithUTF8String:(const char *)str_1];
        }
        //menu_pk
        int menu_pk = sqlite3_column_int(statement, 3);
        //menuCategory
        int menuCategory = sqlite3_column_int(statement, 4);
        //menuNameの取り出し
        NSString *menuName = nil;
        const unsigned char *str_2 = sqlite3_column_text(statement, 5);
        if (str_2 && strlen((const char *)str_2)) {
            menuName = [NSString stringWithUTF8String:(const char *)str_2];
        }
        //isTryの取り出し。
        int isTry = sqlite3_column_int(statement, 6);
        //weightの取り出し。
        double weight = sqlite3_column_int(statement, 7);
        //repeatCountの取り出し。
        int repeatCount = sqlite3_column_int(statement, 8);
        
        //record情報NSDictionaryを作成
        id history = historyWithPK(history_pk, date_pk, dateText, menu_pk, menuCategory, menuName, isTry, weight, repeatCount);
        [historys addObject:history];//追加
    }
    
    if (finalizeStatement(database, statement) == NO) {
        printf("history取り出し失敗 (SQLite, fetchHistorys)\n");
        closeDB(database);
        return nil;
    }
    if (closeDB(database) == NO) {
        printf("history取り出し失敗 (SQLite, fetchHistorys)\n");
        return nil;
    }
    
    NSLog(@"historysの数は%d (SQLite, fetchHistorys)",(int)[historys count]);
    
    return historys;
}


#pragma mark - fetchMenu


//menusを全て取り出す
-(NSArray *)fetchMenus
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("menu取り出し失敗 (SQLite, fetchMenus)\n");
        return nil;
    }
    sqlite3_stmt *statement;
    //menu取り出し用ステートメント準備。
    if (prepareStatement(database, "select menu_pk, menuCategory, menuName from menus", &statement) == NO) {
        printf("menu取り出し失敗 (SQLite, fetchMenus)\n");
        closeDB(database);
        
        return nil;
    }
    NSMutableArray *menus = [[NSMutableArray alloc]init];
    
    //sqlite3_stepの返り値はSQLITE_OKではありません
    while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
        //menu_pk(PK)取り出し。
        int menu_pk = sqlite3_column_int(statement, 0);
        if (menu_pk == 0) {
            //無名用なので、リストには登録しない。
            continue;
        }
        //menuCategory取り出し。
        int menuCategory = sqlite3_column_int(statement, 1);
        //menuName取り出し
        const unsigned char *str = sqlite3_column_text(statement, 2);
        NSString *menuName = nil;
        if (str && strlen((const char*)str)) {
            menuName = [NSString stringWithUTF8String:(const char*)str];
        }
        
        //menu情報NSDictionaryを作成
        id menu = menuWithPK(menu_pk, menuCategory, menuName);
        
        [menus addObject:menu];//追加
        
    }
    
    //厳密にはsqlite3_stepの戻り値がSQLITE_OKかも？？？？？
    
    if (finalizeStatement(database, statement) == NO) {
        printf("menu取り出し失敗 (SQLite, fetchMenus)\n");
        closeDB(database);
        return nil;
    }
    if (closeDB(database) == NO) {
        printf("menu取り出し失敗 (SQLite, fetchMenus)\n");
        return nil;
    }
    
    NSLog(@"menusの数は%d (SQLite, fetchMenus)",(int)[menus count]);
    
    return menus;
}


#pragma mark - fetchDates


//datesを全て取り出す
-(NSArray *)fetchDates
{
    sqlite3 *database = openDB(_databaseFilePath);
    if (database == nil) { //データベースのオープンに失敗した。
        printf("date取り出し失敗 (SQLite, fetchDates)\n");
        return nil;
    }
    sqlite3_stmt *statement;
    //menu取り出し用ステートメント準備。
    if (prepareStatement(database, "select date_pk, dateText from dates", &statement) == NO) {
        printf("date取り出し失敗 (SQLite, fetchDates)\n");
        closeDB(database);
        
        return nil;
    }
    NSMutableArray *dates = [[NSMutableArray alloc]init];
    
    //sqlite3_stepの返り値はSQLITE_OKではありません
    while (sqlite3_step(statement) == SQLITE_ROW) { //データがある。
        //menu_pk(PK)取り出し。
        int date_pk = sqlite3_column_int(statement, 0);
        if (date_pk == 0) {
            //無名用なので、リストには登録しない。
            continue;
        }
        //menuName取り出し
        const unsigned char *str = sqlite3_column_text(statement, 1);
        NSString *dateText = nil;
        if (str && strlen((const char*)str)) {
            dateText = [NSString stringWithUTF8String:(const char*)str];
        }
        
        //menu情報NSDictionaryを作成
        id date = dateWithPK(date_pk, dateText);
        
        [dates addObject:date];//追加
        
    }
    
    //厳密にはsqlite3_stepの戻り値がSQLITE_OKかも？？？？？
    
    if (finalizeStatement(database, statement) == NO) {
        printf("date取り出し失敗 (SQLite, fetchDates)\n");
        closeDB(database);
        return nil;
    }
    if (closeDB(database) == NO) {
        printf("date取り出し失敗 (SQLite, fetchDates)\n");
        return nil;
    }
    
    NSLog(@"datesの数は%d (SQLite, fetchDates)",(int)[dates count]);
    
    return dates;
}


#pragma mark - getter


//menuの変則ゲッタ
-(id)menu:(sqlite3 *)database menu_pk:(int)menu_pk
{
    
    sqlite3_stmt *statement;
    //recordsテーブルのレコード再取り出し用ステートメント準備
    if (prepareStatement(database, "select menuCategory, menuName from menus where menu_pk=?", &statement) == NO) {
        return nil; //失敗した。
    }
    int result = sqlite3_bind_int(statement, 1, menu_pk);
    if (result != SQLITE_OK) {
        printf("select from menusでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return nil;//失敗した
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return nil; //失敗した
    }
    //menuName取り出し
    NSString *menuName = nil;
    const unsigned char *str = sqlite3_column_text(statement, 2);
    if (str && strlen((const char *)str)) {
        menuName = [NSString stringWithUTF8String:(const char *)str];
    }
    //menuCategory取り出し
    int menuCategory = sqlite3_column_int(statement, 1);
    if (finalizeStatement(database, statement) == NO) {
        return nil; //失敗した
    }
    return @{@"menuCategory":@(menuCategory), @"menuName":menuName};
}


//dateの変則ゲッタ(dateText)を取得
-(id)date:(sqlite3 *)database date_pk:(int)date_pk
{
    
    sqlite3_stmt *statement;
    //recordsテーブルのレコード再取り出し用ステートメント準備
    if (prepareStatement(database, "select dateText from dates where date_pk=?", &statement) == NO) {
        return nil; //失敗した。
    }
    int result = sqlite3_bind_int(statement, 1, date_pk);
    if (result != SQLITE_OK) {
        printf("select from datesでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return nil;//失敗した
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return nil; //失敗した
    }
    //dateText取り出し
    NSString *dateText = nil;
    const unsigned char *str = sqlite3_column_text(statement, 1);
    if (str && strlen((const char *)str)) {
        dateText = [NSString stringWithUTF8String:(const char *)str];
    }
    if (finalizeStatement(database, statement) == NO) {
        return nil; //失敗した
    }
    return @{@"dateText":dateText};
}


//dateの変則ゲッタ(date_pk)を取得
-(long long)date:(sqlite3 *)database dateText:(NSString *)dateText
{
    sqlite3_stmt *statement;
    //recordsテーブルのレコード再取り出し用ステートメント準備
    if (prepareStatement(database, "select date_pk from dates where dateText=?", &statement) == NO) {
        return 0; //失敗した。
    }
    const char *valueText = [dateText UTF8String];
    int result = sqlite3_bind_text(statement, 1, valueText, -1, SQLITE_STATIC);
    if (result != SQLITE_OK) {
        printf("select from datesでの値の準備に失敗 (%d) '%s' .\n", result, sqlite3_errmsg(database));
        finalizeStatement(database, statement);
        return 0;//失敗した
    }
    //実行
    if (stepStatement(database, statement) == NO) {
        finalizeStatement(database, statement);
        return 0; //失敗した
    }
    //date_pk取り出し
    long long date_pk = 0;
    date_pk = sqlite3_column_int64(statement, 0);
    if (finalizeStatement(database, statement) == NO) {
        return 0; //失敗した
    }
    return date_pk;
}


@end
