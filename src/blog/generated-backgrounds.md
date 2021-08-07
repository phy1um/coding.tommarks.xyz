---
title: Generating Art for Backgrounds
date: 2021-08-04
author: Tom Marks
...

## Generating Art
I'm not a strong visual artist, but 
recently I needed to create a 2560x1440 image as a banner for my new Youtube channel.
I decided it was best to try and program it rather than draw anything by hand.

My basic idea was to generate a pattern, then draw it many times with
very low opacity, and move the key vertices very slightly on each drawing pass. 
These are generated using Javascript drawing to a HTML canvas.

Here are 3 variations on a simple triangulated mesh.

<img src="/img/bg/2021_08_tris_dense.png">
<img src="/img/bg/2021_08_tris1.png">
<img src="/img/bg/2021_08_tris2.png">


Code can be found <a href="https://gist.github.com/phy1um/d68819c8736ca7687e1b25ae44f484d7">in this gist.</a> The script was hacked together quickly, it has rough edges.

I love abstract desktop backgrounds and I think I'll continue to play with this
idea for generating backgrounds.

