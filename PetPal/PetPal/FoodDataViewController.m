//  PROGRAMMER:     Curtis Cox
//  PANTHERID:      5001361
//  GROUP:          F
//  CLASS:          COP 465501 TR 5:00
//  INSTRUCTOR:     Steve Luis  ECS 282
//  ASSIGNMENT:     Group Project
//  DUE:            Thursday 12/10/15
//
//  FoodDataViewController.m
//  PetPalV1
//
//  Created by Curtis Cox on 11/12/15.
//  Copyright (c) 2015 Curtis Cox. All rights reserved.
//

#import "FoodDataViewController.h"
#import "MyFoodsTableViewController.h"
#import <Parse/Parse.h>
#import "FoodList.h"
#import "FoodType.h"

@interface FoodDataViewController ()

@end

@implementation FoodDataViewController
@synthesize brandName, FlavorName, caloriesPerServing, servingSize, univPriceCode, ServingUnit, myFoodList, pickedServingUnit, sizeLables, typeLables, foodType, pickedType, importedFood;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Food";
    // Do any additional setup after loading the view from its nib.
    sizeLables = [[NSArray alloc] initWithObjects:@"can", @"cups", @"grams", @"ounces", @"pieces", @"pouch", @"pounds", nil];
    typeLables = [[NSArray alloc] initWithObjects:@"Cat", @"Dog", nil];

    myFoodList = [FoodList defaultFoodList];
}

//populate the view with the previously selected food
-(void)viewWillAppear:(BOOL)animated
{
    if (importedFood != nil) {
        brandName.text = [importedFood objectForKey:@"brandName"];
        FlavorName.text = [importedFood objectForKey:@"flavorName"];
        servingSize.text = [importedFood objectForKey:@"servingSize"];
        univPriceCode.text = [importedFood objectForKey:@"uPC"];
        caloriesPerServing.text = [importedFood objectForKey:@"caolriesPerServing"];
        pickedServingUnit = [importedFood objectForKey:@"servingUnit"];
        pickedType = [importedFood objectForKey:@"type"];
        NSUInteger row = [sizeLables indexOfObject:[importedFood objectForKey:@"servingUnit"]];
        [ServingUnit selectRow:row inComponent:0 animated:YES];
        row = [typeLables indexOfObject:[importedFood objectForKey:@"type"]];
        [foodType selectRow:row inComponent:0 animated:YES];
    }
    else
    {
        pickedServingUnit = [sizeLables objectAtIndex:0];
        pickedType = [typeLables objectAtIndex:0];
    }
}

//Save changed to core Data
-(void)viewWillDisappear:(BOOL)animated
{
    [[FoodList defaultFoodList] saveChanges];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Add the input food to the Global Parse Database
- (IBAction)pressedAddToDatabase:(id)sender {
    
    PFObject *food = [PFObject objectWithClassName:@"food"];
    food[@"type"] = pickedType;
    food[@"brandName"] = [brandName text];
    food[@"flavorName"] = [FlavorName text];
    food[@"servingSize"] = [servingSize text];
    food[@"caolriesPerServing"] = [caloriesPerServing text];
    food[@"uPC"] = [univPriceCode text];
    food[@"servingUnit"] = pickedServingUnit;
    [food saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSString *title = [[NSString alloc] initWithFormat:
                               @"Parse Database"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:@"Food saved to database."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        } else {
            NSString *title = [[NSString alloc] initWithFormat:
                               @"Parse Database"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:@"Could not save to database.\nTry again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

//Add the Food to the Local food list
- (IBAction)pressedAddToMyFood:(id)sender {
    FoodType *food = [[FoodType alloc]init];
    food.foodName = [NSString stringWithFormat:@"%@ - %@",[brandName text], [FlavorName text]];
    food.servingSize = [servingSize text];
    food.calPerServig = [caloriesPerServing text];
    food.servingUnit = pickedServingUnit;
    [myFoodList addFoodType:food];
    [[FoodList defaultFoodList] saveChanges];
}

//change view to the local food list
- (IBAction)pressedManageMyFood:(id)sender {
    MyFoodsTableViewController *mFTVC = [[MyFoodsTableViewController alloc]init];
    [self.navigationController pushViewController:mFTVC animated:YES];
}

//UIPickerViewDataSource methods:

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == ServingUnit){
    return 5;
    }
    if (pickerView == foodType) {
        return 2;
    }
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView == ServingUnit) {
        return [sizeLables objectAtIndex:row];
    }
    else if (pickerView == foodType){
        return [typeLables objectAtIndex:row];
    }
    else
        return @"";
}

//UIPicketviewDelagte method
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component{
    if(pickerView == ServingUnit){
        pickedServingUnit = [sizeLables objectAtIndex:row];
    }
    if (pickerView == foodType) {
        pickedType = [typeLables objectAtIndex:row];
    }
}

//UITextFeildDelegate method
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if ([brandName isFirstResponder])
        [brandName resignFirstResponder];
    if ([FlavorName isFirstResponder])
        [FlavorName resignFirstResponder];
    if ([univPriceCode isFirstResponder])
        [univPriceCode resignFirstResponder];
    if ([servingSize isFirstResponder])
        [servingSize resignFirstResponder];
    if ([caloriesPerServing isFirstResponder])
        [caloriesPerServing resignFirstResponder];

    return YES;
}

// UITextFieldDelegate protocol method called when
// touches occur outside of a UITextField that is
// being edited or its keyboard
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([brandName isFirstResponder])
        [brandName resignFirstResponder];
    if ([FlavorName isFirstResponder])
        [FlavorName resignFirstResponder];
    if ([univPriceCode isFirstResponder])
        [univPriceCode resignFirstResponder];
    if ([servingSize isFirstResponder])
        [servingSize resignFirstResponder];
    if ([caloriesPerServing isFirstResponder])
        [caloriesPerServing resignFirstResponder];

    
    [super touchesBegan:touches withEvent:event];
}


@end
