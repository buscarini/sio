//
//  Application.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 21/12/2019.
//

import Foundation

public func |> <A, B>(_ a: A, _ f: (A) throws -> B) rethrows -> B {
	return try f(a)
}

/// Left-to-right, in-place function application.
///
/// - Parameters:
///   - a: A mutable value.
///   - f: An in-out function.
/// - Note: This function is commonly seen in operator form as "pipe-forward", `|>`.
public func |> <A>(_ a: inout A, _ f: (inout A) throws -> Void) rethrows {
	try f(&a)
}

/// Left-to-right, reference-mutable function application.
///
/// - Parameters:
///   - a: A mutable value.
///   - f: An function from `A` to `Void`.
/// - Returns: The result of `f` applied to `a`.
/// - Note: This function is commonly seen in operator form as "pipe-forward", `|>`.
@discardableResult
public func |> <A: AnyObject>(_ a: A, _ f: (A) throws -> Void) rethrows -> A {
	try f(a)
	return a
}

public func <| <A, B>(_ f: (A) throws -> B, _ a: A) rethrows -> B {
	return try f(a)
}

/// Left-to-right, in-place function application.
///
/// - Parameters:
///   - a: A mutable value.
///   - f: An in-out function.
/// - Note: This function is commonly seen in operator form as "pipe-forward", `|>`.
public func <| <A>(_ f: (inout A) throws -> Void, _ a: inout A) rethrows {
	try f(&a)
}

///// Left-to-right, value-mutable function application.
/////
///// - Parameters:
/////   - a: A value.
/////   - f: An in-out function.
///// - Returns: The result of `f` applied to `a`.
///// - Note: This function is commonly seen in operator form as "pipe-forward", `|>`.
//public func <| <A>(_ f: (inout A) throws -> Void, _ a: A) rethrows -> A {
//	var a = a
//	try f(&a)
//	return a
//}

/// Left-to-right, reference-mutable function application.
///
/// - Parameters:
///   - a: A mutable value.
///   - f: An function from `A` to `Void`.
/// - Returns: The result of `f` applied to `a`.
/// - Note: This function is commonly seen in operator form as "pipe-forward", `|>`.
@discardableResult
public func <| <A: AnyObject>(_ f: (A) throws -> Void, _ a: A) rethrows -> A {
	try f(a)
	return a
}

