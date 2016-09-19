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
#define kFILE_HEADER       @("//\n//  %@\n//  MariboJsonFormat\n//\n//  Version 1.0\n//\n//  在使用中如果遇到什么问题，请联系作者tobe1016@163.com\n//  仓库地址 (github) https://github.com/MarioBiuuuu/MarioJsonFormat\n//\n\n")

@interface ViewController () {
    NSMutableString *_classString;
    NSMutableString *_classMString;
    NSMutableString *_classSwiftString;
    NSString *_classPrefixName;
    NSMutableDictionary *_filesDictM;
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
    _filesDictM = nil;
    [self deleteMutableString:_classString];
    [self deleteMutableString:_classMString];
    [self deleteMutableString:_classSwiftString];
    
    self.jsonTV.string = @"";
    self.classTV.string = @"";
    self.classSwiftTV.string = @"";
    self.classMTV.string = @"";
}

- (IBAction)gernateFormatString:(id)sender {
    _filesDictM = nil;
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
            NSString *hName = [NSString stringWithFormat:@"%@.h", className];
            NSString *mName = [NSString stringWithFormat:@"%@.m", className];
            NSString *sName = [NSString stringWithFormat:@"%@.swift", className];
            
            _filesDictM = [NSMutableDictionary dictionary];
           
            [_classString appendFormat:kFILE_HEADER, hName];
            [_classMString appendFormat:kFILE_HEADER, mName];
            [_classSwiftString appendFormat:kFILE_HEADER, sName];
            
            [_classString appendString:@"#import <Foundation/Foundation.h>\n"];
            [_classMString appendString:[NSString stringWithFormat:@"#import \"%@\"\n", hName]];
            [_classSwiftString appendString:@"import UIKit\n"];
            
            [_classSwiftString appendFormat:kCLASS_SWIFT, className, className, [self formatDataWithDict:dataDict key:@"" swift:YES]];
            [_classString appendFormat:kCLASS_H, className, [self formatDataWithDict:dataDict key:@"" swift:NO]];
            if (_classPrefixName.length > 0) {
                [_classMString appendFormat:kCLASS_Prefix_M, className];
            } else {
                [_classMString appendFormat:kCLASS_M, className];
            }
            self.classTV.string = _classString;
            self.classMTV.string = _classMString;
            
            self.classTitle.stringValue = hName;
            self.classMTitle.stringValue = mName;
            
            _filesDictM[self.classTitle.stringValue] = _classString;
            _filesDictM[self.classMTitle.stringValue] = _classMString;

            if (self.checkBoxBtn.state == 1) {
                self.classSwiftTitle.stringValue = sName;
                self.classSwiftTV.string = _classSwiftString;
                _filesDictM[self.classSwiftTitle.stringValue] = _classSwiftString;
            }
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"警告";
            alert.informativeText = @"json或者xml数据格式不正确";
            [alert addButtonWithTitle:@"确定"];
            
            [alert runModal];
        }
       
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"警告";
        alert.informativeText = @"json或者xml数据不能为空";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
    }
}

- (IBAction)saveToLocal:(id)sender {
    
//    NSSavePanel *panel = [NSSavePanel savePanel];
//    [panel setNameFieldStringValue:@"abc.txt"];
//    [panel setMessage:@"Choose the path to save the document"];
//    [panel setAllowsOtherFileTypes:YES];
////    [panel setAllowedFileTypes:@[@"onecodego"]];
//    [panel setExtensionHidden:YES];
//    [panel setCanCreateDirectories:YES];
//    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
//        if (result == NSFileHandlingPanelOKButton)
//        {
//            NSString *path = [[panel URL] path];
//            NSLog(@"%@", path);
//            [@"onecodego" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        }
//    }];
    if (_filesDictM) {
        [_filesDictM enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           
            if (self.checkBoxBtn.state == 1 && [key isEqualToString:self.classSwiftTitle.stringValue]) {
                [self saveFileToLocal:key withContent:obj];
            } else if (![key isEqualToString:self.classSwiftTitle.stringValue]) {
                [self saveFileToLocal:key withContent:obj];
            }
        }];
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"提示";
        alert.informativeText = [NSString stringWithFormat:@"文件已经保存到桌面MarioClasses文件夹内"];
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (result == NSAlertFirstButtonReturn) {//响应第一个按钮被按下：name：firstname；

            }
        }];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"提示";
        alert.informativeText = @"无可用文件，请先点击Format按钮进行生成";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];

    }
    
}

- (void)saveFileToLocal:(NSString *)name withContent:(NSString *)content {
    
    [content writeToFile:[self filePath:name] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

- (NSString *)filePath:(NSString *)fileName {
    NSArray *appDirectory = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSAllDomainsMask, YES);
    NSString *path = [appDirectory.firstObject stringByAppendingString:@"/MarioClasses"];
    __block NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"提示";
        alert.informativeText = [NSString stringWithFormat:@"文件%@已存在", fileName];
        [alert addButtonWithTitle:@"覆盖"];
        [alert addButtonWithTitle:@"跳过"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (result == NSAlertFirstButtonReturn) {//响应第一个按钮被按下：name：firstname；
                filePath = @"";
            }
        }];
    } else {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSLog(@"%@", filePath);
    return filePath;
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
                NSString *className = [self getClassName:key];
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

- (NSString *)getClassName:(NSString *)className {
    NSString *first = [className substringToIndex:1];
    NSString *other = [className substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@%@", _classPrefixName, [first uppercaseString], other];
}

@end
