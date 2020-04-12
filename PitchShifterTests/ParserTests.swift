//
//  ParserTests.swift
//  PitchShifterTests
//
//  Created by David Solis on 4/8/20.
//  Copyright © 2020 David Solis. All rights reserved.
//

import XCTest
import os.log
@testable import PitchShifter

class ParserTests: XCTestCase {
    
    func testParseDownloadedMP3() {
        let expectation = XCTestExpectation(description: "Download & Parse MP3")
        
        let url = RemoteFileURL.theLastOnes.mp3
        Downloader.shared.url = url
        Downloader.shared.start()
        
        var parserOrNil: Parser?
        do {
            parserOrNil = try Parser()
        } catch {
            XCTFail("Could not create parser")
            return
        }
        
        guard let parser = parserOrNil else {
            XCTFail("Did not create parser")
            return
        }
        
        Downloader.shared.progressHandler = { (data, progress) in
            try! parser.parse(data: data)
        }
        
        Downloader.shared.completionHandler = {
            XCTAssertEqual(Downloader.shared.state, .completed)
            XCTAssertNil($0)
            
            XCTAssertNotEqual(parser.dataFormat, nil)
            XCTAssertEqual(parser.packets.count, 6897)
            
            expectation.fulfill()
        }
        XCTAssertEqual(Downloader.shared.state, .started)
        
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testParseDownloadedAAC() {
        let expectation = XCTestExpectation(description: "Download & Parse AAC")
        
        let url = RemoteFileURL.theLastOnes.aac
        Downloader.shared.url = url
        Downloader.shared.start()
        
        var parserOrNil: Parser?
        do {
            parserOrNil = try Parser()
        } catch {
            XCTFail("Could not create parser")
            return
        }
        
        guard let parser = parserOrNil else {
            XCTFail("Did not create parser")
            return
        }
        
        Downloader.shared.progressHandler = { (data, progress) in
            try! parser.parse(data: data)
        }
        
        Downloader.shared.completionHandler = {
            XCTAssertEqual(Downloader.shared.state, .completed)
            XCTAssertNil($0)
            
            XCTAssertNotEqual(parser.dataFormat, nil)
            XCTAssertEqual(parser.packets.count, 3881)
            
            expectation.fulfill()
        }
        XCTAssertEqual(Downloader.shared.state, .started)
        
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testParseDownloadedWAV() {
        let expectation = XCTestExpectation(description: "Download & Parse WAV")
        
        let url = RemoteFileURL.theLastOnes.wav
        Downloader.shared.url = url
        Downloader.shared.start()
        
        var parserOrNil: Parser?
        do {
            parserOrNil = try Parser()
        } catch {
            XCTFail("Could not create parser")
            return
        }
        
        guard let parser = parserOrNil else {
            XCTFail("Did not create parser")
            return
        }
        
        Downloader.shared.progressHandler = { (data, progress) in
            try! parser.parse(data: data)
        }
        
        Downloader.shared.completionHandler = {
            XCTAssertEqual(Downloader.shared.state, .completed)
            XCTAssertNil($0)
            
            XCTAssertNotEqual(parser.dataFormat, nil)
            XCTAssertEqual(parser.packets.count, 3971520)
            
            expectation.fulfill()
        }
        XCTAssertEqual(Downloader.shared.state, .started)
        
        self.wait(for: [expectation], timeout: 30)
    }
    
}
