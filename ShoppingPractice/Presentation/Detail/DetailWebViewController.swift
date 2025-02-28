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
    
    var item: MerchandiseInfo!
    
    override func bind() {
        
    }
    
    override func configLayout() {
        view.addSubview(webView)
        
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configView() {
        navigationItem.title = item.mall
        
        let request = URLRequest(url: URL(string: item.link)!)
        print("URL >>> ", item.link, request)
        webView.load(request)
    }
    
    private func createWKWebViewConfiguration() -> WKWebViewConfiguration {
        let preference = WKPreferences()
        preference.javaScriptCanOpenWindowsAutomatically = true
        
        let controller = WKUserContentController()
        controller.add(self, name: "bridge")
        
        let config = WKWebViewConfiguration()
        config.preferences = preference
        config.userContentController = controller

        return config
    }
    
    override func configNavigation() {
        let likeButton = CustomLikeButton()
        likeButton.bind(viewModel: CustomLikeButtonViewModel(id: item.id)) 
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
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
