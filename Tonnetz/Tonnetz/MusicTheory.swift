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
  static var aMinorTriad = Note.a | Note.c | Note.e
  static var aMajorTriad = Note.a | Note.csharp | Note.e

  static var bflatMinorTriad = Note.bflat | Note.csharp | Note.f
  static var bflatMajorTriad = Note.bflat | Note.d | Note.f

  static var bMinorTriad = Note.b | Note.d | Note.fsharp
  static var bMajorTriad = Note.b | Note.eflat | Note.fsharp

  static var cMinorTriad = Note.c | Note.eflat | Note.g
  static var cMajorTriad = Note.c | Note.e | Note.g

  static var csharpMinorTriad = Note.csharp | Note.e | Note.gsharp
  static var csharpMajorTriad = Note.csharp | Note.f | Note.gsharp

  static var dMinorTriad = Note.d | Note.f | Note.a
  static var dMajorTriad = Note.d | Note.fsharp | Note.a

  static var eflatMinorTriad = Note.eflat | Note.fsharp | Note.bflat
  static var eflatMajorTriad = Note.eflat | Note.g | Note.bflat

  static var eMinorTriad = Note.e | Note.g | Note.b
  static var eMajorTriad = Note.e | Note.gsharp | Note.b

  static var fMinorTriad = Note.f | Note.gsharp | Note.c
  static var fMajorTriad = Note.f | Note.a | Note.c

  static var fsharpMinorTriad = Note.fsharp | Note.a | Note.csharp
  static var fsharpMajorTriad = Note.fsharp | Note.bflat | Note.csharp

  static var gMinorTriad = Note.g | Note.bflat | Note.d
  static var gMajorTriad = Note.g | Note.b | Note.d

  static var gsharpMinorTriad = Note.gsharp | Note.b | Note.eflat
  static var gsharpMajorTriad = Note.gsharp | Note.c | Note.eflat

  static var triads = [
    aMinorTriad, aMajorTriad, bflatMinorTriad, bflatMajorTriad, bMinorTriad, bMajorTriad, cMinorTriad, cMajorTriad,
    csharpMinorTriad, csharpMajorTriad, dMinorTriad, dMajorTriad, eflatMinorTriad, eflatMajorTriad, eMinorTriad, eMajorTriad,
    fMinorTriad, fMajorTriad, fsharpMinorTriad, fsharpMajorTriad, gMinorTriad, gMajorTriad, gsharpMinorTriad, gsharpMajorTriad
  ]
}


typealias Scale = UInt16
extension Scale {
  static var cMajorScale = Note.c | Note.d | Note.e | Note.f | Note.g | Note.a | Note.b
  static var csharpMajorScale = Note.csharp | Note.eflat | Note.f | Note.fsharp | Note.gsharp | Note.bflat | Note.c
  static var dMajorScale = Note.d | Note.e | Note.fsharp | Note.g | Note.a | Note.b | Note.csharp
  static var eflatMajorScale = Note.eflat | Note.f | Note.g | Note.gsharp | Note.bflat | Note.c | Note.d
  static var eMajorScale = Note.e | Note.fsharp | Note.gsharp | Note.a | Note.b | Note.csharp | Note.eflat
  static var fMajorScale = Note.f | Note.g | Note.a | Note.bflat | Note.c | Note.d | Note.e
  static var fsharpMajorScale = Note.fsharp | Note.gsharp | Note.bflat | Note.b | Note.csharp | Note.eflat | Note.f
  static var gMajorScale = Note.g | Note.a | Note.b | Note.c | Note.d | Note.e | Note.fsharp
  static var gsharpMajorScale = Note.gsharp | Note.bflat | Note.c | Note.csharp | Note.eflat | Note.f | Note.g
  static var aMajorScale = Note.a | Note.b | Note.csharp | Note.d | Note.e | Note.fsharp | Note.gsharp
  static var bflatMajorScale = Note.bflat | Note.c | Note.d | Note.eflat | Note.f | Note.g | Note.a
  static var bMajorScale = Note.b | Note.csharp | Note.eflat | Note.e | Note.fsharp | Note.gsharp | Note.bflat
}
