//
//  Operators.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 30/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

// Pipe operator
infix operator <|: infixr0
infix operator |>: infixl1

// Composition
infix operator >>>: infixr9
infix operator <<<: infixr9

infix operator ?=: infixl0

// Semigroup
infix operator <>: infixr5
prefix operator <>
postfix operator <>

// Alt
infix operator <|>: infixl3

infix operator <&>: infixl3

infix operator <*>: ApplyPrecedence
