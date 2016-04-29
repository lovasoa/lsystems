# Example L-Systems

## Generation

Images generated using
```bash
for i in examples/*txt; do ./lsystem 6 < "$i" | ./turtle_interpretation 90 > "$i.svg"; done
```
