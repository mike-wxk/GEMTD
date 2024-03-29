//
//  TutorialLayer.h
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#import "Creep.h"
#import "Projectile.h"
#import "Tower.h"
#import "WayPoint.h"
#import "Wave.h"
#import "AStarPathFinder.h"

#import "GameHUD.h"

// Tutorial Layer
@interface Tutorial : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
	AStarPathFinder *_aStarPF;
	
	int _currentLevel;
    //NSMutableDictionary *_levels;
	
	GameHUD * gameHUD;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;

@property (nonatomic, retain) AStarPathFinder *aStarPF;
@property (nonatomic, assign) int currentLevel;

+ (id) scene;
- (void)addWaves;
- (void)addWaypoint;
- (void)addTower: (CGPoint)pos;
- (BOOL) canBuildOnTilePosition:(CGPoint) pos;

@end
