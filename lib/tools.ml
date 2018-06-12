module MkPrivateInt :
  functor (X : sig end) ->
  sig
    type t = private int
    val (+) : t -> t -> t
    val (-) : t -> t -> t
    val (/) : t -> t -> t
    val ( * ) : t -> t -> t
    val ( mod ) : t -> t -> t

    val int    : int -> t
    val to_int : t -> int
  end =
  functor (X : sig end) ->
  struct

    type t = int

    let (+) = (+)
    let (-) = (-)
    let (/) = (/)
    let ( * ) = ( * )
    let ( mod ) = ( mod )

    let int x = x
    let to_int x = x

  end
