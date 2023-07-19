//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@MainActor
public final class _WindowPresentationController<Content: View>: ObservableObject {
    public var content: Content {
        didSet {
            if contentWindow == nil {
                _update()
            }
        }
    }
    
    public let windowStyle: _WindowStyle
    
    @Published public var canBecomeKey: Bool {
        didSet {
            if contentWindow == nil || canBecomeKey != oldValue {
                _update()
            }
        }
    }
    
    @Published public var isVisible: Bool {
        didSet {
            if contentWindow == nil || isVisible != oldValue {
                _update()
            }
        }
    }
    
    @Published public var preferredColorScheme: ColorScheme? {
        didSet {
            if contentWindow == nil || preferredColorScheme != oldValue {
                _update()
            }
        }
    }
    
    private var contentWindow: AppKitOrUIKitHostingWindow<Content>?
    
    init(
        content: Content,
        windowStyle: _WindowStyle = .default,
        canBecomeKey: Bool,
        isVisible: Bool
    ) {
        self.content = content
        self.windowStyle = windowStyle
        self.canBecomeKey = canBecomeKey
        self.isVisible = isVisible
        
        DispatchQueue.asyncOnMainIfNecessary {
            self._update()
        }
    }
    
    public convenience init(
        content: Content
    ) {
        self.init(
            content: content,
            windowStyle: .default,
            canBecomeKey: true,
            isVisible: false
        )
    }
        
    public func show() {
        isVisible = true
    }
    
    public func hide() {
        isVisible = false
    }
    
    func _update() {
        if let contentWindow = contentWindow, contentWindow.isHidden == !isVisible {
            return
        }
        
        if isVisible {
            #if !os(macOS)
            guard let window = AppKitOrUIKitWindow._firstKeyInstance, let windowScene = window.windowScene else {
                return
            }
            #endif
            
            #if os(macOS)
            let contentWindow = self.contentWindow ?? AppKitOrUIKitHostingWindow(
                rootView: content,
                style: windowStyle
            )
            #else
            let contentWindow = self.contentWindow ?? AppKitOrUIKitHostingWindow(
                windowScene: windowScene,
                rootView: content
            )
            #endif
            
            self.contentWindow = contentWindow
            
            contentWindow.rootView = content
            contentWindow.configuration.canBecomeKey = canBecomeKey
            contentWindow.isVisibleBinding = Binding(
                get: { [weak self] in
                    self?.isVisible ?? false
                },
                set: { [weak self] in
                    self?.isVisible = $0
                }
            )
            
            #if os(iOS)
            let userInterfaceStyle: UIUserInterfaceStyle = preferredColorScheme == .light ? .light : .dark
            
            if contentWindow.overrideUserInterfaceStyle != userInterfaceStyle {
                _assignIfNotEqual(userInterfaceStyle, to: &window.overrideUserInterfaceStyle)
                
                if let rootViewController = contentWindow.rootViewController {
                    _assignIfNotEqual(userInterfaceStyle, to: &rootViewController.overrideUserInterfaceStyle)
                }
            }
            #endif
            
            #if os(iOS) || os(tvOS)
            _assignIfNotEqual(UIWindow.Level(rawValue: window.windowLevel.rawValue + 1), to: &contentWindow.windowLevel)
            #endif
            
            contentWindow.show()
        } else {
            contentWindow?.hide()
            contentWindow = nil
        }
    }
}

#if os(macOS)
extension _WindowPresentationController {
    @available(macOS 11.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public convenience init<Style: WindowStyle>(
        content: Content,
        windowStyle: Style
    ) {
        self.init(
            content: content,
            windowStyle: .init(from: windowStyle),
            canBecomeKey: true,
            isVisible: false
        )
    }
}
#endif

// MARK: - Auxiliary

public enum _WindowStyle {
    case `default`
    case titleBar
    case hiddenTitleBar
    
    @available(macOS 11.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(from windowStyle: any WindowStyle) {
        switch windowStyle {
            case is DefaultWindowStyle:
                self = .`default`
            case is TitleBarWindowStyle:
                self = .titleBar
            case is HiddenTitleBarWindowStyle:
                self = .hiddenTitleBar
            default:
                assertionFailure("unimplemented")
                
                self = .default
        }
    }
}

#endif
