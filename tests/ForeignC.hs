module ForeignC(main) where
import Foreign.C.Types
import Foreign.Ptr
import Foreign.Storable
import Foreign.Marshal.Alloc (mallocBytes)
import Data.Word (Word8)

foreign import ccall "errno.h &errno" cerrno :: IO (Ptr CInt)
foreign import ccall "unistd.h getpid" getpid :: IO CInt
foreign import capi  "value 3+4" seven :: CInt
foreign import ccall labs :: CLong -> CLong
-- Polymorphic imports: a generated stub (memset), and a runtime function (free).
foreign import ccall "string.h memset" c_memset :: Ptr a -> CInt -> CSize -> IO (Ptr a)
foreign import ccall "free" c_free :: Ptr a -> IO ()

main :: IO ()
main = do
  let CLong r = labs (-33)
  print r
  CInt pid <- getpid
  print (pid /= 0)
  p <- cerrno
  CInt e <- peek p
  print e
  print (let CInt x = seven in x)
  q <- mallocBytes 4
  _ <- c_memset q 7 4
  b <- peek (castPtr q :: Ptr Word8)
  print b
  c_free q
