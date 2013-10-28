//
//  LayVcNavigationViewController.m
//  Lay
//
//  Created by Rene Kollmorgen on 14.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcNavigation.h"
#import "LayVcMyCatalogList.h"
#import "LayStyleGuide.h"

#import "LayImage.h"

@interface LayVcNavigation ()

@end

@implementation LayVcNavigation

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINavigationBar *navBar = self.navigationBar;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    navBar.barTintColor = [styleGuide getColor:ButtonBorderColor];
    //navBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
