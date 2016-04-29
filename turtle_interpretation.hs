import Data.List
import Data.Maybe
import Text.Read
import System.Environment

data Ctx = Ctx {
                angle :: Float, -- current angle
                alpha :: Float, -- angle incrementation
                pos :: (Float, Float), -- current position on the canvas
                size :: (Float, Float), -- canvas size
                linelen :: Float, -- length of lines
                saved :: [Ctx], -- saved positions
                svg :: ShowS -- svg path string
               }


defaultCtx = Ctx {
  angle = 0,
  alpha = pi/2,
  pos = (0,0),
  size = (0,0),
  linelen = 50,
  saved = [],
  svg = showString ""
}

addSvg :: Ctx -> String -> (Float, Float) -> Ctx
addSvg ctx command (x,y) = ctx { svg = (svg ctx) . showString (command ++ (show x) ++ "," ++ (show y) ++ "\n")}

interpret :: Ctx -> Char -> Ctx
interpret ctx 'F' = let
  l = linelen ctx
  a = angle ctx
  (dx,dy) = (l*cos(a), l*sin(a))
  (x, y) = pos ctx
  (newx, newy) = (x+dx, y+dy) 
  (w, h) = size ctx
  in addSvg ctx {pos = (newx,newy), size=(max w newx, max h newy)} "l" (dx,dy)

interpret ctx '-' = ctx {angle = alpha ctx + angle ctx}
interpret ctx '+' = ctx {angle = angle ctx - alpha ctx}
interpret ctx '|' = ctx {angle = angle ctx - pi}

interpret ctx '[' = ctx { saved = ctx:(saved ctx) }
interpret ctx ']' = case saved ctx of
                      (ctx':tail) ->
                        addSvg ctx {
                              saved = tail,
                              angle = angle ctx',
                              pos = pos ctx'
                            } "M" (pos ctx')
                      _ -> ctx

interpret ctx _ = ctx

turtle :: Ctx -> String -> String
turtle defaultCtx code = let
              ctx = foldl' interpret defaultCtx code
              (w',h') = size ctx
              (w,h) = (w'+20, h'+20)
              path = svg ctx ""
           in concat [
              "<svg ",
                "xmlns=\"http://www.w3.org/2000/svg\" ",
                "xmlns:xlink=\"http://www.w3.org/1999/xlink\" ",
                "width=\"", show w, "\" height=\"", show h, "\" >\n",
              "<g transform=\"translate(10,10)\">\n",
              "<path fill=\"none\" stroke=\"black\" d=\"\nM0,0\n",
                path, "\" />\n",
              "</g>\n</svg>"]

main = do
  source <- getContents
  args <- getArgs
  let angle_g = fromMaybe 90 $ case args of
                                  [sn] -> readMaybe sn
                                  _    -> Nothing
  putStrLn $ turtle defaultCtx {alpha = angle_g*pi/180} source
