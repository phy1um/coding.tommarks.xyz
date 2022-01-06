::: {#attract .section}
# Projects

An incomplete list of interesting projects I have worked on since
childhood
:::

::: section
## 2021

### Lisp Game Jam Attempt - Failed Playstation 2 Dungeon Crawler

I attempted to make a simple 2D dungeon cralwer in [fennel](#) for *Lisp
Autumn Game Jam 2021*, but didn't end up submitting anything. I used 
my custom Playstation 2 Lua engine which is not very mature, and encountered
many technical problems. The final game is playable, but has some graphical issues
and is not very fun :D

* [Download + Source on itch.io](https://tommarkstalkscode.itch.io/lisp-game-jam-2021-ps2-shooter)

### Playstation 2 Homebrew Livestreams

I stepped back to square one and started documenting my process of building 
software for the Playstation 2, first in C and later incorporating Lua. This is
a huge ongoing piece of work that will continue well beyond 2021, but it started
here!

* [Youtube Playlist](https://www.youtube.com/playlist?list=PLFZsvEE0TWOsFhZr-9KwLED3Rzlwra_Rm)

### Nim Lisp Interpreter

To continue developing my knowledge of Lisp and to learn a new
programming language Nim, I implemented a very simple Lisp interpreter.
The macro compile-time code generation capabilities of Nim are very
interesting for writing code which plays well with Lisp, such as
automatically generating code which binds runtime Lisp function
arguments (in the form of a Cons-list) to variable names, possibly even
with auto-generated type checking.

* [Source (Very incomplete)](#)

![](img/2021_nimlisp.png)
~The\ very\ verbose\ output\ of\ my\ Lisp\ interpreter\ proving\ it\ is\ capable\ of\ basic\ addition~

### 7 Day RogueLike 2021


I attempted to make a small roguelike platformer in 7 days for a game jam. 
Overall I didn't succeed in making a roguelike, but I did make a functional game
with random levels. I'm happy with what I achieved in the timeframe,
however as it isn't really a roguelike I did not submit it to the jam.

* [Download on itch.io](https://tommarkstalkscode.itch.io/0x5007)

![](img/2021_7drl1.png){height="320"}
![](img/2021_7drl2.png){height="320"}
~Programmer\ art\ in\ full\ swing\ with\ a\ 7\ day\ deadline~
:::

::: section
## 2020

### Lisp Interpreter

I wrote a simple Lisp interpreter in C based on McCarthy's 1959 paper.
It has the minimal set of functions to be an interpreter and a simple
interface for binding C functions to be called from Lisp. It has no
garbage collection so is quite limited in what it can run.

* [Source (Incomplete)](#)

### Playstation 2 Graphics Synthesizer Buffer/DMA Utilities

I've been interested in Playstation 2 hardware since 2019 and have a
few small experiments resembling games. One headache has been managing
the state of buffers which are sent to the Graphics Synthesizer
(rasterizer). I wrote some utilities for a managed buffer which
automatically builds DMA headers and Graphics Synthesizer "packets".
This is currently embedded in a rendering example
[here](https://github.com/phy1um/ps2draw-examples/tree/basic), but it
will be polished and extracted to a self-contained library in the
future.

![](img/2020_ps2render.png){height="480"}
~A\ simple\ .obj\ renderer\ running\ in\ a\ PlayStation\ 2\ emulator~
![](img/2020_ps2game1.png){height="480"}
~A\ simple\ gameplay\ test\ for\ a\ PlayStation\ 2\ arcade\ shooter~
:::

::: section
## 2019

Quake 3 Server Browser API and Discord Bot

In Quake 3 sending queries to get server status is done over UDP. I
wanted to make this easier, so I wrote and hosted a web service which
periodically queried all public Quake 3 servers and exposed their status
(player counts, game settings, admin contact details and more) in a REST
API. I then built a Discord bot which allowed members of my Discord
server to use a !command to prompt the bot to report player activity in
local servers.
:::

::: section
## 2018

### Survey and Data Collection Platform

I volunteered to build a survey for an honors student conducting
research at the University of Adelaide. The survey contained
interactive sections which were outside of what is possible with survey
builders and existing survey web frameworks/libraries. My solution was
built in HTML and Javascript, with some data pre-processing for survey
question/activity data in Python. I also built the data collection
backend, which was a simple NodeJS app storing data in MongoDB.
:::

::: section
2016

### C Game Experiments

To learn more about lower level programming I dove into C and built
simple games using the SDL2 library.

* [Source](#)

![One of my games, a screen filled with small atari-inspired
characters](img/2016_cgame1.png)
~A\ test\ of\ displaying\ many\ interacting\ characters~ ![Screenshot
of \'Shark Game\'](img/2016_cgame2.png)
~Shark\ Game\ was\ an\ arcade-style\ game\ about\ eating\ fish~
:::

::: section
## 2015

### Music Playlist Generator

My first paid programming project was for my local doctor's clinic,
building a system to randomly generate Windows Media Player playlists
from a large collection of music. This was my first project where I had
to gather requirements myself. I had to work under tight restrictions
and understand data structures to effectively track which songs had been
considered already while selecting a variety of genres and artists,
based on song metadata as well as a song's filesystem path. The system
worked well and was in use years later when I visited the same clinic.
:::

::: section
## 2014

### Card Layout System

A very modular system which took a list of card data and arranged them
into A4 pdfs for printing. Used for generating sheets of Magic: The
Gathering proxies, but I had ambitions of prototyping my own card game
with it that never came together. This was a strange mishmash of Python
and Batch scripts. I learned a lot from this project by finding ways to
glue together existing solutions with my own small scripts to make a
larger system.
:::

::: section
## 2013

### Java Games

Simple Java games mostly from a top-down perspective. My first Java game
"Text Game" was console based, but later ported to a graphical game. I
built some simple platformers, but never finished anything other than
example levels. I spent a lot of time thinking about structuring my code
into "engine" and "game" sections, which enabled me to share a lot
of code between projects.

:::

::: section
## 2006-2009

### GameMaker Games

I started programming with GameMaker, first with the drag-and-drop
interface but eventually writing code in "GML", a Java-like language.
These games impressed my school friends, but are very primitive.

![](img/2007_gamemaker.png){height="480"}
~My\ 2007/2008\ game\'s\ gimmick\ was\ creating\ platforms\ you\ could\ jump\ on\ by\ clicking\ the\ mouse~
:::
