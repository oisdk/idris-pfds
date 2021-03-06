module Data.LazyList

%default total
%access public export

data LazyListCell a = Nil | (::) a (Lazy (LazyListCell a))

LazyList : Type -> Type
LazyList a = Lazy (LazyListCell a)

appendLL : LazyList a -> LazyList a -> LazyList a
appendLL xs ys =
  Delay $ case xs of
    Nil => ys
    (x::xs') => x::(appendLL xs' ys)

(++) : LazyList a -> LazyList a -> LazyList a
(++) = appendLL -- trying to define (++) directly leads to an error

implementation Semigroup (LazyList a) where
  (<+>) = (++)

implementation Monoid (LazyList a) where
  neutral = Nil

implementation Functor LazyListCell where
  map f Nil = Nil
  map f (x :: xs) =
    f x :: Delay (map f xs)

fromStrictList : List a -> LazyList a
fromStrictList Nil = Nil
fromStrictList (x::xs) = x::(fromStrictList xs)

toStrictList : LazyList a -> List a
toStrictList (Delay Nil) = Nil
toStrictList (Delay (x::xs)) = x::(toStrictList xs)

countdown : Nat -> LazyList Nat
countdown Z = [Z]
countdown (S n) = (S n)::(countdown n)

takeLL : Nat -> LazyList a -> LazyList a
takeLL Z _ = Nil
takeLL (S n) (Delay xs) = Delay $
  case xs of
    Nil => Nil
    (x::xs') => x::(takeLL n xs')

take : Nat -> LazyList a -> LazyList a
take = takeLL -- trying to define `take` directly leads to an error

ack' : Nat -> Nat -> Nat
ack'    Z     m  = S m
ack' (S n)    Z  = ack' n (S Z)
ack' (S n) (S m) = ack' n (ack' (S n) m)

ack : Nat -> Nat
ack n = ack' n n

example : LazyList Nat
example = [1,2,3,4,5,6,7,8]

firstThreeAckValues : List Nat
firstThreeAckValues = toStrictList $ Data.LazyList.take 3 $ map ack example
