//
//  ViewController.m
//  MarioJsonFormat-Swift
//
//  Created by ZhangXiaofei on 16/9/19.
//  Copyright © 2016年 Yuri. All rights reserved.
//

#import "ViewController.h"
#import "XMLDictionary.h"

#define kDEFAULT_CLASS_NAME     @("Mario")
#define kDEFAULT_CLASS_PREFIX   @("Mario")
#define kCLASS_H           @("\n@interface %@ :NSObject\n%@\n@end\n")
#define kPROPERTY(property)       ((property) == 'c' ? @("@property (nonatomic ,copy) %@ *%@;\n") : @("@property (nonatomic , strong) %@ *%@;\n"))
#define kASSIGN_PROPERTY   @("@property (nonatomic ,assign) %@ %@;\n")
#define kCLASS_M           @("@implementation %@\n\n@end\n")
#define kCLASS_Prefix_M    @("@implementation %@\n+ (NSString *)prefix;\n@end\n\n")
#define kCLASS_SWIFT       @("\n@objc(%@)\nclass %@ :NSObject {\n%@\n}")
#define kPROPERTY_SWIFT    @("var %@: %@!\n")

@interface ViewController () {
    NSMutableString *_classString;
    NSMutableString *_classMString;
    NSMutableString *_classSwiftString;
    NSString *_classPrefixName;
}
@property (nonatomic ,strong) IBOutlet NSTextField *classPrefixTF;
@property (nonatomic ,strong) IBOutlet NSTextField *classNameTF;
@property (nonatomic ,strong) IBOutlet NSTextView *jsonTV;
@property (nonatomic ,strong) IBOutlet NSTextView *classTV;
@property (nonatomic ,strong) IBOutlet NSTextView *classMTV;
@property (nonatomic ,strong) IBOutlet NSTextView *classSwiftTV;
@property (nonatomic ,strong) IBOutlet NSButton *checkBoxBtn;
@property (nonatomic ,strong) IBOutlet NSTextField *classTitle;
@property (nonatomic ,strong) IBOutlet NSTextField *classMTitle;
@property (nonatomic ,strong) IBOutlet NSTextField *classSwiftTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self initialData];
    
    // Do any additional setup after loading the view.
}

- (void)initialData {
    //data
    _classString = [NSMutableString string];
    _classMString = [NSMutableString string];
    _classSwiftString = [NSMutableString string];
    
    //output
    self.classTV.editable = NO;
    self.classMTV.editable = NO;
    self.classSwiftTV.editable = NO;
    
    //input
    self.jsonTV.drawsBackground = NO;
    self.classNameTF.drawsBackground = NO;
    self.classPrefixTF.drawsBackground = NO;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)isCreateSwift:(id)sender {

    
}
- (IBAction)resetJsonInput:(id)sender {
    self.jsonTV.string = @"";
    self.classTV.string = @"";
    self.classSwiftTV.string = @"";
    self.classMTV.string = @"";
}

- (IBAction)gernateFormatString:(id)sender {
    
    [self deleteMutableString:_classString];
    [self deleteMutableString:_classMString];
    [self deleteMutableString:_classSwiftString];
    
    _classPrefixName = self.classPrefixTF.stringValue ? self.classPrefixTF.stringValue : kDEFAULT_CLASS_PREFIX;
    NSString *className = self.classNameTF.stringValue;
    NSString *jsonStr = self.jsonTV.string;
    
    if (!className || className.length == 0) {
        className = kDEFAULT_CLASS_NAME;
    }
    
    if (jsonStr && jsonStr.length > 0) {
        
        NSDictionary *dataDict = nil;
        if ([jsonStr hasPrefix:@"<"]) {
             dataDict = [NSDictionary dictionaryWithXMLString:jsonStr];
        } else {
            NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        }
        if (dataDict) {
            [_classSwiftString appendFormat:kCLASS_SWIFT, className, className, [self formatDataWithDict:dataDict key:@"" swift:YES]];
            [_classString appendFormat:kCLASS_H, className, [self formatDataWithDict:dataDict key:@"" swift:NO]];
            if (_classPrefixName.length > 0) {
                [_classMString appendFormat:kCLASS_Prefix_M, className];
            } else {
                [_classMString appendFormat:kCLASS_M, className];
            }
            self.classTV.string = _classString;
            self.classMTV.string = _classMString;
            self.classTitle.stringValue = [NSString stringWithFormat:@"%@.h", className];
            self.classMTitle.stringValue = [NSString stringWithFormat:@"%@.m", className];
            
            if (self.checkBoxBtn.state == 1) {
                self.classSwiftTitle.stringValue = [NSString stringWithFormat:@"%@.swift", className];
                self.classSwiftTV.string = _classSwiftString;
            }
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"警告" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"json或者xml数据格式不正确"];
            [alert runModal];
        }
       
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"警告" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"json或者xml数据不能为空"];
        [alert runModal];
    }
}

- (IBAction)saveToLocal:(id)sender {
    
//    NSOpenPanel *openPaner = [[NSOpenPanel alloc] init];
//    
//    openPaner.allowedFileTypes = NO;
//    openPaner.treatsFilePackagesAsDirectories = NO;
//    openPaner.canChooseFiles = NO;
//    openPaner.canChooseDirectories = YES;
//    openPaner.canCreateDirectories = YES;
//    openPaner.prompt = @"choose";
//    [openPaner beginSheet:self.view.window completionHandler:^(NSModalResponse returnCode) {
//        if (returnCode == NSFileHandlingPanelOKButton) {
//            [self saveToPath:openPaner.URL.path];
//            
//        }
//    }];
}

- (void)saveToPath:(NSString *)path {
//    NSError *error = nil;
//    for (<#type *object#> in fil) {
//        <#statements#>
//    }
}

- (void)deleteMutableString:(NSMutableString *)mutableStr {
    
    if (mutableStr.length > 0) {
        [mutableStr deleteCharactersInRange:NSMakeRange(0, mutableStr.length)];
    }
}

- (NSString *)formatDataWithDict:(NSDictionary *)object key:(NSString *)key swift:(BOOL)isSwift{
    if (object) {
        NSMutableString  *property = [NSMutableString string];
        if([object isKindOfClass:[NSDictionary class]]){
            
            NSDictionary *dict = object;
            NSInteger count = dict.count;
            NSArray *keyArr = [dict allKeys];
            
            for (NSInteger i = 0; i < count; i++) {
                NSString *key = keyArr[i];
                if ([key isEqualToString:@"id"]) {
                    key = @"ID";
                }
                id subObject = dict[key];
                NSString *className = [self handleAfterClassName:key];
                if([subObject isKindOfClass:[NSDictionary class]]){
                    NSString *classContent = [self formatDataWithDict:subObject key:key swift:isSwift];
                    if (isSwift == 0) {
                        [property appendFormat:kPROPERTY('c'), className, key];
                        [_classString appendFormat:kCLASS_H, className, classContent];
                        if (_classPrefixName.length > 0) {
                            [_classMString appendFormat:kCLASS_Prefix_M, className];
                        } else {
                            [_classMString appendFormat:kCLASS_M, className];
                        }
                    } else {
                        [property appendFormat:kPROPERTY_SWIFT, key, className];
                        [_classSwiftString appendFormat:kCLASS_SWIFT,className, className, classContent];
                    }
                } else if ([subObject isKindOfClass:[NSArray class]]) {
                    NSString * classContent = [self formatDataWithDict:subObject key:key swift:isSwift];
                    if(isSwift == 0){
                        [property appendFormat:kPROPERTY('s'),[NSString stringWithFormat:@"NSArray<%@ *>",className], key];
                        [_classString appendFormat:kCLASS_H,className, classContent];
                        if (_classPrefixName.length > 0) {
                            [_classMString appendFormat:kCLASS_Prefix_M, className];
                        }else {
                            [_classMString appendFormat:kCLASS_M, className];
                        }
                    }else{
                        [property appendFormat:kPROPERTY_SWIFT,key,[NSString stringWithFormat:@"[%@]", className]];
                        [_classSwiftString appendFormat:kCLASS_SWIFT, className, className, classContent];
                    }
                } else if ([subObject isKindOfClass:[NSString class]]){
                    if(isSwift == 0){
                        [property appendFormat:kPROPERTY('c'), @"NSString", key];
                    }else{
                        [property appendFormat:kPROPERTY_SWIFT, key, @"String"];
                    }
                } else if ([subObject isKindOfClass:[NSNumber class]]){
                    if (isSwift == 0) {
                        if (strcmp([subObject objCType], @encode(float)) == 0 ||
                            strcmp([subObject objCType], @encode(CGFloat)) == 0) {
                            [property appendFormat:kASSIGN_PROPERTY, @"CGFloat", key];
                        } else if (strcmp([subObject objCType], @encode(double)) == 0) {
                            [property appendFormat:kASSIGN_PROPERTY, @"double", key];
                        } else if (strcmp([subObject objCType], @encode(BOOL)) == 0) {
                            [property appendFormat:kASSIGN_PROPERTY, @"Bool", key];
                        } else {
                            [property appendFormat:kASSIGN_PROPERTY, @"NSInteger", key];
                        }
                    } else {
                        if (strcmp([subObject objCType], @encode(float)) == 0 ||
                            strcmp([subObject objCType], @encode(CGFloat)) == 0) {
                            [property appendFormat:kPROPERTY_SWIFT, key, @"CGFloat"];
                        } else if (strcmp([subObject objCType], @encode(double)) == 0) {
                            [property appendFormat:kPROPERTY_SWIFT, key, @"Double"];
                        } else if (strcmp([subObject objCType], @encode(BOOL)) == 0) {
                            [property appendFormat:kPROPERTY_SWIFT, key, @"Bool"];
                        } else {
                            [property appendFormat:kPROPERTY_SWIFT, key, @"Int"];
                        }
                    }
                } else {
                    if(subObject == nil){
                        if(isSwift == 0){
                            [property appendFormat:kPROPERTY('c'), @"NSString", key];
                        }else{
                            [property appendFormat:kPROPERTY_SWIFT, key, @"String"];
                        }
                    }else if([subObject isKindOfClass:[NSNull class]]){
                        if(isSwift == 0){
                            [property appendFormat:kPROPERTY('c'), @"NSString", key];
                        }else{
                            [property appendFormat:kPROPERTY_SWIFT, key, @"String"];
                        }
                    }
                }
            }
        } else {
            NSLog(@"key = %@", key);
        }
        return property;
    }
    return @"";
}

- (NSString *)handleAfterClassName:(NSString *)className {
    NSString *first = [className substringToIndex:1];
    NSString *other = [className substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@%@", _classPrefixName, [first uppercaseString], other];
}

@end
