//
//  TutorialLayer.m
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//

// Import the interfaces
#import "TutorialScene.h"
#import "GameHUD.h"

#import "DataModel.h"

// Tutorial implementation
@implementation Tutorial

@synthesize tileMap = _tileMap;
@synthesize background = _background;

@synthesize aStarPF = _aStarPF;
@synthesize currentLevel = _currentLevel;


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Tutorial *layer = [Tutorial node];
	
	// add layer as a child to scene
	[scene addChild: layer z:1];
	
	GameHUD * myGameHUD = [GameHUD sharedHUD];
	[scene addChild:myGameHUD z:2];
	
	DataModel *m = [DataModel getModel];
	m._gameLayer = layer;
	m._gameHUDLayer = myGameHUD;
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init {
    if((self = [super init])) {				
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"GemTDMap04.tmx"];
        self.background = [_tileMap layerNamed:@"CollideLayer"];
		self.background.anchorPoint = ccp(0, 0);
		[self addChild:_tileMap z:0];
        
        self.aStarPF = [[AStarPathFinder alloc] initWithTileMap:self.tileMap collideLayer:@"CollideLayer"];
        self.aStarPF.considerDiagonalMovement = NO;
        //[self.aStarPF highlightPathFrom:ccp(0,3) to:ccp(19,12)];
        //[self addChild:self.aStarPF z:1];
        
		[self addWaypoint];
		[self addWaves];
		
		// Call game logic about every second
        [self schedule:@selector(update:)];
		[self schedule:@selector(gameLogic:) interval:2.0];	

		
		self.currentLevel = 0;
		self.position = ccp(0, 0);
		
		gameHUD = [GameHUD sharedHUD];
		
    }
    return self;
}

-(void)addWaves {
	DataModel *m = [DataModel getModel];
	
	Wave *wave = nil;
    for (int i=0; i<m._wavesData.count; i++) {
        wave = [[Wave alloc] initWithCreep:[FastRedCreep creep:i] SpawnRate:1.0 TotalCreeps:10];
        if ((i-1) % 4 == 0) {
            wave = [[Wave alloc] initWithCreep:[StrongGreenCreep creep:i] SpawnRate:1.0 TotalCreeps:10];
        }
        [m._waves addObject:wave];
        CCLOG(@"m._waves: %@", m._waves);
        wave = nil;
    }
    /*
	wave = [[Wave alloc] initWithCreep:[FastRedCreep creep:self.currentLevel] SpawnRate:3.0 TotalCreeps:5];
	[m._waves addObject:wave];
	wave = nil;
	wave = [[Wave alloc] initWithCreep:[StrongGreenCreep creep:self.currentLevel] SpawnRate:1.0 TotalCreeps:5];
	[m._waves addObject:wave];
	wave = nil;	
    for (id wave in m._waves) {
        CCLOG(@"wave: %@", wave);
    }
    */
}

- (Wave *)getCurrentWave{
	
	DataModel *m = [DataModel getModel];	
	Wave * wave = (Wave *) [m._waves objectAtIndex:self.currentLevel];
	//NSMutableDictionary *dict = [m._wavesData objectAtIndex:self.currentLevel];
	return wave;
}

- (Wave *)getNextWave{
	
	DataModel *m = [DataModel getModel];
	
	self.currentLevel++;
	
	if (self.currentLevel >= m._wavesData.count)
		self.currentLevel = 0;
	
	 Wave * wave = (Wave *) [m._waves objectAtIndex:self.currentLevel];
	 
	 return wave;
}

-(void)addWaypoint {
	DataModel *m = [DataModel getModel];
	
	CCTMXObjectGroup *objects = [self.tileMap objectGroupNamed:@"Objects"];
	WayPoint *wp = nil;
	
	int wayPointCounter = 0;
	NSMutableDictionary *wayPoint;
	while ((wayPoint = [objects objectNamed:[NSString stringWithFormat:@"waypoint%d", wayPointCounter]])) {
		int x = [[wayPoint valueForKey:@"x"] intValue];
		int y = [[wayPoint valueForKey:@"y"] intValue];
		
		wp = [WayPoint node];
		wp.position = ccp(x, y);
		[m._waypoints addObject:wp];
		wayPointCounter++;
	}
	
	NSAssert([m._waypoints count] > 0, @"Waypoint objects missing");
	wp = nil;
    CCLOG(@"m._waypoints: %@", m._waypoints);
}

- (CGPoint) tileCoordForPosition:(CGPoint) position 
{
	int x = position.x / self.tileMap.tileSize.width;
	int y = ((self.tileMap.mapSize.height * self.tileMap.tileSize.height) - position.y) / self.tileMap.tileSize.height;
	
	return ccp(x,y);
}

- (BOOL) canBuildOnTilePosition:(CGPoint) pos 
{
	CGPoint towerLoc = [self tileCoordForPosition: pos];
	
	int tileGid = [self.background tileGIDAt:towerLoc];
	NSDictionary *props = [self.tileMap propertiesForGID:tileGid];
	NSString *type = [props valueForKey:@"buildable"];
	
	if([type isEqualToString: @"1"]) {
		return YES;
	}
	
	return NO;
}

-(void)addTower: (CGPoint)pos {
	DataModel *m = [DataModel getModel];
	
	Tower *target = nil;
	
	CGPoint towerLoc = [self tileCoordForPosition: pos];
	
	int tileGid = [self.background tileGIDAt:towerLoc];
	NSDictionary *props = [self.tileMap propertiesForGID:tileGid];
	NSString *type = [props valueForKey:@"buildable"];
	
	
	NSLog(@"Buildable: %@", type);
	if([type isEqualToString: @"1"]) {
		target = [MachineGunTower tower];
		target.position = ccp((towerLoc.x * 32) + 16, self.tileMap.contentSize.height - (towerLoc.y * 32) - 16);
		[self addChild:target z:1];
		
		target.tag = 1;
		[m._towers addObject:target];
		
	} else {
		NSLog(@"Tile Not Buildable");
	}
	
}

-(void)addTarget {
    
	DataModel *m = [DataModel getModel];
	Wave * wave = [self getCurrentWave];
	if (wave.totalCreeps <= 0) {
		//return; 
        wave = [self getNextWave];
	}
	
	wave.totalCreeps--;
    
	
    Creep *target = nil;
    //target = [FastRedCreep creep:self.currentLevel];
    
    
    
    if ((self.currentLevel % 2) == 0) {
        target = [FastRedCreep creep:self.currentLevel];
    } else {
        target = [StrongGreenCreep creep:self.currentLevel];
    }
        
    CCLOG(@"current Level: %d", self.currentLevel);
    
    /*
    self.currentLevel++;
    CCLOG(@"current Level: %d", self.currentLevel);
    target = [FastRedCreep creep:self.currentLevel];
    if (self.currentLevel >= m._wavesData.count) {
        self.currentLevel = 0;
        
    }
     */
	
	WayPoint *waypoint = [target getCurrentWaypoint];
	target.position = waypoint.position;	
	waypoint = [target getNextWaypoint];
	
	
	//id actionMove = [CCMoveTo actionWithDuration:target.speed position:waypoint.position];
	//id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	//[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    //CCLOG(@"target position: (%2.4f, %2.4f)", target.position.x, target.position.y);
    //CCLOG(@"waypoint position: (%2.4f, %2.4f)", waypoint.position.x, waypoint.position.y);
	
    CGPoint curPoint = [self tileCoordForPosition:ccp(target.position.x, target.position.y)];
    CGPoint nextPoint = [self tileCoordForPosition:ccp(waypoint.position.x, waypoint.position.y)];
    [self.aStarPF highlightPathFrom:curPoint to:nextPoint];
    
	id action=[self.aStarPF moveTarget:target from: curPoint to:nextPoint atSpeed:target.speed];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[target runAction:[CCSequence actionOne:action two:actionMoveDone]];
	
    //[self addChild:self.aStarPF z:1];
	//[self FollowPath:target];
    
    
    
//    WayPoint *waypoint = [target getCurrentWaypoint];
//    while (waypoint != nil) {
//        //WayPoint *wp = [target getCurrentWaypoint];
//       
//        target.position = waypoint.position;
//        CGPoint curPoint = [self tileCoordForPosition:ccp(target.position.x, target.position.y)];
//        CCLOG(@"target current waypoint: (%f, %f)", curPoint.x, curPoint.y);
//        
//        waypoint = [target getNextWaypoint];
//        CGPoint nextPoint = [self tileCoordForPosition:ccp(waypoint.position.x, waypoint.position.y)];
//        CCLOG(@"target next waypoint: (%f, %f)", nextPoint.x, nextPoint.y);
//        
//        
//        [self.aStarPF highlightPathFrom:curPoint to:nextPoint];
//        //[self.aStarPF moveSprite:target from: curPoint to:nextPoint atSpeed:target.speed];
//        [self addChild:self.aStarPF z:1];
//        
//    }
    
    
    // Add to targets array
    [self addChild:target z:1 tag:1];
	[m._targets addObject:target];
	
}

-(void)FollowPath:(id)sender {
    
	Creep *creep = (Creep *)sender;
	CGPoint curPoint = [self tileCoordForPosition:ccp(creep.position.x, creep.position.y)];
    CCLOG(@"curPoint: (%2.4f, %2.4f)", curPoint.x, curPoint.y);
	
    WayPoint * waypoint = [creep getNextWaypoint];

	/*
    id actionMove = [CCMoveTo actionWithDuration:creep.speed position:waypoint.position];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[creep stopAllActions];
    [creep runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
     */
    //CGPoint curPoint = [self tileCoordForPosition:ccp(creep.position.x, creep.position.y)];
    CGPoint nextPoint = [self tileCoordForPosition:ccp(waypoint.position.x, waypoint.position.y)];
    //[self.aStarPF highlightPathFrom:curPoint to:nextPoint];
    id action=[self.aStarPF moveTarget:creep from: curPoint to:nextPoint atSpeed:creep.speed];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[creep runAction:[CCSequence actionOne:action two:actionMoveDone]];


}

-(void)gameLogic:(ccTime)dt {
	
	//DataModel *m = [DataModel getModel];
	Wave * wave = [self getCurrentWave];
	static double lastTimeTargetAdded = 0;
    double now = [[NSDate date] timeIntervalSince1970];
   if(lastTimeTargetAdded == 0 || now - lastTimeTargetAdded >= wave.spawnRate) {
        [self addTarget];
        lastTimeTargetAdded = now;
    }
	
}

- (void)update:(ccTime)dt {
    
	DataModel *m = [DataModel getModel];
	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];

	for (Projectile *projectile in m._projectiles) {
		
		CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2), 
										   projectile.position.y - (projectile.contentSize.height/2), 
										   projectile.contentSize.width, 
										   projectile.contentSize.height);
        
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		
		for (CCSprite *target in m._targets) {
			CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), 
										   target.position.y - (target.contentSize.height/2), 
										   target.contentSize.width, 
										   target.contentSize.height);
            
			if (CGRectIntersectsRect(projectileRect, targetRect)) {
                
				[projectilesToDelete addObject:projectile];
				
                Creep *creep = (Creep *)target;
                creep.hitPoint--;
				
                if (creep.hitPoint <= 0) {
                    [targetsToDelete addObject:target];
                }
                break;
                
			}						
		}
		
		for (CCSprite *target in targetsToDelete) {
			[m._targets removeObject:target];
			[self removeChild:target cleanup:YES];									
		}
		
		[targetsToDelete release];
	}
	
	for (CCSprite *projectile in projectilesToDelete) {
		[m._projectiles removeObject:projectile];
		[self removeChild:projectile cleanup:YES];
	}
	[projectilesToDelete release];
}


- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -_tileMap.contentSize.width+winSize.width); 
    retval.y = MIN(0, retval.y);
    retval.y = MAX(-_tileMap.contentSize.height+winSize.height, retval.y); 
    return retval;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {    
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];                
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {    
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];  
        [recognizer setTranslation:CGPointZero inView:recognizer.view];    
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
               
		float scrollDuration = 0.2;
		CGPoint velocity = [recognizer velocityInView:recognizer.view];
		CGPoint newPos = ccpAdd(self.position, ccpMult(ccp(velocity.x, velocity.y * -1), scrollDuration));
		newPos = [self boundLayerPos:newPos];

		[self stopAllActions];
		CCMoveTo *moveTo = [CCMoveTo actionWithDuration:scrollDuration position:newPos];            
		[self runAction:[CCEaseOut actionWithAction:moveTo rate:1]];            
        
    }        
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_tileMap release];
    self.tileMap = nil;
    [_background release];
    self.background = nil;
    [_aStarPF release];
    self.aStarPF = nil;

    
	[super dealloc];
}

@end
