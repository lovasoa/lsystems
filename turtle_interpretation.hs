import Data.List

data Ctx = Ctx {
                angle :: Float,
                alpha :: Float,
                pos :: (Float, Float),
                size :: Float,
                saved :: [Ctx],
                svg :: ShowS
               }


svg_start = unlines [
              "<svg ",
                "xmlns=\"http://www.w3.org/2000/svg\" ",
                "xmlns:xlink=\"http://www.w3.org/1999/xlink\"> ",
              "<path fill=\"none\" stroke=\"black\" d=\"M10,10"]
svg_end = "\n\" />\n</svg>"

defaultCtx = Ctx {
  angle = 0,
  alpha = pi/2,
  pos = (0,0),
  size = 100,
  saved = [],
  svg = showString ""
}

addSvg :: Ctx -> String -> (Float, Float) -> Ctx
addSvg ctx command (x,y) = ctx { svg = (svg ctx) . showString (command ++ (show x) ++ "," ++ (show y) ++ "\n")}

interpret :: Ctx -> Char -> Ctx
interpret ctx 'F' = let
  l = size ctx
  a = angle ctx
  (x,y) = (l*cos(a), l*sin(a))
  (x', y') = pos ctx
  in addSvg ctx {pos = (x'+x, y'+y)} "l" (x,y)

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

path :: String -> String
path = ($"") . svg . foldl' interpret defaultCtx

turtle :: String -> String
turtle s = svg_start ++ (path s) ++ svg_end

main = do
  source <- getContents
  putStrLn $ unlines $ map turtle $ lines source
