# lsystems
Haskell implementation of [L-systems](https://en.wikipedia.org/wiki/L-system)

## Usage
#### Command
```
./lsystem < ./examples/algae.txt
```
#### Source format
Contents of `algae.txt`
```
Algae {
  Axiom A
  A = AB
  B = A
}
```

#### Result
```
A
AB
ABA
ABAAB
ABAABABA
ABAABABAABAAB
ABAABABAABAABABAABABA
ABAABABAABAABABAABABAABAABABAABAAB
...
```
(it never stops)
