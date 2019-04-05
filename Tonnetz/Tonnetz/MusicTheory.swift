//
//  MusicTheory.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/2/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

typealias NoteBit = UInt16
extension NoteBit {
  static var c =        1 << 0
  static var csharp =   1 << 1
  static var d =        1 << 2
  static var eflat =    1 << 3
  static var e =        1 << 4
  static var f =        1 << 5
  static var fsharp =   1 << 6
  static var g =        1 << 7
  static var gsharp =   1 << 8
  static var a =        1 << 9
  static var bflat =    1 << 10
  static var b =        1 << 11

  static var notes = [c, csharp, d, eflat, e, f, fsharp, g, gsharp, a, bflat, b]
}

typealias Chord = UInt16
extension Chord {
  static var cMinorTriad = NoteBit.c | NoteBit.eflat | NoteBit.g
  static var cMajorTriad = NoteBit.c | NoteBit.e | NoteBit.g

  static var csharpMinorTriad = NoteBit.csharp | NoteBit.e | NoteBit.gsharp
  static var csharpMajorTriad = NoteBit.csharp | NoteBit.f | NoteBit.gsharp

  static var dMinorTriad = NoteBit.d | NoteBit.f | NoteBit.a
  static var dMajorTriad = NoteBit.d | NoteBit.fsharp | NoteBit.a

  static var eflatMinorTriad = NoteBit.eflat | NoteBit.fsharp | NoteBit.bflat
  static var eflatMajorTriad = NoteBit.eflat | NoteBit.g | NoteBit.bflat

  static var eMinorTriad = NoteBit.e | NoteBit.g | NoteBit.b
  static var eMajorTriad = NoteBit.e | NoteBit.gsharp | NoteBit.b

  static var fMinorTriad = NoteBit.f | NoteBit.gsharp | NoteBit.c
  static var fMajorTriad = NoteBit.f | NoteBit.a | NoteBit.c

  static var fsharpMinorTriad = NoteBit.fsharp | NoteBit.a | NoteBit.csharp
  static var fsharpMajorTriad = NoteBit.fsharp | NoteBit.bflat | NoteBit.csharp

  static var gMinorTriad = NoteBit.g | NoteBit.bflat | NoteBit.d
  static var gMajorTriad = NoteBit.g | NoteBit.b | NoteBit.d

  static var gsharpMinorTriad = NoteBit.gsharp | NoteBit.b | NoteBit.eflat
  static var gsharpMajorTriad = NoteBit.gsharp | NoteBit.c | NoteBit.eflat

  static var aMinorTriad = NoteBit.a | NoteBit.c | NoteBit.e
  static var aMajorTriad = NoteBit.a | NoteBit.csharp | NoteBit.e

  static var bflatMinorTriad = NoteBit.bflat | NoteBit.csharp | NoteBit.f
  static var bflatMajorTriad = NoteBit.bflat | NoteBit.d | NoteBit.f

  static var bMinorTriad = NoteBit.b | NoteBit.d | NoteBit.fsharp
  static var bMajorTriad = NoteBit.b | NoteBit.eflat | NoteBit.fsharp

  static var triads = [
   cMinorTriad, cMajorTriad, csharpMinorTriad, csharpMajorTriad, dMinorTriad, dMajorTriad,
   eflatMinorTriad, eflatMajorTriad, eMinorTriad, eMajorTriad, fMinorTriad, fMajorTriad,
   fsharpMinorTriad, fsharpMajorTriad, gMinorTriad, gMajorTriad, gsharpMinorTriad, gsharpMajorTriad,
   aMinorTriad, aMajorTriad, bflatMinorTriad, bflatMajorTriad, bMinorTriad, bMajorTriad,
  ]
}


typealias Scale = UInt16
extension Scale {
  static var cMajorScale = NoteBit.c | NoteBit.d | NoteBit.e | NoteBit.f | NoteBit.g | NoteBit.a | NoteBit.b
  static var csharpMajorScale = NoteBit.csharp | NoteBit.eflat | NoteBit.f | NoteBit.fsharp | NoteBit.gsharp | NoteBit.bflat | NoteBit.c
  static var dMajorScale = NoteBit.d | NoteBit.e | NoteBit.fsharp | NoteBit.g | NoteBit.a | NoteBit.b | NoteBit.csharp
  static var eflatMajorScale = NoteBit.eflat | NoteBit.f | NoteBit.g | NoteBit.gsharp | NoteBit.bflat | NoteBit.c | NoteBit.d
  static var eMajorScale = NoteBit.e | NoteBit.fsharp | NoteBit.gsharp | NoteBit.a | NoteBit.b | NoteBit.csharp | NoteBit.eflat
  static var fMajorScale = NoteBit.f | NoteBit.g | NoteBit.a | NoteBit.bflat | NoteBit.c | NoteBit.d | NoteBit.e
  static var fsharpMajorScale = NoteBit.fsharp | NoteBit.gsharp | NoteBit.bflat | NoteBit.b | NoteBit.csharp | NoteBit.eflat | NoteBit.f
  static var gMajorScale = NoteBit.g | NoteBit.a | NoteBit.b | NoteBit.c | NoteBit.d | NoteBit.e | NoteBit.fsharp
  static var gsharpMajorScale = NoteBit.gsharp | NoteBit.bflat | NoteBit.c | NoteBit.csharp | NoteBit.eflat | NoteBit.f | NoteBit.g
  static var aMajorScale = NoteBit.a | NoteBit.b | NoteBit.csharp | NoteBit.d | NoteBit.e | NoteBit.fsharp | NoteBit.gsharp
  static var bflatMajorScale = NoteBit.bflat | NoteBit.c | NoteBit.d | NoteBit.eflat | NoteBit.f | NoteBit.g | NoteBit.a
  static var bMajorScale = NoteBit.b | NoteBit.csharp | NoteBit.eflat | NoteBit.e | NoteBit.fsharp | NoteBit.gsharp | NoteBit.bflat
}
