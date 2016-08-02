//
//  GameScene.m
//  demo-v1
//
//  Created by Bonnie on 7/20/15.
//

#import "GameScene.h"

@implementation GameScene


// ----------------------------------------------------------------------------
- (id) initWithSize:(CGSize)size  {
    if (self = [super initWithSize:size]) {
        // enable detection of touch
        self.userInteractionEnabled = YES;
       
        // load map into layer
        self.map = [JSTileMap mapNamed:@"level1.tmx"];
        [self addChild:self.map];
        
        // load background color into layer
        // light sky blue color RGB(135, 206, 250)
        // divide colors by 255 to get skcolor value
        self.backgroundColor = [SKColor colorWithRed:.52 green:.80 blue:.98 alpha:1.0];

        // walls and hazards
        self.walls = [self.map layerNamed:@"walls"];
        self.hazards = [self.map layerNamed:@"hazards"];

        // checkpoint
        self.checkpoints = [self.map layerNamed:@"checkpoints"];
        
        // load player
        self.player =[[Player alloc] initWithImageNamed:@"cup-char-1 3"];
        
        // load and set position of player relative to the map
        self.player.position = CGPointMake(100, 90);
        self.player.zPosition = 15;
        
        // player is now added to map
        [self.map addChild:self.player];
        
        // score status bar
        score = 0;
        [self setupHUD];
        
        threeCheckpoints = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            threeCheckpoints[i] = @0;
        }
        
        coins = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i = 0; i < 5; ++i) {
            SKSpriteNode *coin = [SKSpriteNode spriteNodeWithImageNamed:@"coins"];
            coin.hidden = YES;
            [coin setXScale:0.5];
            [coin setYScale:0.5];
            [coins addObject:coin];
            [self addChild:coin];
        
        }
        
        isCheckpoint = NO;
        previousCheckpoint = 0;
        
        [self startGame];
        
    }
    return self;
}

// ----------------------------------------------------------------------------
// update
// updates the game scene at every frame (every 0.1 seconds)
- (void) update:(NSTimeInterval)currTime {

    if (self.gameOver)
        return;
    
    NSTimeInterval changeOfTime = currTime - self.previousTime;
    
    self.previousTime = currTime;
    [self.player update:changeOfTime];
    
        
    // check for checkpoints
    [self handleCheckpoints:self.player];

    // check for end of game
    [self checkForWin];

    // update players position
    [self setViewpointCenter:self.player.position];
}

// ----------------------------------------------------------------------------
- (void)handleCheckpoints:(Player *)player {
    // checking corners around the character
    // 3x3 tile. 
    // 1 2 3
    // 4 0 5
    // 6 7 8
    //check below, up side, then sideways
    NSInteger indices[8] = {7, 2, 4, 5, 1, 3, 6, 8};
    for (NSUInteger i = 0; i < 8; i++) {
        NSInteger tileIndex = indices[i];
        
        CGRect playerRect = [player playerCollisionCheck];
        CGPoint playerCoord = [self.checkpoints coordForPoint:player.desiredPosition];
        
        CGPoint tileCoord;
        
        // down
        if (tileIndex == 7) {
            tileCoord = CGPointMake(playerCoord.x, playerCoord.y + 3);
        }
        // up
        else if (tileIndex == 2) {
            tileCoord = CGPointMake(playerCoord.x, playerCoord.y - 3);
        }
        if (tileCoord.y <= 2) {
            tileCoord = CGPointMake(tileCoord.x, 2);
        }
        
        NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.checkpoints];
        if (gid != 0) {
            CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
            
        
            if (CGRectIntersectsRect(playerRect, tileRect)) {
                int num1 = 0;
                int num2 = 0;
                int answer = 0;
                int wrongAnswer1 = 0;
                int wrongAnswer2 = 0;
                int wrongAnswer3 = 0;
                if ([threeCheckpoints[0]  isEqual: @0] && (tileCoord.x <= 24 && tileCoord.x >= 22)) {
                    threeCheckpoints[0] = @1;
                    
                    num1 = getRandomNumberBetween(1, 10);
                    num2 = getRandomNumberBetween(5, 15);
                    answer = num1+num2;
                    wrongAnswer1 = getRandomNumberBetween(answer-5, answer-1);
                    wrongAnswer2 = getRandomNumberBetween(answer+5, answer+10);
                    wrongAnswer3 = getRandomNumberBetween(answer+11, answer+15); 

                    self.answers = [[NSMutableArray alloc] initWithObjects:wrongAnswer1, wrongAnswer2, answer, wrongAnswer3, nil];
                    
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Math Bonus Trivia Time!
                                                                        \n\n What is\n 3+7" + num1 + "+" + num2
                                                                             delegate:self
                                                                    cancelButtonTitle:nil
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:nil];
                    for (NSString *answer in self.answers) {
                        [actionSheet addButtonWithTitle:answer];
                    }
                    
                    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
                    
                    [actionSheet showInView:self.view];
                    
                }
                if ([threeCheckpoints[1]  isEqual: @0] && (tileCoord.x <= 144 && tileCoord.x >= 140)) {
                    threeCheckpoints[1] = @1;
                    
                    self.answers = [[NSMutableArray alloc] initWithObjects:@"8", @"4", @"16", @"20", nil];
                    
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Math Bonus Trivia Time!\n\n What is\n 4x4"
                                                                             delegate:self
                                                                    cancelButtonTitle:nil
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:nil];
                    for (NSString *answer in self.answers) {
                        [actionSheet addButtonWithTitle:answer];
                    }
                    
                    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
                    
                    [actionSheet showInView:self.view];
                    

                }
                if ([threeCheckpoints[2]  isEqual: @0] && (tileCoord.x <= 207 && tileCoord.x >= 203)) {
                    threeCheckpoints[2] = @1;
                    
                    self.answers = [[NSMutableArray alloc] initWithObjects:@"23", @"24", @"25", @"26", nil];
                    
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Math Bonus Trivia Time!\n\n What is\n (3x8)+1"
                                                                             delegate:self
                                                                    cancelButtonTitle:nil
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:nil];
                    for (NSString *answer in self.answers) {
                        [actionSheet addButtonWithTitle:answer];
                    }
                    
                    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
                    
                    [actionSheet showInView:self.view];
                    

                }
            }
        }
    }
}

// ----------------------------------------------------------------------------
- (int) getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

// ----------------------------------------------------------------------------
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex && buttonIndex == 2) {
        [self correctAnswer];
    }
    else if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self wrongAnswer];
    }
    
}

// ----------------------------------------------------------------------------
- (void)correctAnswer {
    score = score + 100;
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %4@", [NSNumber numberWithInteger:score]]];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Correct!\n +100 Bonus Points"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"OK"];
    
    [actionSheet showInView:self.view];
}

// ----------------------------------------------------------------------------
- (void)wrongAnswer {
    UIActionSheet *actionSheet2 = [[UIActionSheet alloc] initWithTitle:@"Incorrect!"
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];
    
    actionSheet2.cancelButtonIndex = [actionSheet2 addButtonWithTitle:@"OK"];
    [actionSheet2 showInView:self.view];
}


// ----------------------------------------------------------------------------
- (void) setupHUD {
    scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
    scoreLabel.position = CGPointMake(self.size.width/2, self.size.height - 50);
    scoreLabel.text = [NSString stringWithFormat:@"Score: %4@", [NSNumber numberWithInteger:score]];
    [self addChild:scoreLabel];
}

// ----------------------------------------------------------------------------
-(void)gameOver:(BOOL)won {

    self.gameOver = YES;
    
    NSString *gameText;
    if (won) {
        gameText = @"You Won!";
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Game Over!"
                              message:[NSString stringWithFormat:@"Score: %4@", [NSNumber numberWithInteger:score]]
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
        [alert show];
    } else {
        gameText = @"Try Again!";
    
    
    
    SKLabelNode *endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    endGameLabel.text = gameText;
    endGameLabel.fontSize = 40;
    endGameLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7);
    [self addChild:endGameLabel];
    
    
    UIButton *replay = [UIButton buttonWithType:UIButtonTypeCustom];
    replay.tag = 321;
    UIImage *replayImage = [UIImage imageNamed:@"replay"];
    [replay setImage:replayImage forState:UIControlStateNormal];
    [replay addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
    replay.frame = CGRectMake(self.size.width / 2.0 - replayImage.size.width / 2.0, self.size.height / 2.0 - replayImage.size.height / 2.0, replayImage.size.width, replayImage.size.height);
    [self.view addSubview:replay];
    
    }
    
    
    
}

// ----------------------------------------------------------------------------
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[self.view viewWithTag:321] removeFromSuperview];
    [self.view presentScene:[[GameScene alloc] initWithSize:self.size]];
    
}

// ----------------------------------------------------------------------------
- (void)replay:(id)sender {
    [[self.view viewWithTag:321] removeFromSuperview];
    [self.view presentScene:[[GameScene alloc] initWithSize:self.size]];
}

// ----------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        if (touchLocation.x > self.size.width / 2.0) {
            self.player.mightAsWellJump = YES;
        } else {
            self.player.forwardMarch = YES;
        }
    }
}

// ----------------------------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        
        float halfWidth = self.size.width / 2.0;
        CGPoint touchLocation = [touch locationInNode:self];
        
        //get previous touch and convert it to node space
        CGPoint previousTouchLocation = [touch previousLocationInNode:self];
        
        if (touchLocation.x > halfWidth && previousTouchLocation.x <= halfWidth) {
            self.player.forwardMarch = NO;
            self.player.mightAsWellJump = YES;
        } else if (previousTouchLocation.x > halfWidth && touchLocation.x <= halfWidth) {
            self.player.forwardMarch = YES;
            self.player.mightAsWellJump = NO;
        }
    }
}

// ----------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        if (touchLocation.x < self.size.width / 2.0) {
            self.player.forwardMarch = NO;
        } else {
            self.player.mightAsWellJump = NO;
        }
    }
}

// ----------------------------------------------------------------------------
-(void)checkForWin {
    if (self.player.position.x > 3370.0) {
        [self gameOver:1];
    }
}

// ----------------------------------------------------------------------------
-(void)startGame {
    nextCoinSpawn = 0;
    for(SKSpriteNode *coin in coins) {
        coin.hidden = YES;
    }
}

@end