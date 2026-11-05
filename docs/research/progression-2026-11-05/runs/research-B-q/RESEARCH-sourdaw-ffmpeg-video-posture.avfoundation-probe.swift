import AVFoundation
import CoreVideo
func run(_ codec: AVVideoCodecType, _ ext: String) {
  let url = URL(fileURLWithPath: "/tmp/rq-exercise/out-\(codec.rawValue).\(ext)")
  try? FileManager.default.removeItem(at: url)
  let w = try! AVAssetWriter(outputURL: url, fileType: .mov)
  let settings: [String: Any] = [AVVideoCodecKey: codec, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080]
  let canApply = w.canApply(outputSettings: settings, forMediaType: .video)
  let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
  let ad = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: 1920, kCVPixelBufferHeightKey as String: 1080])
  w.add(input); w.startWriting(); w.startSession(atSourceTime: .zero)
  for i in 0..<24 {
    while !input.isReadyForMoreMediaData { usleep(1000) }
    var pb: CVPixelBuffer?; CVPixelBufferPoolCreatePixelBuffer(nil, ad.pixelBufferPool!, &pb)
    CVPixelBufferLockBaseAddress(pb!, []); memset(CVPixelBufferGetBaseAddress(pb!), Int32(i*10 % 255), CVPixelBufferGetDataSize(pb!)); CVPixelBufferUnlockBaseAddress(pb!, [])
    ad.append(pb!, withPresentationTime: CMTime(value: CMTimeValue(i), timescale: 24))
  }
  input.markAsFinished()
  let sem = DispatchSemaphore(value: 0); w.finishWriting { sem.signal() }; sem.wait()
  // decode back
  let asset = AVURLAsset(url: url)
  let track = asset.tracks(withMediaType: .video).first!
  let r = try! AVAssetReader(asset: asset)
  let out = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
  r.add(out); r.startReading(); var n = 0
  while out.copyNextSampleBuffer() != nil { n += 1 }
  let fourcc = CMFormatDescriptionGetMediaSubType(track.formatDescriptions.first as! CMFormatDescription)
  let fc = String(bytes: [UInt8((fourcc>>24)&255),UInt8((fourcc>>16)&255),UInt8((fourcc>>8)&255),UInt8(fourcc&255)], encoding: .ascii)!
  let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size]) ?? 0
  print("codec=\(codec.rawValue) canApply=\(canApply) writerStatus=\(w.status.rawValue) err=\(String(describing: w.error)) fourcc=\(fc) bytes=\(size) decodedFrames=\(n) readerStatus=\(r.status.rawValue)")
}
run(.proRes422Proxy, "mov"); run(.proRes422, "mov"); run(.h264, "mov"); run(.hevc, "mov")
