
#import "macwindow.h"

// 000   000  00000000  0000000    000   000  000  00000000  000   000  
// 000 0 000  000       000   000  000   000  000  000       000 0 000  
// 000000000  0000000   0000000     000 000   000  0000000   000000000  
// 000   000  000       000   000     000     000  000       000   000  
// 00     00  00000000  0000000        0      000  00000000  00     00  

@implementation MacWebView

-(id) initWithInspectorAllowed:(BOOL)inspectorAllowed
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    if (inspectorAllowed) {
      [[config preferences] setValue:@YES forKey:@"developerExtrasEnabled"];
    }

    [[config preferences] setValue:@YES forKey:@"fullScreenEnabled"];
    [[config preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];
    [[config preferences] setValue:@YES forKey:@"DOMPasteAllowed"];

    return [self initWithFrame:CGRectMake(0, 0, 0, 0) configuration:config];
}

-(id) initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration*)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    
    if (self)
    {
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"drawsBackground"];
    }
    
    return self;
}

-(void)mouseDown:(NSEvent *)event 
{
    NSPoint   viewLoc = [self convertPoint:event.locationInWindow fromView:nil];
    NSString *docElem = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f)", viewLoc.x, viewLoc.y];
    NSString *jsCode  = [NSString stringWithFormat:@"%@.classList.contains(\"app-drag-region\")", docElem];
    
    [self evaluateJavaScript:jsCode completionHandler:
        ^(id result, NSError * error) {
            if (error) NSLog(@"%@", error);
            else 
            {
                if ([[NSNumber numberWithInt:1] compare:result] == NSOrderedSame)
                {
                    [self.window performWindowDragWithEvent:event];
                }
            }
    }];
    
    [super mouseDown:event];
}

-(void)takeSnapshot
{
    WKSnapshotConfiguration * snapshotConfiguration = [[WKSnapshotConfiguration alloc] init];
    [self takeSnapshotWithConfiguration:snapshotConfiguration completionHandler:
        ^(NSImage * image, NSError * error) {
            if (error) { NSLog(@"%@", error); return; }
            [((MacWindow*)[self window]) snapshotTaken:image];
    }];
    [snapshotConfiguration release];
}

@end

// 00     00   0000000    0000000  000   000  000  000   000  0000000     0000000   000   000  
// 000   000  000   000  000       000 0 000  000  0000  000  000   000  000   000  000 0 000  
// 000000000  000000000  000       000000000  000  000 0 000  000   000  000   000  000000000  
// 000 0 000  000   000  000       000   000  000  000  0000  000   000  000   000  000   000  
// 000   000  000   000   0000000  00     00  000  000   000  0000000     0000000   00     00  

@implementation MacWindow

- (id)initWithWebView:(MacWebView*)webView hiddenTitlebar:(BOOL)hideTitlebar hiddenButtons:(BOOL)hideButtons resizable:(BOOL)resizable
{
    m_webView = webView;    

    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskMiniaturizable;
    
    if (resizable)
    {
        styleMask |= NSWindowStyleMaskResizable;
    }
    
    if (hideTitlebar)
    {
        styleMask |= NSWindowStyleMaskFullSizeContentView;
    }
    
    self = [self 
        initWithContentRect:CGRectMake(0, 0, 0, 0)
        styleMask:          styleMask
        backing:            NSBackingStoreBuffered
        defer:              NO];
                
    if (self)
    {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        
        if (hideTitlebar)
        {
            self.titleVisibility = NSWindowTitleHidden;
            self.titlebarAppearsTransparent = YES;
            
            // self.movableByWindowBackground = YES; // not sure if this is still needed or doing anything anymore
        }
        
        if (hideButtons)
        {
            [self standardWindowButton:NSWindowCloseButton      ].hidden = YES;
            [self standardWindowButton:NSWindowMiniaturizeButton].hidden = YES;
            [self standardWindowButton:NSWindowZoomButton       ].hidden = YES;
        }        
    }
    
	return self;
}

- (void)setWidth:(int)width height:(int)height 
        minWidth:(int)minWidth minHeight:(int)minHeight 
        maxWidth:(int)maxWidth maxHeight:(int)maxHeight 
        resizable:(BOOL)resizable
{
    [self setStyleMask:(resizable ? 
        [self styleMask] |  NSWindowStyleMaskResizable : 
        [self styleMask] & ~NSWindowStyleMaskResizable)];

    if (minWidth != -1 || minHeight != -1) {
        [self setContentMinSize:CGSizeMake(minWidth, minHeight)];
    }
    if (maxWidth != -1 || maxHeight != -1) {
        [self setContentMaxSize: CGSizeMake(maxWidth, maxHeight)];
    }
    if(width != -1 || height != -1) {
        [self setFrame:CGRectMake(0, 0, width, height) display:YES animate:NO];
        [self center];
    }
}

-(void)takeSnapshot
{
    [m_webView takeSnapshot];
}

-(void)snapshotTaken:(NSImage *)image
{
    NSString *filePath = @"~/Desktop/neu.png"; // todo: make path configurable somehow
    
    int number = 0;
    while ([[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByExpandingTildeInPath]])
    {
        number++;
        filePath = [NSString stringWithFormat:@"~/Desktop/neu_%d.png", number];
    }
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    imageData = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:[NSDictionary dictionary]];
    [imageData writeToFile:[filePath stringByExpandingTildeInPath] atomically:NO];        
}

- (BOOL)isMovableByWindowBackground 
{
    return YES; // not sure if this is still needed or doing anything anymore
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (BOOL)canBecomeMainWindow
{
	return YES;
}

@end