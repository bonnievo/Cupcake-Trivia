//
//  GameViewController.m
//  demo-v1
//
//  Created by Bonnie on 7/20/15.
//  Copyright (c) 2015 Bonnie. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"


@implementation GameViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    // debugging labels
    skView.showsFPS = NO;                   // frames per second
    skView.showsNodeCount = NO;             // node count
    
    // Create and configure the scene.
    SKScene * scene = [GameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations // this header is for iOS 9 (Xcode 7)
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end