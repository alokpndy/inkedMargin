//
//  AP_TextExtract.m
//  WordsWorth
//
//  Created by alok pandey on 23/12/15.
//  Copyright © 2015 alok pandey. All rights reserved.
//

#import "AP_TextExtract.h"


@implementation AP_TextExtract


#pragma mark - component seperated by bookName
+(NSArray *) componentSeperatedByBooksFromTXTFile: (NSURL *)urlOfFIle
{
//    NSURL *url = [NSURL URLWithString:@"file:///Volumes/Kindle//documents/My%20Clippings.txt"];
    NSURL *url = urlOfFIle;
    
    // loading file content to NSString pointer
    NSError *error = error;
    NSString *originalContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (error) NSLog(@"ERROR READING CONTENT OF FILE: %@", error);
    
    // separeting string in book entity and saving to NSArray
    NSArray *seperateStringBody = [originalContent componentsSeparatedByString:@"=========="];
    // since last array object will be blank, remove it and form new array
    NSArray *subArray = [seperateStringBody subarrayWithRange:NSMakeRange(0, seperateStringBody.count-1)];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSString *stringBlock in subArray) {
        NSString *modify = [stringBlock stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [array addObject:modify];
    }
    
    return array;
}



#pragma mark - seperate string by new line

+(NSString *) authorNameFromString:(NSString*) string{
    
    NSString *stringToRemove = [self bookNameFromString:string];
    NSMutableArray *newLineArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<[string length]; i++)
    {
        if ([string characterAtIndex:i]=='\n')
        {
            [newLineArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    NSString *firstLine  = nil;
    if (newLineArray[0] != 0) {
        firstLine = [string substringWithRange:NSMakeRange(0, [newLineArray[0]integerValue])];
    }
    
    NSString *authorName = [firstLine substringWithRange:NSMakeRange(stringToRemove.length, firstLine.length - stringToRemove.length)];
    NSString *modify;
    if ([authorName containsString:@")"]) {
        modify = [authorName stringByReplacingOccurrencesOfString:@")" withString:@""];
    }if ([authorName isEqualToString:@""]) {
        modify = @"Unknown";
    }
    return [modify capitalizedString];
    
    
}


#pragma mark - bookNameFromString
+(NSString *) bookNameFromString:(NSString *)string{
    
    NSMutableArray *newLineArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<[string length]; i++)
    {
        if ([string characterAtIndex:i]=='\n')
        {
            [newLineArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    NSString *bookName  = nil;
    if (newLineArray[0] != 0) {
        bookName = [string substringToIndex:[newLineArray[0]integerValue]];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*?\\)" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSMutableString* newString = [bookName mutableCopy];
    NSArray<NSTextCheckingResult*>* matches = [regex matchesInString:newString options:0 range:NSMakeRange(0, newString.length)];
    
    if (matches.count >= 1)
    {
        NSTextCheckingResult* result = matches[matches.count-1];
        [newString replaceCharactersInRange:result.range withString:@""];
        
    }
    
    return newString;
}



#pragma mark - whether Note or Highlights
+(NSString *) whetherNoteOrHighlightFromString:(NSString *)string{
    
    NSMutableArray *newLineArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<[string length]; i++)
    {
        if ([string characterAtIndex:i]=='\n')
        {
            [newLineArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    NSString *secondLine  = nil;
    
    if (newLineArray.count > 1 && newLineArray[1] != 0) {
        secondLine = [string substringWithRange:NSMakeRange([newLineArray[0]integerValue], ([newLineArray[1]integerValue]- [newLineArray[0]integerValue]))];
    }else if (newLineArray.count == 1 && newLineArray[0] != 0){
        secondLine = [string substringFromIndex:[newLineArray[0]integerValue]];
    }
    // checking for highlight
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"highlight|выделенный|Markierung|subrayado|surlignement|evidenziazione|ハイライト|destaque|标"
                                                                           options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray<NSTextCheckingResult*>* matches = [regex matchesInString:secondLine options:0 range:NSMakeRange(0, secondLine.length)];
    
    NSString *result;
    if (matches.count >0) {
        //        NSLog(@"It is a highlight");
        result = @"Highlight";
    }
    
    
    
    NSRegularExpression *regexNotes = [NSRegularExpression regularExpressionWithPattern:@"note|のメモ|笔记|заметка|nota|notitie|Notiz"
                                                                                options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray<NSTextCheckingResult*>* matchesNotes = [regexNotes matchesInString:secondLine options:0 range:NSMakeRange(0, secondLine.length)];
    
    //    NSString *notesResult;
    if (matchesNotes.count >0) {
        //                NSLog(@"It is a Note");
        result = @"Notes";
    }
    
    
    
    
    
    
    
    
    return result;
}

#pragma mark - dateAndTimeFromString
+(NSDate *) dateAndTimeFromString:(NSString *)string{
    
    NSMutableArray *newLineArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<[string length]; i++)
    {
        if ([string characterAtIndex:i]=='\n')
        {
            [newLineArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    NSString *secondLine  = nil;
    
    if (newLineArray.count > 1 && newLineArray[1] != 0) {
        secondLine = [string substringWithRange:NSMakeRange([newLineArray[0]integerValue], ([newLineArray[1]integerValue]- [newLineArray[0]integerValue]))];
    }else if (newLineArray.count == 1 && newLineArray[0] != 0){
        secondLine = [string substringFromIndex:[newLineArray[0]integerValue]];
    }
    
    NSString *removedNewLine = [secondLine stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    
    __block NSDate *dateFromDetector;
    NSDate *manualDate;
    NSDate *dateToReturn;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil];
    
    [detector enumerateMatchesInString:removedNewLine options:kNilOptions range:NSMakeRange(0, [removedNewLine length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        dateFromDetector = result.date;
        
    }];
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // since data detector rely on System Locale to detect date// hence a knide with diifferent languahge book will not be able to be pased fro correct date// date for other language wiil be current dat i.e cannot identify / hence manually
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    
    NSMutableArray *dateSeperatorArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<[removedNewLine length]; i++)
    {
        if ([removedNewLine characterAtIndex:i]=='|')
        {
            [dateSeperatorArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    if (dateSeperatorArray.count > 0) {
        NSInteger lastIndex = [dateSeperatorArray[dateSeperatorArray.count-1]integerValue]+1;
        NSString *subString = [removedNewLine substringFromIndex:lastIndex];
        
        NSString *onlyDateString = [subString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   ////////////////////////////////////////////////////////////////////////////////////////////////
        // Portuguese
        
        if ([onlyDateString containsString:@"Adicionado:"]) {
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"pt_BR"]];
            [dateFormatter setDateFormat:@"'Adicionado: 'EEEE, dd 'de' MM 'de' yyyy HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
          // Russian
        else if ([onlyDateString containsString:@"Добавлено:"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"ru"]];
            [dateFormatter setDateFormat:@"'Добавлено: 'EEEE, dd MM yyyy 'г. в' HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
        
        // German //Hinzugefügt am Sonntag, 27. Dezember 2015 08:18:36
        else if ([onlyDateString containsString:@"Hinzugefügt am"]){
//            NSLog(@"\n\nYES");
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"de_LU"]];
            [dateFormatter setDateFormat:@"'Hinzugefügt am' EEEE, dd'.' MM yyyy HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
//            NSLog(@"MANUAL DATE OS  %@ and %@", manualDate, [dateFormatter dateFromString:onlyDateString] );
            
        }
        
        // French
        else if ([onlyDateString containsString:@"Ajouté le"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"fr_GP"]];
            [dateFormatter setDateFormat:@"'Ajouté le' EEEE, dd MM yyyy HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
        
        // Spanish
        else if ([onlyDateString containsString:@"Añadido el"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"es_CO"]];
            [dateFormatter setDateFormat:@"'Añadido el' EEEE, dd 'de' MM 'de' yyyy HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }

        
        // Italiano
        else if ([onlyDateString containsString:@"Aggiunto in data"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"it_CH"]];
            [dateFormatter setDateFormat:@"'Aggiunto in data' EEEE dd MM yyyy HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
        
        // Japan
        else if ([onlyDateString containsString:@"作成日:"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"ja_JP"]];
            [dateFormatter setDateFormat:@"'作成日:' yyyy'年'MM'月'dd'日金曜日' HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
        
        // Dutch
        else if ([onlyDateString containsString:@"Toegevoegd op"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"nl"]];
            [dateFormatter setDateFormat:@"'Toegevoegd op' EEEE dd MM yyyy HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
        
        // China
        else if ([onlyDateString containsString:@"添加于"]){
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_SG"]];
            [dateFormatter setDateFormat:@"'添加于' yyyy'年'MM'月'dd'日星期五' '上午'HH:mm:ss"];
            manualDate = [dateFormatter dateFromString:onlyDateString];
        }
        
//           NSLog(@"ONLY DTE LINE  IS:%@", onlyDateString);
        
    }
    
    
    if (manualDate != nil) {
        dateToReturn = manualDate;
    }else{
        dateToReturn = dateFromDetector;
    }
    
//    NSLog(@"MANUAL DATE is %@", [manualDate descriptionWithLocale:[NSLocale systemLocale]]);
//    NSLog(@"LINE IS %@", removedNewLine);
//     NSLog(@"DATE TO RETEUN  is %@", [dateToReturn descriptionWithLocale:[NSLocale systemLocale]]);
    return dateToReturn;
}


#pragma mark - Page Location

+(NSDictionary *) pageLocation:(NSString *)string{
    
    NSMutableArray *newLineArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<[string length]; i++)
    {
        if ([string characterAtIndex:i]=='\n')
        {
            [newLineArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    NSString *secondLine  = nil;
    
    if (newLineArray.count > 1 && newLineArray[1] != 0) {
        secondLine = [string substringWithRange:NSMakeRange([newLineArray[0]integerValue], ([newLineArray[1]integerValue]- [newLineArray[0]integerValue]))];
    }else if (newLineArray.count == 1 && newLineArray[0] != 0){
        secondLine = [string substringFromIndex:[newLineArray[0]integerValue]];
    }
    
    NSString *removedNewLine = [secondLine stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //    NSLog(@"LINE IS: %@", removedNewLine);
    
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\|" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray<NSTextCheckingResult*>* matches = [regex matchesInString:removedNewLine options:0 range:NSMakeRange(0, removedNewLine.length)];
    
    NSArray *numbers;
    if (matches.count > 0) {
        NSString *sub = [removedNewLine substringToIndex:matches[matches.count-1].range.location];
        numbers = [sub componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    }
   
    
    NSMutableArray *clean = [numbers mutableCopy];
    [clean removeObject:@""];
   
    
    NSMutableArray *numberToNSNumber = [[NSMutableArray alloc]init];
    for (NSString *myStr in clean) {
        [numberToNSNumber addObject:[NSNumber numberWithInteger:[myStr integerValue]]];
    }
    //   NSLog(@"ARRAY IS %@",clean);
    
    
# pragma mark - Rough
    //Russian  page = странице   Location = Место
    //Deautch  page = Seite      Location = Position
    //Espanol  page = página     Location = posición
    // Francia page = page       Location = emplacement
    // Chiese page = 页          Location =  位置
    
    //Italiano page = pagina    Location =  posizione
    //Japan    page =  ページ    Location =  位置
    //Nederlands page = pagina   Location = locatie
    //Portuguese Brasil page = página     Location = posição
    
    
    
    // checking for page string
    NSRegularExpression *regexCheckPage = [NSRegularExpression regularExpressionWithPattern:@"странице|Seite|página|page|pagina|页|página|ページ"
                                                                                    options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray<NSTextCheckingResult*>* matchesPage = [regexCheckPage matchesInString:removedNewLine options:0 range:NSMakeRange(0, removedNewLine.length)];
    
    
    if (matchesPage.count >0) {
        //                NSLog(@"It has a Page Count");
    }
    
    //Checking for Location string
    
    NSRegularExpression *regexCheckLocation = [NSRegularExpression regularExpressionWithPattern:@"Место|месте|Position|posición|emplacement|posizione|位置|locatie|posição|Location"
                                                                                        options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray<NSTextCheckingResult*>* matchesLocation = [regexCheckLocation matchesInString:removedNewLine options:0 range:NSMakeRange(0, removedNewLine.length)];
    
    
    if (matchesLocation.count >0) {
        //        NSLog(@"It has Location count");
    }
    
    NSMutableArray *pageArray = [[NSMutableArray alloc]init];
    NSMutableArray *locationArray = [[NSMutableArray alloc]init];
    
    if (numberToNSNumber.count == 4) {
        [pageArray addObject:numberToNSNumber[0]];
        [pageArray addObject:numberToNSNumber[1]];
//        NSLog(@"CASE 4");
        [locationArray addObject:numberToNSNumber[2]];
        [locationArray addObject:numberToNSNumber[3]];
    }
    
    if (numberToNSNumber.count == 3) {
        [pageArray addObject:numberToNSNumber[0]];
//        NSLog(@"CASE 3");
        [locationArray addObject:numberToNSNumber[1]];
        [locationArray addObject:numberToNSNumber[2]];
    }
    
    if (numberToNSNumber.count == 2 && matchesPage.count > 0 && matchesLocation.count > 0) {
        [pageArray addObject:numberToNSNumber[0]];
//        NSLog(@"CASE A");
        [locationArray addObject:numberToNSNumber[1]];
    }
    
    if (numberToNSNumber.count == 2 && matchesPage.count == 0 && matchesLocation.count >0) {
//        NSLog(@"CASE B");
        [locationArray addObject:numberToNSNumber[0]];
        [locationArray addObject:numberToNSNumber[1]];
    }
    
    if (numberToNSNumber.count == 2 && matchesPage.count > 0 && matchesLocation.count  == 0) {
//        NSLog(@"CASE C");
        [pageArray addObject:numberToNSNumber[0]];
        [pageArray addObject:numberToNSNumber[1]];
    }
    
    
    if (numberToNSNumber.count == 1 && matchesPage.count == 0 && matchesLocation.count >0) {
        [locationArray addObject:numberToNSNumber[0]];
//        NSLog(@"CASE D");
    }
    
    if (numberToNSNumber.count == 1 &&matchesPage.count > 0 && matchesLocation.count == 0 ) {
        [pageArray addObject:numberToNSNumber[0]];
//        NSLog(@"CASE E");
    }
    
    
    
    
    NSMutableDictionary *locationDictionary = [[NSMutableDictionary alloc]init];
    if (pageArray) {
        [locationDictionary setObject:pageArray forKey:@"Page"];
    }
    if (locationArray) {
        [locationDictionary setObject:locationArray forKey:@"Location"];
        
    }
    
    return locationDictionary;
}



#pragma mark - clippings body
+(NSString *) clippingsBodyFromString:(NSString*) string{
    NSMutableArray *newLineArray = [[NSMutableArray alloc]init];
    for (NSUInteger i=0; i<[string length]; i++)
    {
        if ([string characterAtIndex:i]=='\n')
        {
            [newLineArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    NSString *body  = nil;
    if (newLineArray.count >2 && newLineArray[2] != 0) {
        NSUInteger startOfBody = [newLineArray[2]integerValue];
        body = [string substringFromIndex:startOfBody];
    }
    
    NSString *result = [body stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return result;
}

@end
