//
//  MenusManager.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/24.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menus.h"

@interface MenusManager : NSObject


@property (nonatomic, strong) NSMutableArray *menus;


//このクラスのインスタンスはシングルトン
+(MenusManager *)sharedManager;

//**menusを読み込むメソッド*/
-(void)loadMenus;

//menuCategory、menuNameをmenuに追加する
-(id)addMenu:(int)menuCategory menuName:(NSString *)menuName;

//menusを再度読み込む
-(void)reloadMenu;

//menuのkeyで指定される値を設定する。失敗したらnilを戻す。
-(id)setMenuValue:(id)value forKey:(id)key menu:(id)menu;

//menuを削除する。失敗したらNOを戻す。
-(BOOL)deleteMenu:(id)menu;


@end
