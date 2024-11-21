---
title: Strange Playstation 2 Assembler
date: 2024-08-24
author: Tom Marks
draft: true
...

## A Strange Quest

Sometimes love of a video game can drive you to do strange things. The world of 
modding old console games is filled with unnatural programming horrors, the likes
of which no human should encounter. This is the story of modding gone wrong, and
what happens when you disagree with your assembler.

This is the story of writing a randomizer for Kingdom Hearts on the Playstation 2.
Even more, writing it in assembly, with everything needing to fit within the 4Kb of spare 
memory that I noticed the BIOS forgot to use.

## Genesis

I have been hacking on tools to unpack and repack Kingdom Hearts disk images for
a few months. I have found huge success unpacking, changing the index, repacking.
I am able to modify file sizes, decompress and recompress assets, and even view
a few images in specific easy to decode formats. There is also a lot of data I
have not been able to make sense of.

One thing I found fairly easily was where the chest and reward tables for the game
live. Every time you open a chest, the item you are given is based on an entry
in the chest table. When you complete certain game objectives, you are given
items or abilities based on the rewards table. The chest table lives inside
the main binary for the game, it is literally hard-coded. The rewards table
naturally lives in an entirely different location, a mysterious binary file called
`btltbl.bin` which I always seem to edit wrong and end up making all of the
enemies in the game die in 2 hits. 

Rearranging the chests and rewards leads to the creation of some kind of game
_randomizer_, which adds replayability by shuffling the game around and forcing
you to play in different ways. One drawback with unpacking and repacking the game
to achieve this is that each new randomization (each new _seed_) is a 3.4Gb ISO.
Copying gigabytes of data for rearranging data less than a kilobyte in size is
slighly excessive, and I felt very dirty for doing it.

## A Better Way

What if the randomizer ran was embedded as a part of the game binary? What if we
could hook into the main loop of the game, and run some extra code to do unintended
things? So began my journey into the depths of ELF headers, PS2 binary loading quirks,
and a solution so disgusting it will require its own blog post in the future. A small
spoiler for the curious -- the PS2 has
no memory protection, so if I can add extra ELF headers I can make the binary loader
write any data I want anywhere, including into a region of the BIOS memory that is
unused. There are _so many_ extra things that made this more complex than it sounds.

For today, assume that we can load a random binary blob, modify a function call in the 
game's main loop to jump there, then after running my custom code and cleaned up 
continue with the function call that was hooked. This all works reasonably consistently,
as long as you respect a few housekeeping rules such as leaving the registers `v0`, `v1`, `a0` 
and most importantly `ra` as you found them. Also _do not patch in a binary more than 4Kb_ because
after that point you will override the entrypoint of the executable and beyond.

So I wrote the most basic thing I could to randomize the chests in the game. It 
looked something like this:

```asm

addiu $sp, $sp, 4
sw $ra, 0($sp)

li $t0, CHEST_TABLE_OFFSET
li $t1, CHEST_TABLE_END

loop:
jal xorshift # xorshift puts a random number in $t7
nop
andi $t2, $t7, 0xff # t2 has a random number 0-255
sll $t2, $t2, 4 # a chest table entry to give an item has a 0 in the lower nibble, then a 1 byte item id
sh $t2, 0($t0)
addiu $t0, $t0, 2
# t2 = end addr - current addr (eg t2 <= 0 until we reach the end)
sub $t2, $t0, $t1
blez $t2, loop
nop

lw $ra, 0($sp)
addi $sp, $sp, -4
```

I have left out the implementation of `xorshift` because it is not interesting. I ran this and 
it worked, despite generating some garbage items and populating many chest table entries that do
not correspond to anything you can reach in the game. If I want a smarter randomizer that generates seeds that
are winnable, I need to know which chest table indexes correspond to obtainable chests.
Thankfully there are lists online[^1] that seem to map every table index to a location in the
game, which show that ~half or more of the entries are unused.

## Finding The Next Entry

My first thought was to use some kind of RLE to compress this data for a simple walk. Looking 
at a random section of the file:

```
14d Mega-Potion     ; Coliseum Gates
14e Dalmatians 8    ; Coliseum Gates ; Blue Trinity
14f Reward 55       ; Coliseum Gates ; Blue Trinity
150 Reward 56       ; Coliseum Gates ; White Trinity
151 Gummi           ; Coliseum Gates ; Blizzara Magic
152 Reward 9a       ; Coliseum Gates ; Blizzaga Magic
153 Potion          ; ? ; ?
154 Potion          ; ? ; ?
155 Potion          ; ? ; ?
156 Potion          ; ? ; ?
157 Potion          ; ? ; ?
158 Potion          ; ? ; ?
159 Potion          ; ? ; ?
15a Potion          ; ? ; ?
15b Reward 27       ; Monstro: Mouth
15c Cottage         ; Monstro: Mouth ; High Jump OR Glide
15d Dalmatians 25   ; Monstro: Mouth ; High Jump OR Glide
15e Scan-G          ; Monstro: Mouth
15f Reward 57       ; Monstro: Mouth ; High Jump OR Glide ; Green Trinity
160 Potion          ; ? ; ?
161 Potion          ; ? ; ?
162 Potion          ; ? ; ?
163 Cottage         ; Chamber 2
164 Megalixir       ; Chamber 2
165 Potion          ; ? ; ?
166 Potion          ; ? ; ?
167 Potion          ; ? ; ?
168 Potion          ; ? ; ?
169 Potion          ; ? ; ?
16a Mythril         ; Chamber 5
16b Mega-Ether      ; Chamber 3
16c Dalmatians 19   ; Chamber 3
16d Osmose-G        ; Chamber 3
16e Flare-G         ; Chamber 3
16f Potion          ; ? ; ?
170 Potion          ; ? ; ?
171 Potion          ; ? ; ?
172 Potion          ; ? ; ?
173 Potion          ; ? ; ?
174 Potion          ; ? ; ?
```

This could be simplified as:

`6, 8, 5, 3, 2, 5, 5, 6, ...`

Or in human terms: "The next 6 elements are valid, then skip 8, then 5 valid, then skip 3, ...". A viewer in 
my Twitch chat suggested something even better though -- that this 479 entry table could be compressed into
480 bits, aka 15x 32-bit words. So I wrote some Python to crunch this file and spit out my final, beautiful bitmask, 
formatted for you enjoyment as a harmonious string of 32bit integers:

```
0xEFF00001,0x0000010F,0xFF000000,0x7C07DFF1,0x00007FF7,0x00000780,0xFFFFFFE0,0x003C03FF,
0x00000000,0x3FFF8000,0xF807EF00,0xFFE07C18,0xFFF80000,0x80FFF87F,0x7EFFCB1B
```

Now all I needed was some code which, given an index, produces the next valid index.

```
# assume t0 is the current place in the chest table
next_chest_index:
  addiu $t0, $t0, 1
  li $t7, 479
  sub $t7, $t7, $t0 # t7 = sizeof table (479) - current index
  # jump to some terminal label for now
  blez $t7, out_of_table
  # divide current index by 32
  addiu $t7, $zero, 32
  div $t0, $t7
  # quotient (LO) = index of word containing relevant bit
  mflo $t7
  addiu $t7, $t7, chest_bits # chest_bits is a label for our bitmask data
  lw $t7, 0($t7)
  # remainder (HI) = index of bit within word
  mfhi $t6
  li $t5, 1
  sllv $t5, $t5, $t6 # t5 is now our bit mask
  and $t7, $t7, $t5
  beq $t7, $zero, next_chest_index  # if no bits set, loop again
  nop
  j $ra
  nop
```

I built this, patched the binary, rebuilt a disk image, loaded PCSX2 and saw a black screen.
Something had hung forever. From a quick glance at the PCSX2 debugger, 
it was clear that this `next_chest_index` function 
never returned. Looking at the disassembly however, something was clearly wrong:

<img src="/img/2024ps2asm/pcsx2_dis.png" />

This was not the code I wrote. Suspecting that PCSX2 was being strange, I turned back to my
faithful, reliable GNU tools and examined my object file with `objdump -d`:

<img src="/img/2024ps2asm/objdump.png" />

I started to feel a familiar, sinking feeling in my stomach. PlayStation 2 development has
been full of strange, hard to resolve bugs. The tooling is sometimes lacking, and my knowledge
is limited. When something like this goes wrong it's hard to know if I am the problem, or if 
the PS2SDK build of GNU `as` has malfunctioned. Someone else must have encountered this before, right?

## Conclusion

I wish I had a satisfying conclusion to this :D The struggle continues.

[^1]: From KHPCSpeedrunTools repo: <https://raw.githubusercontent.com/Denhonator/KHPCSpeedrunTools/0856c6bbf76a4a4c1052295d82124eaabd5c6be2/1FMMods/randofiles/Chests.txt>
