import Data.List
import Data.Maybe
import Text.Read
import System.Environment

data Ctx = Ctx {
                angle :: Float, -- current angle
                alpha :: Float, -- angle incrementation
                pos :: (Float, Float), -- current position on the canvas
                viewbox :: (Float, Float, Float, Float), -- canvas size
                linelen :: Float, -- length of lines
                saved :: [Ctx], -- saved positions
                svg :: ShowS -- svg path string
               }


defaultCtx = Ctx {
  angle = 0,
  alpha = pi/2,
  pos = (0,0),
  viewbox = (0,0,0,0),
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
  (minx, miny, w, h) = viewbox ctx
  in addSvg ctx {
                  pos = (newx,newy),
                  viewbox=(min minx newx, min miny newy, max w newx, max h newy)
                 } "l" (dx,dy)

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
              (minx, miny, maxx, maxy) = viewbox ctx
              (w,h) = (maxx-minx+20, maxy-miny+20)
              path = svg ctx ""
           in concat [
              "<svg\n",
                "xmlns=\"http://www.w3.org/2000/svg\" ",
                "xmlns:xlink=\"http://www.w3.org/1999/xlink\"\n",
                "viewBox=\"",
                    show (minx-10), " ", show (miny-10), " ",
                    show w, " ", show h, "\"\n",
                "width=\"700\" height=\"700\" >\n",
              "<path fill=\"none\" stroke=\"black\" d=\"\nM0,0\n",
                path, "\" />\n",
              "</svg>"]

main = do
  source <- getContents
  args <- getArgs
  let angle_g = fromMaybe 90 $ case args of
                                  [sn] -> readMaybe sn
                                  _    -> Nothing
  putStrLn $ turtle defaultCtx {alpha = angle_g*pi/180} source
