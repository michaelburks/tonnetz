//
//  MusicTheory.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/2/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

typealias Note = UInt16
extension Note {
  static var a =        1 << 0
  static var bflat =    1 << 1
  static var b =        1 << 2
  static var c =        1 << 3
  static var csharp =   1 << 4
  static var d =        1 << 5
  static var eflat =    1 << 6
  static var e =        1 << 7
  static var f =        1 << 8
  static var fsharp =   1 << 9
  static var g =        1 << 10
  static var gsharp =   1 << 11

  static var notes = [a, bflat, b, c, csharp, d, eflat, e, f, fsharp, g, gsharp]
}

typealias Chord = UInt16
extension Chord {
  static var aMinor = Note.a | Note.c | Note.e
  static var aMajor = Note.a | Note.csharp | Note.e

  static var bflatMinor = Note.bflat | Note.csharp | Note.f
  static var bflatMajor = Note.bflat | Note.d | Note.f

  static var bMinor = Note.b | Note.d | Note.fsharp
  static var bMajor = Note.b | Note.eflat | Note.fsharp

  static var cMinor = Note.c | Note.eflat | Note.g
  static var cMajor = Note.c | Note.e | Note.g

  static var csharpMinor = Note.csharp | Note.e | Note.gsharp
  static var csharpMajor = Note.csharp | Note.f | Note.gsharp

  static var dMinor = Note.d | Note.f | Note.a
  static var dMajor = Note.d | Note.fsharp | Note.a

  static var eflatMinor = Note.eflat | Note.fsharp | Note.bflat
  static var eflatMajor = Note.eflat | Note.g | Note.bflat

  static var eMinor = Note.e | Note.g | Note.b
  static var eMajor = Note.e | Note.gsharp | Note.b

  static var fMinor = Note.f | Note.gsharp | Note.c
  static var fMajor = Note.f | Note.a | Note.c

  static var fsharpMinor = Note.fsharp | Note.a | Note.csharp
  static var fsharpMajor = Note.fsharp | Note.bflat | Note.csharp

  static var gMinor = Note.g | Note.bflat | Note.d
  static var gMajor = Note.g | Note.b | Note.d

  static var gsharpMinor = Note.gsharp | Note.b | Note.eflat
  static var gsharpMajor = Note.gsharp | Note.c | Note.eflat

  static var triads = [
    aMinor, aMajor, bflatMinor, bflatMajor, bMinor, bMajor, cMinor, cMajor,
    csharpMinor, csharpMajor, dMinor, dMajor, eflatMinor, eflatMajor, eMinor, eMajor,
    fMinor, fMajor, fsharpMinor, fsharpMajor, gMinor, gMajor, gsharpMinor, gsharpMajor
  ]
}
