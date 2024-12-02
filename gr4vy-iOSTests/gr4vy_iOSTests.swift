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
        XCTAssertEqual("https://embed.ID123.gr4vy.app/mobile?channel=123", sut?.url?.absoluteString)
    }
    
    func testUtilityGetInitialURLCorrectlyFormsSandboxURL() {
        setup.environment = .sandbox
        setup.gr4vyId = "ID123"
        
        let sut = Gr4vyUtility.getInitialURL(from: setup)
        XCTAssertEqual("https://embed.sandbox.ID123.gr4vy.app/mobile?channel=123", sut?.url?.absoluteString)
    }
    
    func testUtilityGetInitialURLReturnsNilURL() {
        setup.environment = .production
        setup.gr4vyId = ""
        
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
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.buyerId = nil
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSetupCorrectForApplePay() {
        setup.environment = .production
        setup.gr4vyId = "ID123"
        setup.buyerId = "BUYER123"
        setup.token = "TOKEN123"
        setup.amount = 100
        setup.country = "GB"
        setup.currency = "GBP"
        
        setup.applePayMerchantId = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.applePayMerchantId = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.applePayMerchantId = "ABC"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":5,\"token\":\"TOKEN123\"}})", sut)
        
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentAmounts() {
        setup.amount = 1000
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":1000,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.amount = 1
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":1,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.amount = -1
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":-1,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.amount = 0
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":0,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.amount = 2147483647 // Int.max
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":2147483647,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentExternalIdentifiers() {
        setup.externalIdentifier = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.externalIdentifier = "ABC"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"externalIdentifier\":\"ABC\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.externalIdentifier = "123456789"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"externalIdentifier\":\"123456789\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.externalIdentifier = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"externalIdentifier\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentIntent() {
        setup.intent = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.intent = "ABC"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"intent\":\"ABC\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.intent = "authorize"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"intent\":\"authorize\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.intent = "capture"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"intent\":\"capture\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.intent = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"intent\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentStore() {
        setup.store = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.store = .ask
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"store\":\"ask\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.store = .true
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"store\":true,\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.store = .false
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"store\":false,\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentDisplay() {
        setup.display = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = "ABC"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"ABC\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = "all"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"all\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = "addOnly"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"addOnly\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = "storedOnly"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"storedOnly\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = "supportsTokenization"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"supportsTokenization\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentOptionalInput() {
        setup.display = nil
        setup.store = nil
        setup.intent = nil
        setup.externalIdentifier = nil
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.externalIdentifier = ""
        setup.store = nil
        setup.display = ""
        setup.intent = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"\",\"externalIdentifier\":\"\",\"intent\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.externalIdentifier = ""
        setup.store = nil
        setup.display = ""
        setup.intent = nil
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"\",\"externalIdentifier\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.externalIdentifier = "XYZ"
        setup.store = .ask
        setup.display = "DISPLAY"
        setup.intent = "INTENT"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"display\":\"DISPLAY\",\"externalIdentifier\":\"XYZ\",\"intent\":\"INTENT\",\"store\":\"ask\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.display = nil
        setup.store = nil
        setup.intent = nil
        setup.externalIdentifier = nil
        
        setup.merchantAccountId = "merchantAccountId"
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"merchantAccountId\":\"merchantAccountId\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentMetadataObjects() {
        setup.metadata = [:]
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"metadata\":{},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.metadata = ["":""]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"metadata\":{\"\":\"\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.metadata = ["foo": "bar"]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"metadata\":{\"foo\":\"bar\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.metadata = ["apples": "oranges", "foo": "bar"]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"metadata\":{\"apples\":\"oranges\",\"foo\":\"bar\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentPaymentSources() {
        setup.paymentSource = .installment
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"paymentSource\":\"installment\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.paymentSource = .recurring
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"paymentSource\":\"recurring\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithDifferentCartItems() {
        setup.cartItems = []
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Pot Plant", quantity: 1, unitAmount: 1299)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[{\"discountAmount\":0,\"name\":\"Pot Plant\",\"quantity\":1,\"taxAmount\":0,\"unitAmount\":1299}],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Pot Plant", quantity: 1, unitAmount: 1299),
                           Gr4vyCartItem(name: "House Plant", quantity: 2, unitAmount: 2499)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[{\"discountAmount\":0,\"name\":\"Pot Plant\",\"quantity\":1,\"taxAmount\":0,\"unitAmount\":1299},{\"discountAmount\":0,\"name\":\"House Plant\",\"quantity\":2,\"taxAmount\":0,\"unitAmount\":2499}],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Pot Plant", quantity: -1, unitAmount: -1),
                           Gr4vyCartItem(name: "House Plant", quantity: 0, unitAmount: 0)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[{\"discountAmount\":0,\"name\":\"Pot Plant\",\"quantity\":-1,\"taxAmount\":0,\"unitAmount\":-1},{\"discountAmount\":0,\"name\":\"House Plant\",\"quantity\":0,\"taxAmount\":0,\"unitAmount\":0}],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "Backlava's", quantity: -1, unitAmount: -1),
                           Gr4vyCartItem(name: "House Plant", quantity: 0, unitAmount: 0)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[{\"discountAmount\":0,\"name\":\"Backlava's\",\"quantity\":-1,\"taxAmount\":0,\"unitAmount\":-1},{\"discountAmount\":0,\"name\":\"House Plant\",\"quantity\":0,\"taxAmount\":0,\"unitAmount\":0}],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        
        setup.cartItems = [Gr4vyCartItem(name: "\\", quantity: -1, unitAmount: -1),
                           Gr4vyCartItem(name: "House Plant", quantity: 0, unitAmount: 0)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[{\"discountAmount\":0,\"name\":\"\\\\\",\"quantity\":-1,\"taxAmount\":0,\"unitAmount\":-1},{\"discountAmount\":0,\"name\":\"House Plant\",\"quantity\":0,\"taxAmount\":0,\"unitAmount\":0}],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.cartItems = [Gr4vyCartItem(name: "\"", quantity: -1, unitAmount: -1),
                           Gr4vyCartItem(name: "House Plant", quantity: 0, unitAmount: 0)]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"cartItems\":[{\"discountAmount\":0,\"name\":\"\\\"\",\"quantity\":-1,\"taxAmount\":0,\"unitAmount\":-1},{\"discountAmount\":0,\"name\":\"House Plant\",\"quantity\":0,\"taxAmount\":0,\"unitAmount\":0}],\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithTheme() {
        setup.theme = Gr4vyTheme()
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{},\"token\":\"TOKEN123\"}})", sut)
        
        
        setup.theme = Gr4vyTheme(fonts: Gr4vyFonts(body: ""))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"fonts\":{\"body\":\"\"}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(colors: Gr4vyColours(text: "#ffffff"))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"colors\":{\"text\":\"#ffffff\"}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(borderWidths: Gr4vyBorderWidths(container: "container"))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"borderWidths\":{\"container\":\"container\"}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(borderWidths: Gr4vyBorderWidths(input: "input"))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"borderWidths\":{\"input\":\"input\"}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(radii: Gr4vyRadii())
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"radii\":{}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(radii: Gr4vyRadii(input: "input"))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"radii\":{\"input\":\"input\"}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(radii: Gr4vyRadii(container: "container"))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"radii\":{\"container\":\"container\"}},\"token\":\"TOKEN123\"}})", sut)
        
        setup.theme = Gr4vyTheme(shadows: Gr4vyShadows(focusRing: "focusRing"))
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"theme\":{\"shadows\":{\"focusRing\":\"focusRing\"}},\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGr4vyThemeNavigationBackgroundColor() {
        var theme = Gr4vyTheme(colors: Gr4vyColours(headerBackground: "#ffffff"))
        
        var sut = theme.navigationBackgroundColor
        XCTAssertNotNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours(headerBackground: "#000000"))
        
        sut = theme.navigationBackgroundColor
        XCTAssertNotNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours(headerBackground: "#00000012"))
        
        sut = theme.navigationBackgroundColor
        XCTAssertNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours())
        
        sut = theme.navigationBackgroundColor
        XCTAssertNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours(headerText: "#ffffff"))
        
        sut = theme.navigationTextColor
        XCTAssertNotNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours(headerText: "#000000"))
        
        sut = theme.navigationTextColor
        XCTAssertNotNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours(headerText: "#00000012"))
        
        sut = theme.navigationTextColor
        XCTAssertNil(sut)
        
        theme = Gr4vyTheme(colors: Gr4vyColours())
        
        sut = theme.navigationTextColor
        XCTAssertNil(sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithBuyerExternalIdentifier() {
        setup.buyerExternalIdentifier = "ID"
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerExternalIdentifier\":\"ID\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.buyerExternalIdentifier = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerExternalIdentifier\":\"\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithLocale() {
        setup.locale = "EN"
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"locale\":\"EN\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.locale = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"locale\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithStatementDescriptor() {
        setup.statementDescriptor = Gr4vyStatementDescriptor()
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.statementDescriptor = Gr4vyStatementDescriptor(name: "name")
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{\"name\":\"name\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.statementDescriptor = Gr4vyStatementDescriptor(description: "description")
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{\"description\":\"description\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.statementDescriptor = Gr4vyStatementDescriptor(phoneNumber: "phoneNumber")
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{\"phoneNumber\":\"phoneNumber\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.statementDescriptor = Gr4vyStatementDescriptor(city: "city")
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{\"city\":\"city\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.statementDescriptor = Gr4vyStatementDescriptor(url: "url")
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{\"url\":\"url\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.statementDescriptor = Gr4vyStatementDescriptor(name: "name", description: "description", phoneNumber: "phoneNumber", city: "city", url: "url")
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"statementDescriptor\":{\"city\":\"city\",\"description\":\"description\",\"name\":\"name\",\"phoneNumber\":\"phoneNumber\",\"url\":\"url\"},\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithRequireSecurityCode() {
        setup.requireSecurityCode = true
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"requireSecurityCode\":true,\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.requireSecurityCode = false
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"requireSecurityCode\":false,\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testGenerateUpdateOptionsSucceedsWithShippingDetailsId() {
        setup.shippingDetailsId = "shippingDetailsId"
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"shippingDetailsId\":\"shippingDetailsId\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.shippingDetailsId = ""
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"country\":\"GB\",\"currency\":\"GBP\",\"shippingDetailsId\":\"\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
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
    }
    
    func testHandleTransactionCreatedSucceeds() {
        var payload: [String: Any] =  [:]
        
        var sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        
        payload = ["data": ["status": "capture_succeeded", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_succeeded", paymentMethodID: nil, approvalUrl: nil), sut)
        
        payload = ["data": ["status": "capture_succeeded", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_succeeded", paymentMethodID: "ABC", approvalUrl: nil), sut)
        
        payload = ["data": ["status": "capture_pending", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_pending", paymentMethodID: nil, approvalUrl: nil) , sut)
        
        payload = ["data": ["status": "capture_pending", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "capture_pending", paymentMethodID: "ABC", approvalUrl: nil) , sut)
        
        payload = ["data": ["status": "authorization_succeeded", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_succeeded", paymentMethodID: nil, approvalUrl: nil) , sut)
        
        payload = ["data": ["status": "authorization_succeeded", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_succeeded", paymentMethodID: "ABC", approvalUrl: nil) , sut)
        
        payload = ["data": ["status": "authorization_succeeded", "id": "123"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_succeeded", paymentMethodID: nil, approvalUrl: nil) , sut)
        
        payload = ["data": ["status": "authorization_pending", "id": "123", "paymentMethodID": "ABC"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_pending", paymentMethodID: "ABC", approvalUrl: nil) , sut)
        
        payload = ["data": ["status": "authorization_pending", "id": "123", "paymentMethodID": "ABC", "paymentMethod": ["approvalUrl": "123"]]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_pending", paymentMethodID: "ABC", approvalUrl: "123"), sut)
        
        payload = ["data": ["status": "authorization_pending", "id": "123", "paymentMethodID": "ABC", "paymentMethod": []]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionCreated(transactionID: "123", status: "authorization_pending", paymentMethodID: "ABC", approvalUrl: nil), sut)
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
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "", status: "capture_declined", paymentMethodID: nil) , sut)
        
        payload = ["data": ["status": "authorization_failed"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "", status: "authorization_failed", paymentMethodID: nil) , sut)
        
        payload = ["data": ["status": "newStatus"]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "", status: "newStatus", paymentMethodID: nil) , sut)
        
        payload = ["data": ["status": "capture_declined", "paymentMethodID": ""]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "", status: "capture_declined", paymentMethodID: "") , sut)
        
        payload = ["data": ["status": "authorization_failed", "paymentMethodID": ""]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "", status: "authorization_failed", paymentMethodID: "") , sut)
        
        payload = ["data": ["status": "newStatus", "paymentMethodID": ""]]
        
        sut = Gr4vyUtility.handleTransactionCreated(from: payload)
        XCTAssertEqual(Gr4vyEvent.transactionFailed(transactionID: "", status: "newStatus", paymentMethodID: "") , sut)
        
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
    
    func testHandleNavigationUpdateSucceeds() {
        var payload: [String: Any] =  ["data": ["title": "title", "canGoBack": true]]
        
        var sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertEqual(Gr4vyUtility.NavigationUpdate(title: "title", canGoBack: true), sut)
        
        payload = ["data": ["title": "title", "canGoBack": false]]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertEqual(Gr4vyUtility.NavigationUpdate(title: "title", canGoBack: false), sut)
        
        payload = ["data": ["title": "", "canGoBack": false]]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertEqual(Gr4vyUtility.NavigationUpdate(title: "", canGoBack: false), sut)
    }
    
    func testHandleNavigationUpdateFails() {
        var payload: [String: Any] =  ["data": ["title": "title", "canGoBack": 1]]
        
        var sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertNil(sut)
        
        payload = ["data": ["title": "title",]]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertNil(sut)
        
        payload = ["data": ["canGoBack": false]]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertNil(sut)
        
        payload = ["title": "title", "canGoBack": 1]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertNil(sut)
        
        payload = ["dataa": ["title": "title", "canGoBack": true]]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertNil(sut)
        
        payload = ["data": ["title": "title", "canGoBack": "true"]]
        
        sut = Gr4vyUtility.handleNavigationUpdate(from: payload)
        XCTAssertNil(sut)
    }
    
    func testHandleAppleStartSucceeds() {
        var payload: [String: Any] = ["data": ["countryCode": "countryCode", "currencyCode": "currencyCode", "total": ["label": "label", "amount": "123"]]]
        let merchantId: String = "merchantID"
        
        var sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNotNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNotNil(sut)
        
        payload = ["data": ["supportedNetworks": ["VISA", "MASTERCARD"], "countryCode": "countryCode", "currencyCode": "currencyCode", "total": ["label": "label", "amount": "123"]]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNotNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNotNil(sut)
    }
    
    func testHandleAppleStartFails() {
        var payload: [String: Any] = ["data": ["countryCode": "countryCode", "currencyCode": "currencyCode", "total": ["label": "label", "amount": "123"]]]
        let merchantId: String = "merchantID"
        
        var sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNotNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNotNil(sut)
        
        payload = ["data": ["currencyCode": "currencyCode", "total": ["label": "label", "amount": "123"]]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNil(sut)
        
        payload = ["data": ["countryCode": "countryCode", "total": ["label": "label", "amount": "123"]]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNil(sut)
        
        payload = ["data": []]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNil(sut)
        
        payload = ["data": ["countryCode": "countryCode", "currencyCode": "currencyCode"]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNil(sut)
        
        payload = ["data": ["countryCode": "countryCode", "currencyCode": "currencyCode", "total": ["amount": "123"]]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNotNil(sut)
        
        payload = ["data": ["countryCode": "countryCode", "currencyCode": "currencyCode", "total": ["label": "label"]]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNil(sut)
        
        payload = ["data": ["countryCode": "countryCode", "currencyCode": "currencyCode", "total": []]]
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: nil)
        XCTAssertNil(sut)
        
        sut = Gr4vyUtility.handleAppleStartSession(from: payload, merchantId: merchantId, merchantName: "Test")
        XCTAssertNil(sut)
    }
    
    func testGenerateAppleCompleteSessionSucceeds() {
        let sut = Gr4vyUtility.generateAppleCompleteSession()
        XCTAssertEqual("window.postMessage({ channel: 123, type: 'appleCompleteSession'})", sut)
    }
    
    func testGenerateAppleCancelSessionSucceeds() {
        let sut = Gr4vyUtility.generateAppleCancelSession()
        XCTAssertEqual("window.postMessage({ channel: 123, type: 'appleCancelSession'})", sut)
    }
    
    func testGenerateApprovalCancelledSucceeds() {
        let sut = Gr4vyUtility.generateApprovalCancelled()
        XCTAssertEqual("window.postMessage({ channel: 123, type: 'approvalCancelled'})", sut)
    }
    
    func testGenerateNavigationBackSucceeds() {
        let sut = Gr4vyUtility.generateNavigationBack()
        XCTAssertEqual("window.postMessage({ channel: 123, type: 'navigationBack'})", sut)
    }
    
    func testOpenLink() {
        var payload: [String: Any] = ["data": ["url": "https://gr4vy.com"]]
        
        var sut = Gr4vyUtility.handleOpenLink(from: payload)
        XCTAssertNotNil(sut)
        
        payload = [:]
        
        sut = Gr4vyUtility.handleOpenLink(from: payload)
        XCTAssertNil(sut)
        
        payload = ["data": ""]
        
        sut = Gr4vyUtility.handleOpenLink(from: payload)
        XCTAssertNil(sut)
        
        payload = ["data": ["url": ""]]
        
        sut = Gr4vyUtility.handleOpenLink(from: payload)
        XCTAssertNil(sut)
        
        payload = ["data": ["url": "gr4vy.com"]]
        
        sut = Gr4vyUtility.handleOpenLink(from: payload)
        XCTAssertNotNil(sut)
    }
    
    func testConnectionOptionsEncoding() {
        
        let permutations: [[String: [String: Gr4vyConnectionOptionsValue]]] = [
            ["key1": ["subKey1":  .string("value1")]],
            ["key1": ["subKey1": .int(1)]],
            ["key1": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .int(1), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1), "subKey3": .bool(true)]],
            ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .int(1)]],
            ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .int(1)], "key2": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)], "key2": ["subKey1": .int(1), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)], "key2": ["subKey1": .int(1), "subKey2": .string("value2")]],
            ["key1": ["subKey1": .dictionary(["key1": "value1"])]],
        ]
        
        for permutation in permutations {
            setup.connectionOptions = permutation
            let sut = Gr4vyUtility.generateUpdateOptions(from: setup)
            XCTAssertFalse(sut.isEmpty)
        }
    }
    
    func testGenerateUpdateOptionsSucceedsWithConnectionOptionsPermutations() {
        
        struct ConnectionOptionsTestWrapper {
            var input: [String: [String: Gr4vyConnectionOptionsValue]]
            var expectedOutput: String
        }
        
        let permutations: [ConnectionOptionsTestWrapper] = [
            ConnectionOptionsTestWrapper(input: ["key1": ["subKey1": .string("value1")]], expectedOutput: "\"connectionOptions\":{\"key1\":{\"subKey1\":\"value1\"}"),
            ConnectionOptionsTestWrapper(input: ["key1": ["subKey1": .int(1)]], expectedOutput: "\"connectionOptions\":{\"key1\":{\"subKey1\":1}"),
            ConnectionOptionsTestWrapper(input: ["key1": ["subKey1": .bool(true)]], expectedOutput: "\"connectionOptions\":{\"key1\":{\"subKey1\":true}"),
        ]
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        
        for permutation in permutations {
            setup.connectionOptions = permutation.input
            sut = Gr4vyUtility.generateUpdateOptions(from: setup)
            XCTAssertTrue(sut.contains(permutation.expectedOutput))
        }
        
        setup.connectionOptions = [
            "adyen-card": ["additionalData": .string("value")]
        ]
        
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"connectionOptions\":{\"adyen-card\":{\"additionalData\":\"value\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.connectionOptions =  [
            "cybersource-anti-fraud": ["merchant_defined_data": .string("value")]
        ]
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"connectionOptions\":{\"cybersource-anti-fraud\":{\"merchant_defined_data\":\"value\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.connectionOptions =  [
            "cybersource-anti-fraud": ["merchant_defined_data": .dictionary(["key": "value"])]
        ]
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"connectionOptions\":{\"cybersource-anti-fraud\":{\"merchant_defined_data\":{\"key\":\"value\"}}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.connectionOptions = [:]
        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyerId\":\"BUYER123\",\"connectionOptions\":{},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
    
    func testConnectionOptionsInUtilityWhenProvidedValidConnectionOptions() {
        
        let permutations: [[String: [String: Gr4vyConnectionOptionsValue]]] = [
            ["key1": ["subKey1":  .string("value1")]],
            ["key1": ["subKey1": .int(1)]],
            ["key1": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .int(1), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1), "subKey3": .bool(true)]],
            ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .int(1)]],
            ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .int(1)], "key2": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)], "key2": ["subKey1": .int(1), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)], "key2": ["subKey1": .int(1), "subKey2": .string("value2")]],
            ["key1": ["subKey1": .dictionary(["key1": "value1"])]],
        ]
        
        for permutation in permutations {
            XCTAssertEqual(Gr4vyUtility.getConnectionOptions(from: permutation, connectionOptionsString: nil), permutation)
        }
    }
    
    func testConnectionOptionsInUtilityWhenProvidedValidConnectionOptionStrings() {

      let permutations: [[String: [String: Gr4vyConnectionOptionsValue]]] = [
        ["key1": ["subKey1": .string("value1")]],
        ["key1": ["subKey1": .int(1)]],
        ["key1": ["subKey1": .bool(true)]],
        ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)]],
        ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)]],
        ["key1": ["subKey1": .int(1), "subKey2": .bool(true)]],
        ["key1": ["subKey1": .string("value1"), "subKey2": .int(1), "subKey3": .bool(true)]],
        ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .int(1)]],
        ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .bool(true)]],
        ["key1": ["subKey1": .int(1)], "key2": ["subKey1": .bool(true)]],
        [
          "key1": ["subKey1": .string("value1"), "subKey2": .int(1)],
          "key2": ["subKey1": .int(1), "subKey2": .bool(true)],
        ],
        [
          "key1": ["subKey1": .string("value1"), "subKey2": .bool(true)],
          "key2": ["subKey1": .int(1), "subKey2": .string("value2")],
        ],
      ]

      let stringPermutations: [String] = [
        """
        {
          "key1" : {
            "subKey1" : "value1"
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : 1
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1",
            "subKey2" : 1
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1",
            "subKey2" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : 1,
            "subKey2" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1",
            "subKey2" : 1,
            "subKey3" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1"
          },
          "key2" : {
            "subKey1" : 1
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1"
          },
          "key2" : {
            "subKey1" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : 1
          },
          "key2" : {
            "subKey1" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1",
            "subKey2" : 1
          },
          "key2" : {
            "subKey1" : 1,
            "subKey2" : true
          }
        }
        """,
        """
        {
          "key1" : {
            "subKey1" : "value1",
            "subKey2" : true
          },
          "key2" : {
            "subKey1" : 1,
            "subKey2" : "value2"
          }
        }
        """,
      ]

      for (index, stringPermuation) in stringPermutations.enumerated() {
        XCTAssertEqual(
          Gr4vyUtility.getConnectionOptions(from: nil, connectionOptionsString: stringPermuation),
          permutations[index])
      }
    }
    
    func testConnectionOptionsInUtilityWhenProvidedValidConnectionOptionsAndConnectionOptionStrings() {
        
        let permutations: [[String: [String: Gr4vyConnectionOptionsValue]]] = [
            ["key1": ["subKey1":  .string("value1")]],
            ["key1": ["subKey1": .int(1)]],
            ["key1": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .int(1), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1), "subKey3": .bool(true)]],
            ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .int(1)]],
            ["key1": ["subKey1": .string("value1")], "key2": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .int(1)], "key2": ["subKey1": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .int(1)], "key2": ["subKey1": .int(1), "subKey2": .bool(true)]],
            ["key1": ["subKey1": .string("value1"), "subKey2": .bool(true)], "key2": ["subKey1": .int(1), "subKey2": .string("value2")]]
        ]
        
        for permutation in permutations {
            XCTAssertEqual(Gr4vyUtility.getConnectionOptions(from: permutation, connectionOptionsString:    "{\"keyA\":{\"subKeyA\":\"valueA\"}}"), permutation)
        }
    }

    func testGenerateUpdateOptionsSucceedsWithBuyer() {
        setup.buyerId = nil
        setup.buyer = Gr4vyBuyer()
        
        var sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
        
        setup.buyer = Gr4vyBuyer(displayName: "displayName", externalIdentifier: "externalIdentifier")

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"displayName\":\"displayName\",\"externalIdentifier\":\"externalIdentifier\"},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(billingDetails: Gr4vyBillingDetails(firstName: "firstName"))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"billingDetails\":{\"firstName\":\"firstName\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(billingDetails: Gr4vyBillingDetails(lastName: "lastName"))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"billingDetails\":{\"lastName\":\"lastName\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(billingDetails: Gr4vyBillingDetails(emailAddress: "emailAddress"))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"billingDetails\":{\"emailAddress\":\"emailAddress\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(billingDetails: Gr4vyBillingDetails(phoneNumber: "phoneNumber"))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"billingDetails\":{\"phoneNumber\":\"phoneNumber\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(billingDetails: Gr4vyBillingDetails(address: Gr4vyAddress(houseNumberOrName: "houseNumberOrName", line1: "line1", line2: "line2", organization: "organization", city: "city", postalCode: "postalCode", country: "country", state: "state", stateCode: "stateCode")))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"billingDetails\":{\"address\":{\"city\":\"city\",\"country\":\"country\",\"houseNumberOrName\":\"houseNumberOrName\",\"line1\":\"line1\",\"line2\":\"line2\",\"organization\":\"organization\",\"postalCode\":\"postalCode\",\"state\":\"state\",\"stateCode\":\"stateCode\"}}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(billingDetails: Gr4vyBillingDetails(taxId: Gr4vyTaxId(value: "value", kind: "kind")))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"billingDetails\":{\"taxId\":{\"kind\":\"kind\",\"value\":\"value\"}}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)

        setup.buyer = Gr4vyBuyer(shippingDetails: Gr4vyShippingDetails(firstName: "firstName", lastName: "lastName", address: Gr4vyAddress(houseNumberOrName: "houseNumberOrName", line1: "line1", line2: "line2", organization: "organization", city: "city", postalCode: "postalCode", country: "country", state: "state", stateCode: "stateCode")))

        sut = Gr4vyUtility.generateUpdateOptions(from: setup)
        XCTAssertEqual("window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": {\"amount\":100,\"apiHost\":\"api.ID123.gr4vy.app\",\"apiUrl\":\"https:\\/\\/api.ID123.gr4vy.app\",\"buyer\":{\"shippingDetails\":{\"address\":{\"city\":\"city\",\"country\":\"country\",\"houseNumberOrName\":\"houseNumberOrName\",\"line1\":\"line1\",\"line2\":\"line2\",\"organization\":\"organization\",\"postalCode\":\"postalCode\",\"state\":\"state\",\"stateCode\":\"stateCode\"},\"firstName\":\"firstName\",\"lastName\":\"lastName\"}},\"country\":\"GB\",\"currency\":\"GBP\",\"supportedApplePayVersion\":0,\"token\":\"TOKEN123\"}})", sut)
    }
}

extension gr4vy_iOSTests {
    
    private func generateSetup() -> Gr4vySetup {
        Gr4vySetup(gr4vyId: "ID123", token: "TOKEN123", amount: 100, currency: "GBP", country: "GB", buyerId: "BUYER123", environment: .production, externalIdentifier: nil, store: nil, display: nil, intent: nil)
    }
}
