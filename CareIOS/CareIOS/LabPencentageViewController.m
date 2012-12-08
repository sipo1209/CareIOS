//
//  LabPencentageViewController.m
//  CareIOS
//
//  Created by Tron Skywalker on 12-12-6.
//  Copyright (c) 2012年 ThankCreate. All rights reserved.
//

#import "LabPencentageViewController.h"
#import "MiscTool.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface LabPencentageViewController ()
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIImageView *herImage;
@property (strong, nonatomic) IBOutlet UIImageView *myImage;
@property (strong, nonatomic) IBOutlet UILabel *lblHerName;
@property (strong, nonatomic) IBOutlet UILabel *lblMyName;
@property (strong, nonatomic) IBOutlet UILabel *lblScore;
@property (strong, nonatomic) IBOutlet UILabel *lblScorePrefix;


@end

@implementation LabPencentageViewController

@synthesize col1;
@synthesize col2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* myGreen = [UIColor colorWithRed:0.0f green:0.5 blue:0.0f alpha:1.0f ];
    NSString* herStrUrl = [MiscTool getHerIcon];
    NSURL* herUrl = [NSURL URLWithString:herStrUrl];
    [self.herImage setImageWithURL:herUrl];    
    self.herImage.layer.cornerRadius = 9.0;
    self.herImage.layer.masksToBounds = YES;
    self.herImage.layer.borderColor = myGreen.CGColor;
    self.herImage.layer.borderWidth = 4.0;
    
    NSString* myStrUrl = [MiscTool getMyIcon];
    NSURL* myUrl = [NSURL URLWithString:myStrUrl];
    [self.myImage setImageWithURL:myUrl];
    self.myImage.layer.cornerRadius = 9.0;
    self.myImage.layer.masksToBounds = YES;
    self.myImage.layer.borderColor = myGreen.CGColor;
    self.myImage.layer.borderWidth = 4.0;
    
    self.lblHerName.text = [MiscTool getHerName];
    self.lblHerName.Font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
    self.lblHerName.textColor = myGreen;
    [self.lblHerName sizeToFit];
    
    self.lblMyName.text = [MiscTool getMyName];
    self.lblMyName.Font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
    self.lblMyName.textColor = myGreen;
    [self.lblMyName sizeToFit];
    
    
    self.lblScorePrefix.Font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
    self.lblScorePrefix.textColor = myGreen;
    [self.lblScorePrefix sizeToFit];
    self.lblScore.Font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0];
    self.lblScore.textColor = myGreen;
    [self.lblScore sizeToFit];

    
    NSMutableArray *temp = [NSMutableArray array];
    for(int j = 0; j < 3; j++)
    {
        for(int i = 0; i < 10 ; ++i)
        {
            [temp addObject:[NSNumber numberWithInt:i]];
        }
    }

    col1 = [NSArray arrayWithArray:temp];
    col2 = [NSArray arrayWithArray:temp];
    
    self.picker.userInteractionEnabled = NO;
    [self analysisPercentage];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)analysisPercentage
{
    NSString* hername = [MiscTool getHerName];
    int sig1 = [self calculateString:hername];
    NSString* myname = [MiscTool getMyName];
    int sig2 = [self calculateString:myname];
    int result = (sig1 + sig2) * 575 % 59 + 41;
    
    int first = result / 10;
    int secoend = result % 10;
    [self.picker selectRow:first + 10 inComponent:0 animated:YES];
    [self.picker selectRow:secoend + 10 inComponent:1 animated:YES];
    [self.picker reloadAllComponents];
    
    self.lblScore.text = [[NSNumber numberWithInt:result] stringValue];

}

- (int)calculateString:(NSString*)str
{
    int sig = 0;
    char* p = (char*)[str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
    {
        if (*p)
        {
            p++;
            sig += (int)(*p);
        }
        else
        {
            p++;
        }
        
    }
    return sig;
}


#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    if (component == 0)
        return [self.col1 count];
    
    return [self.col2 count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if(component == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 52)];
        label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        label.textAlignment = NSTextAlignmentRight;
        label.Font = [UIFont fontWithName:@"Helvetica-Bold" size:50];
        label.backgroundColor = [UIColor clearColor];
        return label;
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 120, 52)];
        label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        label.textAlignment = NSTextAlignmentLeft;
        label.Font = [UIFont fontWithName:@"Helvetica-Bold" size:50];
        label.backgroundColor = [UIColor clearColor];
        return label;
    }

}


#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    NSNumber* num;
    row = row % 10;
    if (component == 0)
    {
        num = [col1 objectAtIndex:row];        
    }
    else
    {
        num = [col2 objectAtIndex:row];
    }
    return [num stringValue];
}

@end
