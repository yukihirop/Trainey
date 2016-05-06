//
//  MenusManager.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/24.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "MenusManager.h"

@implementation MenusManager


@synthesize menus = _menus;


//このクラスのインスタンスはシングルトン
+(MenusManager *)sharedManager
{
    static MenusManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}


//イニシャライザ
-(id)init
{
    self = [super init];
    if(self){
        //Initializa Code
        _menus = [[NSMutableArray alloc] init];
    }
    return self;
}


//menusを読み込む。
-(void)loadMenus
{
    NSLog(@"呼ばれました (MenusManager, loadMenus)");
    _menus = [[[SQLite sharedSQLite] fetchMenus] mutableCopy];
    NSLog(@"menusの数は%d (Menus, loadMenus)",(int)[_menus count]);
}


//menuCategory、menuNameをmenuに追加する
-(id)addMenu:(int)menuCategory menuName:(NSString *)menuName
{
    //データベースに記録。記録したmenuはNSDictionaryにまとめて戻される。
    NSDictionary *menu = [[SQLite sharedSQLite] addMenu:menuCategory menuName:menuName];
    [_menus insertObject:menu atIndex:[_menus count]];
    NSLog(@"menusの数は%d (Menus, addMenu)",(int)[_menus count]);
    return menu;
}


//menuを再度読み込む
-(void)reloadMenu
{
    _menus = [[[SQLite sharedSQLite] fetchMenus] mutableCopy];
}


//menuのkeyで指定される値を設定する。失敗したらnilを戻す。
-(id)setMenuValue:(id)value forKey:(id)key menu:(id)menu
{
    int menu_pk = [menu[@"menu_pk"] intValue];
    id result = [[SQLite sharedSQLite]setMenuValue:value forKey:key menu_pk:menu_pk];
    if (result) {
        NSMutableDictionary *dic = [menu mutableCopy];
        if ([key isEqualToString:@"menu_pk"]) {
            if ([value intValue] != 0) {
                dic[@"menuCategory"] = result[@"menuCategory"];
                dic[@"menuName"] = result[@"menuName"];
            }else{
                [dic removeObjectForKey:@"menuName"];
                dic[@"menuCategory"]=@(-1);
            }
        }
        dic[key] = value;
        id newMenu = [dic copy];
        [_menus replaceObjectAtIndex:[_menus indexOfObject:menu] withObject:newMenu];
        return newMenu;
    }
    return nil;
}


//menuを削除する。失敗したらNOを戻す。
-(BOOL)deleteMenu:(id)menu
{
    int menu_pk = [menu[@"menu_pk"] intValue];
    if ([[SQLite sharedSQLite] deleteMenuForPK:menu_pk]) {
        [_menus removeObject:menu];
        return YES;
    }
    return NO;
}


@end
