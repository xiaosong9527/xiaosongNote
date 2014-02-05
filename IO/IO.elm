module IO.IO where

data IOF a = PutC Char a

data IO a = Pure a
          | Impure (IOF (IO a))

mapF : (a -> b) -> IOF a -> IOF b
mapF f iof = case iof of
  PutC p x -> PutC p (f x)

map : (a -> b) -> IO a -> IO b
map f io = case io of
  Pure   a   -> Pure (f a)
  Impure iof -> Impure (mapF (map f) iof)

pure : a -> IO a
pure = Pure

bind : IO a -> (a -> IO b) -> IO b
bind io f = case io of
  Pure x     -> f x
  Impure iof -> Impure (mapF (flip bind f) iof)

(>>=) : IO a -> (a -> IO b) -> IO b
(>>=) = bind

foldIO : (a -> b) -> (IOF b -> b) -> IO a -> b
foldIO pur impur io = case io of
  Pure   x   -> pur x
  Impure iof -> impur (mapF (foldIO pur impur) iof)

-- | User-facing API
putChar : Char -> IO ()
putChar c = Impure (PutC c (Pure ()))