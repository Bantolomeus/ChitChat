module CircularList exposing (CircularList, get, next, single, take, fromList)


type CircularList a
    = CircularList a (() -> CircularList a)


single : a -> CircularList a
single x =
    fromList x []


fromList : a -> List a -> CircularList a
fromList x xs =
    let
        l =
            fromListLoop x xs (\() -> l)
    in
        l


fromListLoop : a -> List a -> (() -> CircularList a) -> CircularList a
fromListLoop x xs l =
    case xs of
        [] ->
            CircularList x l

        h :: t ->
            CircularList x (\() -> fromListLoop h t l)


get : CircularList a -> a
get (CircularList a n) =
    a


next : CircularList a -> CircularList a
next (CircularList a n) =
    n ()


take : Int -> CircularList a -> List a
take n (CircularList a na) =
    if n > 0 then
        a :: take (n - 1) (na ())
    else
        []
