// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

@interface NSNumber (NSNumberHelper)
+ (BOOL)compareIRCColor:(UniChar)c against:(NSInteger)firstNumber;

- (NSString *)integerWithLeadingZero;
@end