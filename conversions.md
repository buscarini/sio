# SIO

## R

### Void => R

.require(R.self)

	SIO<Void, E, A> => SIO<R, E, A>

### R => Void

.provide(r)

	SIO<R, E, A> => SIO<Void, E, A>


## E

### E => Void

.constError(())

	SIO<R, E, A> => SIO<R, Void, A>

### Void => E

.constError(e)

	SIO<R, Void, A> => SIO<R, E, A>

### E => Never

.optional() 

	SIO<R, E, A> -> SIO<R, Never, A?>

.catch(a)

	SIO<R, E, A> -> SIO<R, Never, A>

.result()

	SIO<R, E, A> -> SIO<R, Never, Result<A, E>>

.fold((E) -> B, (A) -> B)

	SIO<R, E, A> -> SIO<R, Never, B>

### Never => E

.mapError(absurd)

	SIO<R, Never, A> -> SIO<R, E, A>


## A

### A => Void

.discard

	SIO<R, E, A> => SIO<R, E, Void>

### Void => A

.const(a)

	SIO<R, E, Void> => SIO<R, E, A>

### Never => A

.map(absurd)

	SIO<R, E, Never> => SIO<R, E, A>

## Funciones

### SIO<R, E, A> => (R) -> SIO<Void, E, A>

	{ r in sio.provide(r) }

### (R) -> SIO<Void, E, A> => SIO<R, E, A>

SIO.fromFunc

