//
//  gr4vy_iOSTests.swift
//  gr4vy-iOSTests
//
//  Created by Gr4vy
//

import XCTest
@testable import gr4vy_ios

class gr4vy_iOSTests: XCTestCase {

    var setup: Gr4vySetup!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        setup = generateSetup()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        setup = nil
    }
    
    func testUtilityGetInitialURLCorrectlyFormsProductionURL() {
        setup.environment = .production
        setup.gr4vyId = "ID123"
        
        let sut = Gr4vyUtility.getInitialURL(from: setup)
        XCTAssertEqual("https://embed.ID123.gr4vy.app/mobile.html?channel=123", sut?.url?.absoluteString)
    }
    
    func testUtilityGetInitialURLCorrectlyFormsSandboxURL() {
        setup.environment = .sandbox
        setup.gr4vyId = "ID123"
        
        let sut = Gr4vyUtility.getInitialURL(from: setup)
        XCTAssertEqual("https://embed.sandbox.ID123.gr4vy.app/mobile.html?channel=123", sut?.url?.absoluteString)
    }
    
    func testUtilityGetInitialURLReturnsNilURL() {
        setup.environment = .production
        setup.gr4vyId = "¬"
        
        let sut = Gr4vyUtility.getInitialURL(from: setup)
        XCTAssertNil(sut?.url?.absoluteString)
    }
    
    func testGenerateUpdateOptionsSucceeds() {
        setup.environment = .production
        setup.gr4vyId = "ID123"
        setup.buyerId = "BUYER123"
        setup.token = "TOKEN123"
        setup.amount = 100
        setup.country = "GB"
        setup.currency = "GBP"
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.buyerId = nil
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentAmounts() {
        setup.amount = 1000
    
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 1000, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.amount = 1
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 1, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.amount = -1
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: -1, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.amount = 0
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 0, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.amount = 2147483647 // Int.max
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 2147483647, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentExternalIdentifiers() {
        setup.externalIdentifier = nil
    
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.externalIdentifier = "ABC"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', externalIdentifier: 'ABC', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.externalIdentifier = "123456789"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', externalIdentifier: '123456789', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.externalIdentifier = ""
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', externalIdentifier: '', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentIntent() {
        setup.intent = nil
    
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.intent = "ABC"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', intent: 'ABC', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.intent = "authorize"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', intent: 'authorize', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.intent = "capture"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', intent: 'capture', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.intent = ""
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', intent: '', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }

    func testGenerateUpdateOptionsSucceedsWithDifferentStore() {
        setup.store = nil
    
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.store = "ABC"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', store: 'ABC', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.store = "ask"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', store: 'ask', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.store = "true"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', store: 'true', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.store = "false"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', store: 'false', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.store = ""
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', store: '', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentDisplay() {
        setup.display = nil
    
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.display = "ABC"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', display: 'ABC', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.display = "all"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', display: 'all', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.display = "addOnly"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', display: 'addOnly', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.display = "storedOnly"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', display: 'storedOnly', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.display = "supportsTokenization"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', display: 'supportsTokenization', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.display = ""
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', display: '', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentOptionalInput() {
        setup.display = nil
        setup.store = nil
        setup.intent = nil
        setup.externalIdentifier = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.externalIdentifier = ""
        setup.store = ""
        setup.display = ""
        setup.intent = ""
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', externalIdentifier: '', store: '', display: '', intent: '', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.externalIdentifier = ""
        setup.store = nil
        setup.display = ""
        setup.intent = nil
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', externalIdentifier: '', display: '', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.externalIdentifier = "XYZ"
        setup.store = "STORE"
        setup.display = "DISPLAY"
        setup.intent = "INTENT"
    
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', externalIdentifier: 'XYZ', store: 'STORE', display: 'DISPLAY', intent: 'INTENT', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentMetadataObjects() {
        setup.metadata = [:]

        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', metadata: {}, buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)

        setup.metadata = ["":""]

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', metadata: {}, buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.metadata = ["foo": "bar"]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', metadata: {foo: 'bar'}, buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.metadata = ["apples": "oranges", "foo": "bar"]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', metadata: {apples: 'oranges', foo: 'bar'}, buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentPaymentSources() {
        setup.paymentSource = .installment
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', paymentSource: 'installment', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.paymentSource = .recurring
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', paymentSource: 'recurring', buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentCartItems() {
        setup.cartItems = []
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', cartItems: [], buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Pot Plant", quantity: 1, unitAmount: 1299)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', cartItems: [{name: 'Pot Plant', quantity: 1, unitAmount: 1299}], buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Pot Plant", quantity: 1, unitAmount: 1299),
                           Gr4vyCartItem(name: "House Plant", quantity: 2, unitAmount: 2499)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', cartItems: [{name: 'Pot Plant', quantity: 1, unitAmount: 1299}, {name: 'House Plant', quantity: 2, unitAmount: 2499}], buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Pot Plant", quantity: -1, unitAmount: -1),
                           Gr4vyCartItem(name: "House Plant", quantity: 0, unitAmount: 0)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.ID123.gr4vy.app', apiUrl: 'https://api.ID123.gr4vy.app', token: 'TOKEN123', amount: 100, country: 'GB', currency: 'GBP', cartItems: [{name: 'Pot Plant', quantity: -1, unitAmount: -1}, {name: 'House Plant', quantity: 0, unitAmount: 0}], buyerId: 'BUYER123', supportedApplePayVersion: 5},})", sut)
    }
    
    func testApprovalURLSucceeds() {
        var payload: [String: Any] =  ["data": "https://api.ID123.gr4vy.app"]
        
        var sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertEqual(sut, URL(string: "https://api.ID123.gr4vy.app"))
        
        payload =  ["data": "https://api.ID123.gr4vy.app", "data2": "https://api.ID123.gr4vy.app"]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertEqual(sut, URL(string: "https://api.ID123.gr4vy.app"))
    }
    
    func testApprovalURLFails() {
        var payload: [String: Any] =  ["data": ""]
        
        var sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
        
        payload =  ["data": true]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
        
        payload =  ["data": 123]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
        
        payload =  [:]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
        
        payload =  ["dataa": "https://api.ID123.gr4vy.app"]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
        
        payload =  ["dataa": "https://api.ID123.gr4vy.app"]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
        
        payload =  ["data": "https://api.¬ID123.gr4vy.app"]
        
        sut = Gr4vyUtility.handleApprovalUrl(from: payload)
        XCTAssertNil(sut)
    }

    func testHandleTransactionCreatedSucceeds() {
        var payload: [String: Any] =  [:]
        
        var sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        
        payload = ["data": ["status": "capture_succeeded", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_succeeded", paymentMethodID: nil), sut)
        
        payload = ["data": ["status": "capture_succeeded", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_succeeded", paymentMethodID: "ABC"), sut)
        
        payload = ["data": ["status": "capture_pending", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_pending", paymentMethodID: nil) , sut)
        
        payload = ["data": ["status": "capture_pending", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_pending", paymentMethodID: "ABC") , sut)
        
        payload = ["data": ["status": "authorization_succeeded", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_succeeded", paymentMethodID: nil) , sut)
        
        payload = ["data": ["status": "authorization_succeeded", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_succeeded", paymentMethodID: "ABC") , sut)
        
        payload = ["data": ["status": "authorization_succeeded", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_succeeded", paymentMethodID: nil) , sut)
        
        payload = ["data": ["status": "authorization_pending", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_pending", paymentMethodID: "ABC") , sut)
    }
    
    func testHandleTransactionCreatedFails() {
        var payload: [String: Any] =  [:]
        
        var sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: Pop up transaction created failed.") , sut)
        
        payload = ["data": [:]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: Pop up transaction created failed.") , sut)
        
        payload = ["data": 123]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: Pop up transaction created failed.") , sut)
        
        payload = ["data": ["status": 123]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: Pop up transaction created failed.") , sut)
        
        payload = ["data": ["status": 123]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: Pop up transaction created failed.") , sut)
    
        payload = ["data": ["status": "capture_declined"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found") , sut)
        
        payload = ["data": ["status": "authorization_failed"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found") , sut)
        
        payload = ["data": ["status": "newStatus"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found") , sut)
        
        payload = ["data": ["status": "capture_declined", "paymentMethodID": ""]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found") , sut)
        
        payload = ["data": ["status": "authorization_failed", "paymentMethodID": ""]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found") , sut)
        
        payload = ["data": ["status": "newStatus", "paymentMethodID": ""]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found") , sut)
        
        payload = ["data": ["status": "newStatus", "paymentMethodID": "paymentID", "id": "transactionID"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "transactionID", status: "newStatus", paymentMethodID: "paymentID") , sut)
        
        payload = ["data": ["status": "authorization_failed", "paymentMethodID": "paymentID", "id": "transactionID"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "transactionID", status: "authorization_failed", paymentMethodID: "paymentID") , sut)
        
        payload = ["data": ["status": "capture_declined", "paymentMethodID": "paymentID", "id": "transactionID"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "transactionID", status: "capture_declined", paymentMethodID: "paymentID") , sut)
    }
    
    func testHandleTransactionUpdatedSucceeds() {
        var payload: [String: Any] =  ["data": "123"]
        
        var sut = Gr4vyUtility.handleTransactionUpdated(from: payload)
        XCTAssertEqual("window.postMessage({\"data\":\"123\"})", sut)
        
        payload = [:]
        
        sut = Gr4vyUtility.handleTransactionUpdated(from: payload)
        XCTAssertEqual("window.postMessage({})", sut)
    }
    
    func testHandleTransactionUpdatedFails() {
        let payload: [String: Any] =  ["": String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)!]
        
        let sut = Gr4vyUtility.handleTransactionUpdated(from: payload)
        XCTAssertNil(sut)
    }
    
    func testHandlePaymentSelectedSucceeds() {
        var payload: [String: Any] =  ["data": ["id": "123", "method": "method", "mode": "mode"]]
        
        var sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertEqual(Gr4vyEvent.paymentMethodSelected(id: "123", method: "method", mode: "mode"), sut)
        
        payload = ["data": ["id": "123", "method": "method", "mode": "mode"], "data2": "https://api.ID123.gr4vy.app"]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertEqual(Gr4vyEvent.paymentMethodSelected(id: "123", method: "method", mode: "mode"), sut)
        
        payload = ["data": ["method": "method", "mode": "mode"], "data2": "https://api.ID123.gr4vy.app"]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertEqual(Gr4vyEvent.paymentMethodSelected(id: nil, method: "method", mode: "mode"), sut)
        
        payload  =  ["data": ["method": "method", "mode": "mode"]]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertEqual(Gr4vyEvent.paymentMethodSelected(id: nil, method: "method", mode: "mode"), sut)
    }
    
    func testHandlePaymentSelectedFails() {
        var payload: [String: Any] =  [:]
        
        var sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertNil(sut)
        
        payload  =  ["data": ["id": "123", "method": "method"]]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertNil(sut)
        
        payload  =  ["data": ["id": "123", "mode": "mode"]]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertNil(sut)
        
        payload  =  ["data": [:]]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertNil(sut)
        
        payload  =  ["dataa": ["id": "123", "method": "method", "mode": "mode"]]

        sut = Gr4vyUtility.handlePaymentSelected(from: payload)
        XCTAssertNil(sut)
    }
    
}

extension gr4vy_iOSTests {
    
    private func generateSetup() -> Gr4vySetup {
        Gr4vySetup(gr4vyId: "ID123", token: "TOKEN123", amount: 100, currency: "GBP", country: "GB", buyerId: "BUYER123", environment: .production, externalIdentifier: nil, store: nil, display: nil, intent: nil)
    }
}
