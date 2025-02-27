//
//  DetailWebViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 2/27/25.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa
import SnapKit

final class DetailWebViewController: BaseViewController {
    
    private lazy var webView = {
        let view = WKWebView(frame: .zero, configuration: createWKWebViewConfiguration())
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    var url: String!
    var navTitle: String!
    
    override func bind() {
        
    }
    
    override func configLayout() {
        view.addSubview(webView)
        
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configView() {
        navigationItem.title = navTitle ?? "test"
        
        let request = URLRequest(url: URL(string: url)!)
        print("URL >>> ", url, request)
        webView.load(request)
    }
    
    private func createWKWebViewConfiguration() -> WKWebViewConfiguration {
        let preference = WKPreferences()
        preference.javaScriptCanOpenWindowsAutomatically = true
        preference.javaScriptEnabled = true
        
        let controller = WKUserContentController()
        controller.add(self, name: "bridge")
        
        let config = WKWebViewConfiguration()
        config.preferences = preference
        config.userContentController = controller

        return config
    }
    
}

extension DetailWebViewController: WKUIDelegate {
    
}

extension DetailWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension DetailWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            
    }
}
