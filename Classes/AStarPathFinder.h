//
//  AStarPathFinder.h
//  GemTD0
//
//  Created by wu xiaokui on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define ASTAR_COLLIDE_PROP_NAME @"COLLIDE"
#define ASTAR_COLLIDE_PROP_VALUE @"1"

@class AStarNode;
@class AStarPathFinder;

//A structure for storing a A* node

@interface AStarNode : NSObject {
    int x;
    int y;
@public
    AStarNode *parent;
    CGPoint point;
    int F;
    int G;
    int H;
}
//create a new autoreleased node at the given tile position
+(id)nodeAtPoint:(CGPoint)pos;
//initialize the node at the given tile position
-(id)initAtPoint:(CGPoint)pos;
//returns the calculated cost of the node
-(int)cost;

@end

@interface AStarPathFinder : CCLayer {
    CCTMXTiledMap *tileMap;
    CCTMXLayer *collideLayer;
    
    NSMutableSet *openNodes;
    NSMutableSet *closeNodes;
    
    NSString *collideKey;
    NSString *collideValue;
    
    BOOL considerDiagonalMovement;
    float pathFillColor[4];
    CGImageRef pathHighlightImage;
    
}
//the name of the tile property which stores the collision boolean.
@property (copy, nonatomic) NSString *collideKey;
//the value of the tile property which indicates a collide tile.
@property (copy, nonatomic) NSString *collideValue;
//if True the path may use diagonal movement.
@property (assign, nonatomic) BOOL considerDiagonalMovement;

/*
 *initialize the object with a CCTMXTiledMap and the name of the layer
 *which contains your collision tiles
 *
 *the detaulf collide property name is COLLIDE,which is checked for the 
 *default value of 1, use setCollideKey and setCollideValue to customize.
 *
*/

-(id)initWithTileMap:(CCTMXTiledMap *)aTileMap collideLayer:(NSString *)name;

//return an array of tiles which make up the shortest path between src and dst.
-(NSArray *)getPath:(CGPoint)src to:(CGPoint)dst;

//highlight the calculated A* path.
-(void)highlightPathFrom:(CGPoint)src to:(CGPoint)dst;

//clear the highlighted path if any
-(void)clearHighlightPath;

//move given sprite along the calcualted A* path
-(void)moveSprite:(CCSprite *)sprite from:(CGPoint)src to:(CGPoint)dst atSpeed:(float)speed;
-(id)moveTarget:(CCSprite *)sprite from:(CGPoint)src to:(CGPoint)dst atSpeed:(float)speed;

//set the fill color for the path highlight
-(void)setPathRGBAFillColor:(float)red g:(float)green b:(float)blue a:(float)alpha;


@end
