# L-Systems
Haskell implementation of [L-systems](https://en.wikipedia.org/wiki/L-system)

![L-Système plante](https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Plante_g%C3%A9n%C3%A9r%C3%A9e_%C3%A0_l'aide_d'un_L-Syst%C3%A8me.svg/1280px-Plante_g%C3%A9n%C3%A9r%C3%A9e_%C3%A0_l'aide_d'un_L-Syst%C3%A8me.svg.png)

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
