//
//  AudioPlayer.swift
//  Tonnetz
//
//  Created by Michael Burks on 3/31/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import AudioToolbox

protocol LiveMIDIHandlerDelegate: class {
  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8)
}

class LiveMIDIHandler {
  let audioComponent: MusicDeviceComponent
  weak var delegate: LiveMIDIHandlerDelegate?
  init(_ initMidiUnit: AudioUnit) {
    audioComponent = MusicDeviceComponent(initMidiUnit)
  }
}

struct MIDIHandlerRefs {
  var clientRef: MIDIClientRef
  var endpointRef: MIDIEndpointRef
}

class AudioPlayer {
  let sequence: MusicSequence
  let player: MusicPlayer
  let audio = MIDIAudioGraph()
  let midiHandlers: MIDIHandlerRefs
  var liveHandler: LiveMIDIHandler

  var MIDIdelegate: LiveMIDIHandlerDelegate? {
    get {
      return liveHandler.delegate
    }
    set {
      liveHandler.delegate = newValue
    }
  }

  init(midiURL: URL) {
    sequence = AudioPlayer.makeSequence(with: midiURL)
    player = AudioPlayer.makePlayer()

    liveHandler = LiveMIDIHandler(audio.samplerUnit)
    midiHandlers = AudioPlayer.makeNoteHandlers(liveHandlerRef: &liveHandler)

    MusicSequenceSetAUGraph(sequence, audio.graph).printIfError()

    MusicSequenceSetMIDIEndpoint(sequence, midiHandlers.endpointRef).printIfError()

    MusicPlayerSetSequence(player, sequence).printIfError()

    MusicPlayerSetPlayRateScalar(player, 2.0).printIfError()
    MusicPlayerPreroll(player).printIfError()
  }

  deinit {
    MusicPlayerStop(player).printIfError()
    DisposeMusicPlayer(player).printIfError()
    DisposeAUGraph(audio.graph).printIfError()
    DisposeMusicSequence(sequence).printIfError()
    MIDIClientDispose(midiHandlers.clientRef)
    MIDIEndpointDispose(midiHandlers.endpointRef)
  }

  private static func makeSequence(with midiURL: URL) -> MusicSequence {
    var sequence: MusicSequence?
    NewMusicSequence(&sequence).printIfError()
    MusicSequenceFileLoad(sequence!, midiURL as CFURL, .midiType, .smf_ChannelsToTracks).printIfError()
    return sequence!
  }

  private static func makePlayer() -> MusicPlayer {
    var player: MusicPlayer?
    NewMusicPlayer(&player).printIfError()
    return player!
  }

  private static func makeNoteHandlers(liveHandlerRef: UnsafeMutableRawPointer) -> MIDIHandlerRefs {

    let notifyProc: MIDINotifyProc = { (notif, info) in
      let message = MIDINotificationMessage(notifPtr: notif)
      print("MIDINotification: \(message)")
    }

    var clientRef: MIDIClientRef = 0
    MIDIClientCreate("myclient" as CFString, notifyProc, nil, &clientRef).printIfError()
    print("client: \(clientRef)")

    let readProc: MIDIReadProc = { (pktlistref, readProcRefCon, srcConnRefCon) in
      let opaque = OpaquePointer(readProcRefCon)
      let liveHandlerRef = UnsafePointer<LiveMIDIHandler>(opaque)!
      let handler = liveHandlerRef.pointee
      let pkts: MIDIPacketList = pktlistref.pointee

      var packet = pkts.packet
      for _ in 0..<pkts.numPackets {
        // Helpful explaination of the MIDI format.
        // https://ccrma.stanford.edu/~craig/articles/linuxmidi/misc/essenmidi.html
        let midiStatus = packet.data.0
        let midiCommand = midiStatus >> 4

        if (midiCommand == MIDICommand.on) {
          let note = packet.data.1 & 0x7F;
          let velocity = packet.data.2 & 0x7F;
          handler.delegate?.handleMIDIEvent(.on, note: note, velocity: velocity)
        } else if midiCommand == MIDICommand.off {
          let note = packet.data.1 & 0x7F;
          let velocity = UInt8(0);
          handler.delegate?.handleMIDIEvent(.off, note: note, velocity: velocity)
        }

        MusicDeviceMIDIEvent(handler.audioComponent, UInt32(packet.data.0), UInt32(packet.data.1), UInt32(packet.data.2), 0)
        packet = MIDIPacketNext(&packet).pointee
      }
    }

    var endpointRef: MIDIEndpointRef = 0
    MIDIDestinationCreate(clientRef, "mydestination" as CFString, readProc, liveHandlerRef, &endpointRef).printIfError()
    print("endpoint: \(endpointRef)")

    return MIDIHandlerRefs(clientRef: clientRef, endpointRef: endpointRef)
  }
}

extension AudioPlayer {
  func play() {
    MusicPlayerStart(player).printIfError()
  }

  func pause() {
    MusicPlayerStop(player).printIfError()
  }

  var isPlaying: Bool {
    get {
      var b = DarwinBoolean(false)
      MusicPlayerIsPlaying(player, &b).printIfError()
      return b.boolValue
    }
  }

}

extension OSStatus {
  func printIfError(_ msg: String = "", function: String = #function, line: Int = #line) {
    if self != OSStatus(noErr) {
      print("Error at line \(line) in \(function): \(self) \(msg)")
    }
  }
}

func MIDINotificationMessage(notifPtr: UnsafePointer<MIDINotification>) -> String {
  let opq = OpaquePointer(notifPtr)
  let msg = notifPtr.pointee

  switch msg.messageID {
  case .msgObjectAdded: do {
    let msgPtr = UnsafePointer<MIDIObjectAddRemoveNotification>(opq)
    let changeMsg = msgPtr.pointee
    let parent = changeMsg.parent
    let child = changeMsg.child
    return "MIDI Source/Destination Added: \(parent) -> \(child))"
    }
  case .msgObjectRemoved: do {
    let msgPtr = UnsafePointer<MIDIObjectAddRemoveNotification>(opq)
    let changeMsg = msgPtr.pointee
    let parent = changeMsg.parent
    let child = changeMsg.child
    return "MIDI Source/Destination Removed: \(parent) -> \(child))"
    }
  case .msgIOError: do {
    let msgPtr = UnsafePointer<MIDIIOErrorNotification>(opq)
    let errMsg: MIDIIOErrorNotification = msgPtr.pointee
    return "MIDI IO Error: \(errMsg.errorCode)"
    }
  case .msgPropertyChanged: do {
    let msgPtr = UnsafePointer<MIDIObjectPropertyChangeNotification>(opq)
    let changeMsg: MIDIObjectPropertyChangeNotification = msgPtr.pointee
    return "MIDI Property Changed: \(changeMsg.propertyName)"
    }
  case .msgSerialPortOwnerChanged: do {
    return "MIDI Serial Port Owner Changed"
    }
  case .msgSetupChanged: do {
    return "MIDI Setup Changed"
    }
  case .msgThruConnectionsChanged: do {
    return "MIDI Thru Connections Changed"
    }
  default:
    return "unknown"
  }
}

class MIDIAudioGraph {
  let graph: AUGraph
  let samplerUnit: AudioUnit
  let ioUnit: AudioUnit

  init() {
    var newGraph: AUGraph?
    NewAUGraph(&newGraph).printIfError()
    graph = newGraph!

    var samplerNode: AUNode = 0
    var cd: AudioComponentDescription = AudioComponentDescription(
      componentType: OSType(kAudioUnitType_MusicDevice),
      componentSubType: OSType(kAudioUnitSubType_Sampler),
      componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
      componentFlags: 0,
      componentFlagsMask: 0)

    AUGraphAddNode(graph, &cd, &samplerNode).printIfError()

    var ioNode: AUNode = 0
    var ioUnitDescription:AudioComponentDescription = AudioComponentDescription(
      componentType: OSType(kAudioUnitType_Output),
      componentSubType: OSType(kAudioUnitSubType_DefaultOutput),
      componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
      componentFlags: 0,
      componentFlagsMask: 0)
    AUGraphAddNode(graph, &ioUnitDescription, &ioNode).printIfError()

    var newSamplerUnit: AudioUnit?
    var newIOUnit: AudioUnit?

    AUGraphOpen(graph).printIfError()
    AUGraphNodeInfo(graph, samplerNode, nil, &newSamplerUnit).printIfError()
    AUGraphNodeInfo(graph, ioNode, nil, &newIOUnit).printIfError()

    samplerUnit = newSamplerUnit!
    ioUnit = newIOUnit!

    if let bankURL = Bundle.main.url(forResource: "Steinway", withExtension: "sf2") {
      var instdata = AUSamplerInstrumentData(fileURL: Unmanaged.passUnretained(bankURL as CFURL),
                                             instrumentType: UInt8(kInstrumentType_DLSPreset),
                                             bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                             bankLSB: UInt8(kAUSampler_DefaultBankLSB),
                                             presetID: 0)

      AudioUnitSetProperty(
        samplerUnit,
        UInt32(kAUSamplerProperty_LoadInstrument),
        UInt32(kAudioUnitScope_Global),
        0,
        &instdata,
        UInt32(MemoryLayout<AUSamplerInstrumentData>.size)).printIfError()
    }

    let samplerOutputElement:AudioUnitElement = 0
    let ioUnitOutputElement:AudioUnitElement = 0

    AUGraphConnectNodeInput(graph, samplerNode, samplerOutputElement,  ioNode, ioUnitOutputElement).printIfError()

    var outIsInitialized = DarwinBoolean(false)
    AUGraphIsInitialized(graph, &outIsInitialized).printIfError()
    if !outIsInitialized.boolValue {
      AUGraphInitialize(graph).printIfError()
    }

    var isRunning = DarwinBoolean(false)
    AUGraphIsRunning(graph, &isRunning).printIfError()
    if !isRunning.boolValue {
      AUGraphStart(graph).printIfError()
    }
  }
}
