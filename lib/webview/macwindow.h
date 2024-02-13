
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MacWebView : WKWebView
{
}

- (id)initWithInspectorAllowed:(BOOL)inspectorAllowed;

@end

@interface MacWindow : NSWindow
{
    MacWebView *m_webView;
}

- (id)initWithWebView:(MacWebView*)webView hiddenTitlebar:(BOOL)hideTitlebar hiddenButtons:(BOOL)hideButtons resizable:(BOOL)resizable;

- (void)setWidth:(int)width height:(int)height 
        minWidth:(int)minWidth minHeight:(int)minHeight 
        maxWidth:(int)maxWidth maxHeight:(int)maxHeight 
        resizable:(BOOL)resizable;

-(void)snapshotTaken:(NSImage *)image;

@end
