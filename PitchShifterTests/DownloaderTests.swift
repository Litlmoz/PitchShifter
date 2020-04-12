//
//  DownloaderTests.swift
//  PitchShifterTests
//
//  Created by David Solis on 4/8/20.
//  Copyright © 2020 David Solis. All rights reserved.
//

import XCTest
@testable import PitchShifter

class DownloaderTests: XCTestCase {
    
    func testInitialState() {
        let url = RemoteFileURL.claire.mp3
        Downloader.shared.url = url
        XCTAssertEqual(Downloader.shared.url, url)
        XCTAssertEqual(Downloader.shared.progress, 0.0)
        XCTAssertEqual(Downloader.shared.totalBytesReceived, 0)
        XCTAssertEqual(Downloader.shared.totalBytesCount, 0)
        XCTAssertEqual(Downloader.shared.state, .notStarted)
    }
    
    func testDownloadMP3() {
        let expectation = XCTestExpectation(description: "Download MP3")
        
        let url = RemoteFileURL.theLastOnes.mp3
        Downloader.shared.url = url
        Downloader.shared.start()
        Downloader.shared.completionHandler = {
            XCTAssertEqual(Downloader.shared.state, .completed)
            XCTAssertNil($0)
            expectation.fulfill()
        }
        XCTAssertEqual(Downloader.shared.state, .started)
        
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testDownloadAAC() {
        let expectation = XCTestExpectation(description: "Download AAC")
        
        let url = RemoteFileURL.theLastOnes.aac
        Downloader.shared.url = url
        Downloader.shared.start()
        Downloader.shared.completionHandler = {
            XCTAssertEqual(Downloader.shared.state, .completed)
            XCTAssertNil($0)
            expectation.fulfill()
        }
        XCTAssertEqual(Downloader.shared.state, .started)
        
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testDownloadWAV() {
        let expectation = XCTestExpectation(description: "Download WAV")
        
        let url = RemoteFileURL.theLastOnes.wav
        Downloader.shared.url = url
        Downloader.shared.start()
        Downloader.shared.completionHandler = {
            XCTAssertEqual(Downloader.shared.state, .completed)
            XCTAssertNil($0)
            expectation.fulfill()
        }
        XCTAssertEqual(Downloader.shared.state, .started)
        
        self.wait(for: [expectation], timeout: 30)
    }
}

