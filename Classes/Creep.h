//
//  Creep.h
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//

#import "cocos2d.h"

#import "DataModel.h"
#import "WayPoint.h"

#define HITPOINTS_KEY  @"Hitpoints"
#define SPEED_KEY  @"Speed"
#define ARMOR_KEY  @"Armor"


@interface Creep : CCSprite <NSCopying> {
    int _HP;
	float _speed;
    int _armor;
    int _livesCost;
    int _bonus;
	
	int _curWaypoint;
    int _curLevel;
}

@property (nonatomic, assign) int hitPoint;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) int armor;
@property (nonatomic, assign) int livesCost;
@property (nonatomic, assign) int bonus;

@property (nonatomic, assign) int curWaypoint;
@property (nonatomic, assign) int curLevel;

- (Creep *) initWithCreep:(Creep *) copyFrom; 
- (WayPoint *)getCurrentWaypoint;
- (WayPoint *)getNextWaypoint;


@end

@interface FastRedCreep : Creep {
}
+(id)creep:(int)level;
@end

@interface StrongGreenCreep : Creep {
}
+(id)creep: (int)level;
@end