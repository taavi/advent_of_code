#!/bin/env python3

with open("input.txt") as f:
    moves = [l.strip() for l in f.readlines()]

guide = {
  "A X": 3 + 0,
  "A Y": 1 + 3,
  "A Z": 2 + 6,
  "B X": 1 + 0,
  "B Y": 2 + 3,
  "B Z": 3 + 6,
  "C X": 2 + 0,
  "C Y": 3 + 3,
  "C Z": 1 + 6
}

score = sum(guide[l] for l in moves)

print(score)
