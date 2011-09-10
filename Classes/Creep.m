//
//  Creep.m
//  Cocos2D Build a Tower Defense Game
//
//  Created by iPhoneGameTutorials on 4/4/11.
//  Copyright 2011 iPhoneGameTutorial.com All rights reserved.
//

#import "Creep.h"

@implementation Creep

@synthesize hitPoint = _HP;
@synthesize speed = _speed;
@synthesize armor = _armor;
@synthesize livesCost = _livesCost;
@synthesize bonus = _bonus;

@synthesize curWaypoint = _curWaypoint;
@synthesize curLevel = _curLevel;

- (id) copyWithZone:(NSZone *)zone {
	Creep *copy = [[[self class] allocWithZone:zone] initWithCreep:self];
	return copy;
}

- (Creep *) initWithCreep:(Creep *) copyFrom {
    if ((self = [CCSprite spriteWithFile:@"Enemy1.png"])) {
        self.hitPoint = copyFrom.hitPoint;
        self.speed = copyFrom.speed;
        self.armor = copyFrom.armor;
        self.livesCost = copyFrom.livesCost;
        self.bonus = copyFrom.bonus;
        self.curWaypoint = copyFrom.curWaypoint;
	}
	[self retain];
	return self;
}

- (WayPoint *)getCurrentWaypoint{
	
	DataModel *m = [DataModel getModel];
	
	WayPoint *waypoint = (WayPoint *) [m._waypoints objectAtIndex:self.curWaypoint];
	
	return waypoint;
}

- (WayPoint *)getNextWaypoint{
	
	DataModel *m = [DataModel getModel];
	int lastWaypoint = m._waypoints.count;

	self.curWaypoint++;
	
	if (self.curWaypoint > lastWaypoint)
		self.curWaypoint = lastWaypoint - 1;
        //self.curWaypoint = 0;
	
	WayPoint *waypoint = (WayPoint *) [m._waypoints objectAtIndex:self.curWaypoint];
	
	return waypoint;
}

-(void)creepLogic:(ccTime)dt {
	
	
	// Rotate creep to face next waypoint
	WayPoint *waypoint = [self getCurrentWaypoint ];
	
	CGPoint waypointVector = ccpSub(waypoint.position, self.position);
	CGFloat waypointAngle = ccpToAngle(waypointVector);
	CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * waypointAngle);
	
	float rotateSpeed = 0.5 / M_PI; // 1/2 second to roate 180 degrees
	float rotateDuration = fabs(waypointAngle * rotateSpeed);    
	
	[self runAction:[CCSequence actions:
					 [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
					 nil]];		
}

@end

@implementation FastRedCreep

+ (id)creep: (int)level {
    DataModel *m = [DataModel getModel];
    FastRedCreep *creep = nil;
    //[m._wavesData objectForKey:_curLevel];
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    //CCLOG(@"m._wavesData-----%@", m._wavesData);
    
    creep = [[[super alloc] initWithFile:@"Enemy1.png"] autorelease];
    //for (int curLevel =0; curLevel < m._wavesData.count; curLevel++) {
    dic = [m._wavesData objectAtIndex:level];
        //CCLOG(@"dic-----%@", dic);
        CCLOG(@"wavesData---level: %d", level);
        
        if (creep != nil) {
            
            creep.hitPoint = [[dic objectForKey:HITPOINTS_KEY] intValue];
            creep.speed = [[dic objectForKey:SPEED_KEY] floatValue];;
            creep.armor = [[dic objectForKey:ARMOR_KEY] intValue];
            creep.curWaypoint = 0;
           
        }
   // }

	
	[creep schedule:@selector(creepLogic:) interval:0.2];
	
    return creep;
}

@end

@implementation StrongGreenCreep

+ (id)creep: (int)level{
    
    StrongGreenCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"Enemy2.png"] autorelease])) {
        creep.hitPoint = 20;
        creep.speed = 3.0f;
		creep.curWaypoint = 0;
    }
	
	[creep schedule:@selector(creepLogic:) interval:0.2];
    
	return creep;
}

@end