//
//  Reader.swift
//  PitchShifter
//
//  Created by David Solis on 4/5/20.
//  Copyright © 2020 David Solis. All rights reserved.
//

import AVFoundation

/// The `Reader` is a concrete implementation of the `Reading` protocol and is intended to provide the audio data provider for an `AVAudioEngine`.
/// The `parser` property provides a `Parseable` that handles converting binary audio data into audio packets in whatever the original file's format was
/// (MP3, AAC, WAV, etc). The reader handles converting the audio data coming from the parser to a LPCM format that can be used in the context of
/// `AVAudioEngine` since the `AVAudioPlayerNode` requires we provide `AVAudioPCMBuffer` in the `scheduleBuffer` methods.
class Reader: Reading {
    
    // MARK: - Properties
    
    let parser: Parsing
    /// A `DispatchQueue` used to ensure any operations we do changing the current packet index is thread-safe
    let readFormat: AVAudioFormat
    let queue = DispatchQueue(label: "co.peaking.pitch_shifter")
    // TODO: - Use AVAudioConverter to convert audio file formats
    /// An `AudioConverterRef` used to do the conversion from the source format of the `parser` (i.e. the `sourceFormat`) to the read destination
    /// (i.e. the `destinationFormat`). This is provided by the Audio Conversion Services (I prefer it to the `AVAudioConverter`)
    var converter: AudioConverterRef? = nil
    var currentPacket: AVAudioPacketCount = 0
    
    // MARK: - Lifecycle
        
    required init(parser: Parsing, readFormat: AVAudioFormat) throws {
        self.parser = parser
        
        guard let dataFormat = parser.dataFormat else {
            throw ReaderError.parserMissingDataFormat
        }

        let sourceFormat = dataFormat.streamDescription
        let commonFormat = readFormat.streamDescription
        let result = AudioConverterNew(sourceFormat, commonFormat, &converter)
        guard result == noErr else {
            throw ReaderError.unableToCreateConverter(result)
        }
        self.readFormat = readFormat
    }
    
    deinit {
        guard AudioConverterDispose(converter!) == noErr else {
            fatalError("Failed to dispose of audio converter")
        }
    }
    
    // MARK: - Methods
    
    func read(_ frames: AVAudioFrameCount) throws -> AVAudioPCMBuffer {
        let framesPerPacket = readFormat.streamDescription.pointee.mFramesPerPacket
        var packets = frames / framesPerPacket
        
        /// Allocate a buffer to hold the target audio data in the Read format
        guard let buffer = AVAudioPCMBuffer(pcmFormat: readFormat, frameCapacity: frames) else {
            throw ReaderError.failedToCreatePCMBuffer
        }
        buffer.frameLength = frames
        
        // Try to read the frames from the parser
        try queue.sync {
            let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
            let status = AudioConverterFillComplexBuffer(converter!, ReaderConverterCallback, context, &packets, buffer.mutableAudioBufferList, nil)
            guard status == noErr else {
                switch status {
                case ReaderMissingSourceFormatError:
                    throw ReaderError.parserMissingDataFormat
                case ReaderReachedEndOfDataError:
                    throw ReaderError.reachedEndOfFile
                case ReaderNotEnoughDataError:
                    throw ReaderError.notEnoughData
                default:
                    throw ReaderError.converterFailed(status)
                }
            }
        }
        return buffer
    }
    
    func seek(_ packet: AVAudioPacketCount) throws {
        queue.sync {
            currentPacket = packet
        }
    }
}
