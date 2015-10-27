//
//  GameViewController.m
//  rzGalileo
//
//  Created by Robert Zimmelman on 5/16/15.
//  Public Domain 2015 Robert Zimmelman under GPL
//

#import "GameViewController.h"
@import UIKit;

float mySphereRadius = 1.5 ;
float myMaxX = 0.0;
float myMaxY = 0.0;
float myMaxZ = 0.0;

float myProgress = 0.0;

float myMaxVal = 0.0;
int myDataSet = 6;

int myLineSkip =  0;

int myCrdLineCount = 0;

// DATA HEADER LENGTH IS 19 CHARACTERS, SEE BELOW
//(8F10.4)   15 10 17
int myGalileoDataHeaderLength = 19;


@implementation GameViewController
@synthesize myDefaultURL;
- (void)viewWillLayoutSubviews {
}


- (void)viewDidLayoutSubviews {
    //    [myLoadActivity stopAnimating];
}


- (void)viewDidAppear:(BOOL)animated {
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIAlertView *myURLRequest = [[UIAlertView alloc] initWithTitle:@"Enter URL" message:@"Enter URL Here" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Galileo Viewer", @"URL Preview",nil];
    
    myDefaultURL = @"http://www.acsu.buffalo.edu/~woelfel/DATA/data.crd.txt";
    [myURLRequest setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[myURLRequest textFieldAtIndex:0] setText:myDefaultURL];
    [myURLRequest show];
    
}





- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    if (myDataSet < 9 ) {
        myDataSet++;
    }
    else{
        myDataSet = 1;
    }
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        // rz make this duration fast to flash
        [SCNTransaction setAnimationDuration:0.01];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            // rz make this duration fast to flash
            [SCNTransaction setAnimationDuration:0.01];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)showURLError{
    NSError *myError;
    NSLog(@"Error reading file at %@\n%@",
          myDefaultURL, [myError localizedFailureReason]);
    NSString *myMessage = [NSString stringWithFormat:@"There was an Error Loading the URL at %@.   To test the URL, cut and paste it into any web browser and you should see visible Galileo coordinates.  If you do not, see your professor.  The URL that the App was trying to open is in your Paste buffer.  Go to any app and press the 'Paste' button to see it.",myDefaultURL];
    
    UIPasteboard *myPasteboard = [UIPasteboard generalPasteboard];
    [myPasteboard setString:myDefaultURL];
    
    UIAlertView *myLoadErrorAlert = [[UIAlertView alloc] initWithTitle:@"ERROR Loading URL" message:myMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [myLoadErrorAlert show];
    
    
}

//- (void) runWebView: (NSString *) theURLString {
//    NSLog(@"inside runWebView.  theURLString = %@",theURLString);
//    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    NSURL *theURL = [NSURL URLWithString:theURLString];
//    NSURLRequest *theURLRequest = [[NSURLRequest alloc] initWithURL:theURL];
//    [myWebView loadRequest:theURLRequest];
//    [self.view addSubview:myWebView];
//}



- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Clicked %ld",(long)buttonIndex);
    switch (buttonIndex) {
        case 0:
            exit(0);
            break;
        case 1:
            // the user clicked the "Viewer Button"
        {
            
            NSLog(@"Button Index = %ld",(long)buttonIndex);
            NSLog(@"Alert Text = %@",[alertView textFieldAtIndex:0].text);
            
            
            
            myDefaultURL = [alertView textFieldAtIndex:0].text;
            NSLog(@"myDefaultURL = %@",myDefaultURL);
            
            
            
            //    UIProgressView *myProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            //    [self.view addSubview:myProgressView];
            //    [myProgressView setHidden:NO];
            //    [myProgressView setFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
            //    [myProgressView setProgress:0.0];
            
            NSString *myFormatString = @"(8F10.4)";
            NSString *myDimString = @"";
            NSString *myConString = @"";
            int myDimensions = 0;
            int myConceptCount = 0;
            int myCrdsPerLine = 8; // see assignment of myFormatString above (fortran format)
            int myCrdsLength = 10; //see assignment of myFormatString above (fortran format)
            int myCrdsDecimalPlaces = 4; // see assignment of myFormatString above (fortran format)
            
            // ******************************************************************************
            // rz local data
            //
            //        NSString *myFolderPath = [[[NSBundle mainBundle] resourcePath]
            //                                  stringByAppendingPathComponent:@""];
            //        NSMutableString *myEditPath = [NSMutableString stringWithFormat:@"%@/wk%iallresponsesROT.crd.txt",  myFolderPath, myDataSet];
            //    NSURL *url = [NSURL fileURLWithPath:myEditPath];
            //
            // rz end local data
            // ******************************************************************************
            // rz remote data
            //
            //     http://www.acsu.buffalo.edu/~woelfel/DATA/data.crd.txt
            
            NSString *myURLName = myDefaultURL;
            
            //            NSString *myURLName =  [[NSString alloc] initWithString:[alertView textFieldAtIndex:buttonIndex].text  ];
            
            
            
            //    NSString *myURLName = @"http://robzimmelman.tripod.com/Galileo/barnett2.crd.txt";
            
            
            
            //    NSString *myURLName = @"http://www.acsu.buffalo.edu/~woelfel/DATA/data.crd.txt";
            //    NSString *myURLName =  [NSString stringWithFormat:@"http://robzimmelman.tripod.com/Galileo/wk%iallresponsesROT.crd.txt", myDataSet];
            //
            //
            //
            NSMutableString *myEditPath = [NSMutableString stringWithString:myURLName];
            NSURL *myURL = [NSURL URLWithString:myEditPath];
            NSString *stringFromFile = [NSString stringWithContentsOfURL:myURL encoding:NSUTF8StringEncoding error:NULL];
            //
            //  rz end remote data
            // ******************************************************************************
            //
            //
            //    [myProgressView setProgress:0.0];
            
            
            
            //        NSNumber *myNextNum = 0;
            
            //nslog(@"myEditPath = %@",myEditPath);
            if (stringFromFile == nil) {
                // an error occurred
                [self showURLError];
                
            }
            else {
                myFormatString = [stringFromFile substringWithRange: NSMakeRange(0, 8)];
                myCrdsPerLine =  [myFormatString substringWithRange:NSMakeRange(1, 1)].intValue;
                myCrdsLength = [myFormatString substringWithRange:NSMakeRange(3,2 )].intValue;
                myCrdsDecimalPlaces = [myFormatString substringWithRange:NSMakeRange(6, 1)].intValue;
                
                //nslog(@"MyCrds Length = %d, MyCrdsPerLine = %d, myCrdsDecimalPlaces = %d", myCrdsLength,myCrdsPerLine, myCrdsDecimalPlaces);
                
                // DATA HEADER LENGTH IS 19 CHARACTERS, SEE BELOW
                //(8F10.4)   15 10 17
                
                //(8F10.4)  105 76125
                //(8F10.4) 105 76125
                //(8F10.4)   15 10 17
                //(6F12.4) 105 64105
                // rz new galileo format?
                // needed for the larger datasets.
                
                // rz can we check on the location of the last numbers?
                //        if ([[stringFromFile substringWithRange:NSMakeRange(20, 1)]  isEqualToString:@"1"] ) {
                //        if ([[stringFromFile substringWithRange:NSMakeRange(19, 1)] compare:@"0"] ) {
                //            NSLog(@"Greater Than 0");
                //        }
                //        else {
                //            NSLog(@"Less Than 0");
                //        }
                
                myDimString = [stringFromFile substringWithRange: NSMakeRange(16, 3)];
                myConString = [stringFromFile substringWithRange: NSMakeRange(10, 3)];
                
                myDimensions = [myDimString intValue];
                myConceptCount = [myConString intValue];
                NSArray *myFileLines = [stringFromFile componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                //        NSLog(@"myFileLines = %@",myFileLines);
                //
                NSMutableArray *myWorkLines = [NSMutableArray arrayWithArray:myFileLines];
                NSInteger myLineCount = [myFileLines count];
                
                for (int i = 0 ; i < myLineCount; i++) {
                    if ([myFileLines [i] length] == 0 ) {
                        [myWorkLines removeObject:myFileLines[i]];
                    }
                }
                NSUInteger myWorkLineCount = [myWorkLines count] ;
                //nslog(@"myWorkLineCount = %lu",(unsigned long)myWorkLineCount);
                
                //            for (int i = 0 ; i < myWorkLineCount; i++) {
                //                NSLog(@"Line %i: %@", i , myWorkLines[i]);
                //            }
                
                
                
                
                //            for (int i = 0 ; i < myConceptCount; i++) {
                //                NSLog(@"Concept %i = %@", i + 1 , myCrdLabels[i] );
                //            }
                
                //nslog(@"Dims Before Correction: %i",myDimensions);
                //nslog(@"Cons Before Correction: %i",myConceptCount);
                long myTitleLength = 0;
                myTitleLength = [[myFileLines objectAtIndex:0] length ] - myGalileoDataHeaderLength;
                //nslog(@"Title length = %ld",myTitleLength);
                
                // rz this is to read some datasets, like the barnett2 dataset
                //
                if (myWorkLineCount / myConceptCount > 50 ){
                    myDimString = [stringFromFile substringWithRange: NSMakeRange(17, 3)];
                    myConString = [stringFromFile substringWithRange: NSMakeRange(11, 3)];
                    myDimensions = [myDimString intValue];
                    myConceptCount = [myConString intValue];
                }
                //nslog(@"Dims After Correction: %i",myDimensions);
                //nslog(@"Cons After Correction: %i",myConceptCount);
                NSMutableString *myEditedTitleString = [NSMutableString stringWithString:@""];
                
                if (myTitleLength > 0) {
                    NSString *myTitleString = [[myFileLines objectAtIndex:0] substringFromIndex:myGalileoDataHeaderLength];
                    myEditedTitleString = [NSMutableString stringWithString:myTitleString];
                    //nslog(@"BEFORE REPLACE, Title Is: %@",myEditedTitleString);
                    [myEditedTitleString replaceOccurrencesOfString:@"    " withString:@"" options:NSLiteralSearch range:NSMakeRange(1, myTitleString.length - 1)];
                }
                else{
                    myEditedTitleString = [NSMutableString stringWithString:@""];
                }
                //nslog(@"NOW AFTER REPLACE, Title Is: %@",myEditedTitleString);
                
                //nslog(@"myWorkLineLine Count= %lu",(unsigned long)myWorkLineCount);
                
                NSArray *myCrdLines = [ myWorkLines objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange( 1, myWorkLineCount  - myConceptCount - 1)]   ];
                double myTempX = 0;
                double myTempY = 0;
                double myTempZ = 0;
                int j = 0;
                double myCrdsArray[200][3];
                double myNormalizedCrdsArray[200][3];
                
                // rz we have to skip past the dimensions we're not interested in
                //
                double myTempLineSkip = (double)  myDimensions /  (double) myCrdsPerLine;
                myLineSkip =  ceil(myTempLineSkip);
                //nslog(@"myTempLineSkip = %f",myTempLineSkip);
                
                //nslog(@"myLineSkip = %d",myLineSkip);
                
                myCrdLineCount = myConceptCount * myLineSkip;
                //nslog(@"myCrdLineCount = %d",myCrdLineCount);
                
                //        [myProgressView setProgress:0.0];
                
                for (int i = 0; i < myConceptCount; i++) {
                    //nslog(@"In Loop.  i = %d",i);
                    j = i * myLineSkip;
                    //nslog(@"myCrdLines[j]= %@", myCrdLines[j] );
                    NSArray *myTempArray = [NSArray arrayWithObjects:myCrdLines[j], nil];
                    NSString *myTempString = [[ myTempArray valueForKey:@"description"] componentsJoinedByString:@""];
                    myTempX = [[myTempString substringWithRange:NSMakeRange(0, myCrdsLength)] floatValue] ;
                    myTempY = [[myTempString substringWithRange:NSMakeRange(myCrdsLength + 1, myCrdsLength)] floatValue] ;
                    myTempZ = [[myTempString substringWithRange:NSMakeRange((myCrdsLength * 2 ) + 1, myCrdsLength)] floatValue] ;
                    
                    
                    
                    
                    
                    //nslog(@"X= %f, Y= %f, Z= %f" , myTempX , myTempY , myTempZ);
                    myCrdsArray[i][0] =  myTempX;
                    myCrdsArray[i][1] =  myTempY;
                    myCrdsArray[i][2] =  myTempZ;
                    
                    //
                    // rz for very dense datset with all values between 0 and 2
                    //
                    //            myCrdsArray[i][0] =  myTempX * 25 ;
                    //            myCrdsArray[i][1] =  myTempY * 25 ;
                    //            myCrdsArray[i][2] =  myTempZ * 25 ;
                    
                    // rz find out largest X, Y and Z values
                    if (myTempX > myMaxX) {
                        myMaxX = myTempX;
                    }
                    if (myTempY > myMaxY) {
                        myMaxY = myTempY;
                    }
                    if (myTempZ > myMaxZ) {
                        myMaxZ = myTempZ;
                    }
                    // rz find out maxVal
                    
                    if (myTempX > myMaxVal) {
                        myMaxVal = myTempX;
                    }
                    if (myTempY > myMaxVal) {
                        myMaxVal = myTempY;
                    }
                    if (myTempX > myMaxVal) {
                        myMaxVal = myTempZ;
                    }
                    
                }
                //        [myProgressView setProgress:0.0];
                
                
                
                // rz now normalize the values to a max of 100
                //
                //
                
                double myNormalizeMult = 100 / myMaxVal;
                
                for (int i = 0; i < myConceptCount; i++) {
                    myNormalizedCrdsArray[i][0] = myCrdsArray[i][0] * myNormalizeMult;
                    myNormalizedCrdsArray[i][1] = myCrdsArray[i][1] * myNormalizeMult;
                    myNormalizedCrdsArray[i][2] = myCrdsArray[i][2] * myNormalizeMult;
                }
                
                //   rz here is the SceneKit Stuff
                //
                //
                //
                
                //nslog(@"About to Create Scene");
                //        [myLoadActivity stopAnimating];
                
                
                
                
                // create a new scene
                SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/GalileoScene.dae"];
                
                // rz put some fog just in the middle of the scene so we can see it in real time
                //
                scene.fogColor = [UIColor whiteColor];
                scene.fogStartDistance = 50.0;
                scene.fogEndDistance = 5000.0;
                scene.fogDensityExponent = 0.5;
                
                
                
                // create and add a camera to the scene
                SCNNode *cameraNode = [SCNNode node];
                cameraNode.camera = [SCNCamera camera];
                [scene.rootNode addChildNode:cameraNode];
                
                // place the camera
                // rz place the camera at a position to reflect the max as 100
                //
                //
                //
                cameraNode.position = SCNVector3Make(0, 75, 125);
                //
                //
                // rz here is where the camera should be
                //
                //        cameraNode.position = SCNVector3Make(0, myMaxY * 2, myMaxZ * 4);
                // here is where the camera is for the demo set
                //        cameraNode.position = SCNVector3Make(0, myMaxY /4  , myMaxZ);
                //
                //
                //
                //
                // rz put camera here for very dense scene
                //
                //        cameraNode.position = SCNVector3Make(0, myMaxY * 20 , myMaxZ * 30);
                cameraNode.camera.yFov = 120.0;
                cameraNode.camera.zFar = 5000.0;
                
                [cameraNode setName:@"camera"];
                
                
                
                // create and add a light above the floor
                
                SCNLight *myTopLight = [SCNLight light];
                [myTopLight setType:SCNLightTypeOmni];
                [myTopLight setColor:[UIColor whiteColor]];
                
                SCNNode *topLightNode = [SCNNode node];
                [topLightNode setPosition: SCNVector3Make(0, 300, 200)];
                [topLightNode setLight:myTopLight];
                [scene.rootNode addChildNode:topLightNode];
                
                
                // create and add a second light above the floor
                SCNNode *topLightNode2 = [SCNNode node];
                [topLightNode2 setPosition: SCNVector3Make(0, 300, -300)];
                [topLightNode2 setLight:myTopLight];
                [scene.rootNode addChildNode:topLightNode2];
                
                
                
                // create and add a light below the floor
                SCNNode *bottomLightNode = [SCNNode node];
                bottomLightNode.light = [SCNLight light];
                bottomLightNode.light.type = SCNLightTypeOmni;
                //        bottomLightNode.light.attenuationEndDistance = 1000.0;
                bottomLightNode.position = SCNVector3Make(0, -200, -100);
                bottomLightNode.light.color = [UIColor lightGrayColor];
                [scene.rootNode addChildNode:bottomLightNode];
                
                //        NSLog(@"myWorkLines = %@",myWorkLines);
                
                
                //        NSArray *myCrdLabels = [ myWorkLines objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange( myWorkLineCount - myConceptCount , myConceptCount)] ];
                NSArray *myCrdLabels = [ myWorkLines objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange( myCrdLineCount + 1, myConceptCount)] ];
                
                //nslog(@"myCrdLabels = %@",myCrdLabels);
                
                
                
                SCNView *scnView = (SCNView *)self.view;
                
                // set the scene to the view
                scnView.scene = scene;
                
                // allows the user to manipulate the camera
                scnView.allowsCameraControl = YES;
                
                // show statistics such as fps and timing information
                scnView.showsStatistics = NO;
                
                // configure the view
                scnView.backgroundColor = [UIColor blackColor];
                
                // rz default lighting
                scnView.autoenablesDefaultLighting = YES;
                //nslog(@"MyTitleLength = %ld",myTitleLength);
                if (myTitleLength > 0) {
                    
                    // rz display the title somewhere
                    SCNText *myTitleGeometry = [SCNText textWithString:myEditedTitleString extrusionDepth:1.0];
                    SCNNode *myTitleNode = [SCNNode nodeWithGeometry:myTitleGeometry];
                    [myTitleNode setScale:SCNVector3Make(2, 2, 2)];
                    [myTitleGeometry.firstMaterial setTransparency:0.5];
                    
                    [myTitleGeometry.firstMaterial setShininess:1.0];
                    
                    [myTitleGeometry.firstMaterial.specular setContents:[UIColor blueColor]];
                    [myTitleGeometry.firstMaterial.ambient setContents:[UIColor blueColor]];
                    [myTitleGeometry setSubdivisionLevel:2];
                    //
                    //
                    //  rz place title according to normalized maxval of 100
                    //
                    [myTitleNode setPosition:SCNVector3Make(  100 * -2.0 , 100 * 1.2 , 100 * -1.2 )];
                    //            [myTitleNode setPosition:SCNVector3Make(  myMaxX * -2.0 , myMaxY * 1.2 , myMaxZ * -1.2 )];
                    [scene.rootNode addChildNode:myTitleNode];
                    
                }
                
                float _progress = 0;
                // rz make the spheres and cylinders and text for the concepts
                for (int i = 0; i < myConceptCount; i++) {
                    _progress = ( (float)  i / (float) myConceptCount);
                    //            NSLog(@"C = %i I = %i Progress = %f", myConceptCount, i, _progress);
                    //            [myProgressView setProgress:_progress animated:YES];
                    //            [myProgressView setNeedsDisplay];
                    //nslog(@"CRDs for %@ = %f  %f   %f ",myCrdLabels[i] ,myNormalizedCrdsArray[i][0], myNormalizedCrdsArray[i][1], myNormalizedCrdsArray[i][2]   );
                    SCNNode *mySphereNode = [SCNNode node];
                    SCNSphere *mySphere = [SCNSphere sphereWithRadius:mySphereRadius];
                    if (myConceptCount > 50) {
                        [mySphereNode setScale:SCNVector3Make(.5, .5, .5)];
                    }
                    
                    
                    mySphere.firstMaterial.diffuse.contents = [UIColor redColor];
                    mySphere.firstMaterial.specular.contents = [UIColor whiteColor];
                    mySphere.firstMaterial.shininess = 1.0;
                    //            [mySphereNode setCastsShadow:YES];
                    [mySphereNode setGeometry:mySphere];
                    [mySphereNode setPosition:SCNVector3Make(myNormalizedCrdsArray[i][0], myNormalizedCrdsArray[i][1], myNormalizedCrdsArray[i][2])];
                    [scene.rootNode addChildNode:mySphereNode];
                    
                    
                    SCNNode *myTextNode = [SCNNode node];
                    SCNText *myText = [SCNText textWithString:myCrdLabels[i] extrusionDepth:2.0];
                    myText.firstMaterial.shininess = 0.75;
                    [myText setChamferRadius:0.25];
                    [myText setSubdivisionLevel:1];
                    //            SCNLookAtConstraint *myConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:cameraNode];
                    //            NSArray *myConstraintArray = [NSArray arrayWithObjects:myConstraint, nil];
                    //            myTextNode.constraints = myConstraintArray;
                    //NSLog(@"MyText = %@",myText);
                    [myTextNode setPosition:SCNVector3Make(myNormalizedCrdsArray[i][0], myNormalizedCrdsArray[i][1], myNormalizedCrdsArray[i][2])];
                    [myTextNode setGeometry:myText];
                    
                    //
                    //
                    //  if there are a lot of concepts, make the text smaller
                    //
                    if (myConceptCount > 50) {
                        [myTextNode setScale:SCNVector3Make(0.15, 0.15, 0.15)];
                    }
                    else {
                        [myTextNode setScale:SCNVector3Make(0.5, 0.5, 0.5)];
                    }
                    [scene.rootNode addChildNode:myTextNode];
                    
                    
                    SCNNode *myCylinderNode = [SCNNode node];
                    SCNCylinder *myCylinder = [SCNCylinder cylinderWithRadius:0.25 height:  fabs(myNormalizedCrdsArray[i][1]) ];
                    
                    //            if (myConceptCount > 50) {
                    //                [myCylinderNode setScale:SCNVector3Make(0.05, 0.05, 0.05)];
                    //            }
                    //            else{
                    //                [myCylinderNode setScale:SCNVector3Make(0.25, 0.25, 0.25)];
                    //            }
                    [myCylinderNode setGeometry:myCylinder];
                    myCylinder.firstMaterial.specular.contents = [UIColor darkGrayColor];
                    myCylinder.firstMaterial.ambient.contents = [UIColor darkGrayColor];
                    [myCylinderNode setPosition:SCNVector3Make(myNormalizedCrdsArray[i][0], myNormalizedCrdsArray[i][1]/2, myNormalizedCrdsArray[i][2])];
                    [scene.rootNode addChildNode:myCylinderNode];
                    
                    
                    
                    
                }
                
                
                // rz set up a floor here
                SCNFloor *myFloor = [SCNFloor floor];
                myFloor.reflectionFalloffEnd = 5.0;
                myFloor.reflectionFalloffStart = 1.0;
                myFloor.reflectivity = 0.5;
                //        myFloor.firstMaterial.diffuse.contents = [UIColor darkGrayColor];
                //        myFloor.firstMaterial.ambient.contents = [UIColor darkGrayColor];
                myFloor.firstMaterial.doubleSided = YES;
                myFloor.firstMaterial.transparency = 0.35;
                scene.rootNode.geometry = myFloor;
                //        myFloor.firstMaterial.diffuse.contents = @"Pattern_Grid_16x16.png";
                myFloor.firstMaterial.diffuse.contents = @"unnamed.png";
                //        myFloor.firstMaterial.diffuse.contents = @"8x8_binary_grid_small.png";
                
                myFloor.firstMaterial.locksAmbientWithDiffuse = YES;
                
                // add a tap gesture recognizer
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                NSMutableArray *gestureRecognizers = [NSMutableArray array];
                [gestureRecognizers addObject:tapGesture];
                [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
                scnView.gestureRecognizers = gestureRecognizers;
            }
            
        }
            
            
            // end of Viewer Section
            break;
        case 2:{
            myDefaultURL = [alertView textFieldAtIndex:0].text;
            NSError *myError = nil;
            NSStringEncoding encoding;
            NSURL *theURL = [NSURL URLWithString:myDefaultURL];
            NSString *myTestString = [[NSString alloc] initWithContentsOfURL:theURL
                                                                usedEncoding:&encoding
                                                                       error:&myError];
            if (myTestString == nil) {
                [self showURLError];
            } else {
                UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                NSURLRequest *theURLRequest = [[NSURLRequest alloc] initWithURL:theURL];
                [myWebView loadRequest:theURLRequest];
                [self.view addSubview:myWebView];
            }
                break;
        }
        default:
            break;
    }
    
}

- (void) myERROR {
    
}


@end


