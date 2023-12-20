---
title: ChatGPT Daydreams in Lisp
date: 2022-12-05
author: Tom Marks
...

I currently have COVID, so today seemed like a good day to throw inane prompts at the new [ChatGPT](https://openai.com/blog/chatgpt/) language model.
I was inspired by the post which [turned ChatGPT into a virtual machine](https://www.engraved.blog/building-a-virtual-machine-inside/).

## Deviating From Linux

Simulating a realistic Linux terminal is fun, but what about simulating a more exotic machine?

<img src="img/2022gpt/lisp_shell_1.png" />

<img src="img/2022gpt/lisp_shell_2.png" />

I was pretty excited to see a source file in the directory. Maybe I would learn some great secrets about lisp, or about text editor programming
here. What strange corners of the internet has this model scoured to pick up mysterious, arcane lisp knowledge?

<img src="img/2022gpt/lisp_shell_3.png" />

Huh. Usually I've been seeing ChatGPT generate bad code, incorrect code or lazy code. This is the first time I've seen it toally give up.
I assume it is struggling because there is less lisp code online to learn from, and much less application code to learn from.
Let's see if the calculator has anything more interesitng.

<img src="img/2022gpt/lisp_shell_6.png" />

This isn't exciting, but at least we can `eval` this file and pretend it works!

<img src="img/2022gpt/lisp_shell_7.png" />

This printed `10` as expected, but for some reason I forgot to screenshot that.

There is more of the filesystem to explore, so let's see what we can find in the `/system` tree.


<img src="img/2022gpt/lisp_shell_4.png" />
<img src="img/2022gpt/lisp_shell_5.png" />

At least this pretends to do something. I learned later how to probe these hypothetical lisp systems to give me more details about 
how functions are implemented, but at this point I just had to take `run-next-task` at face value.

After learning more about how to write good prompts, I tried to make it hallucinate another similar machine, with results containing
similarly empty files.

<img src="img/2022gpt/lisp_shell2_1.png" />
<img src="img/2022gpt/lisp_shell2_2.png" />
<img src="img/2022gpt/lisp_shell2_3.png" />

This version file was interesting, I could believe this being in a real project even if it is strange. I also appreciate this mysterious
John Doe from 1980 who is being given credit. Also, apparently `princ` is a real function some Lisps, including Emacs Lisp, and prints
with control characters.

When I try to change directory I discover that this system does not understand `cd`. So, time to be a programmer and define it!

<img src="img/2022gpt/lisp_shell2_4.png" />

I was seriously doubting this worked, but I decided that if ChatGPT can halucinate an entire computer then I would make up
the dynamic variable `*current-dir*`. This must be a step too far, right?

<img src="img/2022gpt/lisp_shell2_5.png" />
<img src="img/2022gpt/lisp_shell2_6.png" />

Not only does this work, but it's internally consistent. Insanity! I have added new functionality to a fake computer.

<img src="img/2022gpt/lisp_shell2_7.png" />

Oh no, I guess it's time to give up on this for today.

*Note: this post was written in late 2022 but was not actually published until late 2023 due to life getting in the way. Oops. I don't think
ChatGPT is as much fun with these kind of prompts any more*

