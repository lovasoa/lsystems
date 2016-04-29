import System.Environment
import Text.ParserCombinators.ReadP
import Data.Char
import Data.Maybe
import Text.Read

data LSys = LSys {start :: String, replacements :: [(Char, String)]}
instance Show LSys where
  show = start

axiom :: ReadP String
axiom = munch (not . flip elem " \n}")

replacement :: ReadP (Char, String)
replacement = do
  from <- satisfy isAlphaNum
  skipSpaces
  char '='
  skipSpaces
  to <- axiom
  return (from, to)

lsys :: ReadP LSys
lsys = do
  skipSpaces
  optional $ munch isAlphaNum
  skipSpaces
  optional $ char '{'
  skipSpaces
  optional $ string "Axiom"
  skipSpaces
  start <- axiom
  skipSpaces
  replacements <- sepBy replacement skipSpaces
  skipSpaces
  char '}'
  skipSpaces
  return LSys {start = start, replacements = replacements}

parse :: String -> Maybe LSys
parse s = case readP_to_S lsys s of
            ((parsed, ""):l) -> Just parsed
            _ -> Nothing


replace :: [(Char, String)] -> String -> String
replace r = concatMap (\c -> fromMaybe [c] $ lookup c r)

do_step :: LSys -> LSys
do_step (LSys {start = s, replacements = r}) = 
  LSys {start = replace r s, replacements = r}

generations :: LSys -> [LSys]
generations = iterate do_step

main = do
  source <- getContents
  args <- getArgs
  case parse source of
    Just sys -> let lines = map show $ generations sys in
                  case args of
                    [sn] -> case readMaybe sn of
                             Just n -> putStrLn (lines !! n)
                             Nothing -> fail "Invalid argument"
                    _   -> putStrLn $ unlines lines
    Nothing -> fail "Invalid syntax"
