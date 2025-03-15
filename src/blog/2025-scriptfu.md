---
title: Experimenting with GIMP Script-Fu
date: 2025-03-15
author: Tom Marks
draft: false
...

## Extending My Image Editor

I recently purchased a Wacom graphics tablet for note taking. Especially on Linux, I am
not satisfied with existing note taking programs. Being a stubborn programmer, I have decided to
build my own solution by extending my favourite image editor, [the GIMP](https://www.gimp.org/).

## Script-Fu

I am a programmer with sophistication, so when I learned that the GIMP has its own built-in scheme
for scripting I was thrilled. I committed to learn this elegant, parenthesized language. That was
over 10 years ago. 

Script-Fu is exactly what I would expect from a scheme scripting language. Here is the example
script from the GIMP documentation:

```scheme
  (define (script-fu-text-box inText inFont inFontSize inTextColor))

  (script-fu-register
    "script-fu-text-box"                        ;function name
    "Text Box"                                  ;menu label
    "Creates a simple text box, sized to fit\
      around the user's choice of text,\
      font, font size, and color."              ;description
    "Michael Terry"                             ;author
    "copyright 1997, Michael Terry;\
      2009, the GIMP Documentation Team"        ;copyright notice
    "October 27, 1997"                          ;date created
    ""                                      ;image type that the script works on
    SF-STRING      "Text"          "Text Box"   ;a string variable
    SF-FONT        "Font"          "Charter"    ;a font variable
    SF-ADJUSTMENT  "Font size"     '(50 1 1000 1 10 0 1)
                                                ;a spin-button
    SF-COLOR       "Color"         '(0 0 0)     ;color variable
  )
  (script-fu-menu-register "script-fu-text-box" "<Image>/File/Create/Text")

```

Here a function `script-fu-text-box` is defined, which I assume draws text in a box.

This script goes into the GIMP scripts folder, eg `.config/GIMP/2.10/scripts` with
the extension `.scm`. It should appear in the File menu after `Filters>Script-Fu>Refresh Scripts`.
As expected, this adds a menu item under `File>Create>Text`.

## My Plan 

I want to be able to flip between pages of a notebook with button presses. These will be
scripts bound to buttons. We don't need to worry about the key bindings yet, just the scripts that
drive the actions.

Each "page" will be a layer, named `page-{n}`. To swap to the next or previous page, I will search
for a layer called `page-{n+1}` or `page-{n-1}` respectively. If no such page exists (for `n > 0`),
I will create a new layer.

The functions `gimp-image-get-layer-by-name`, `gimp-layer-new` and `gimp-image-insert-layer` seem
to satisfy all of this functionality.

## Test Script

First, I make an example script to try adding a layer to an open image. I want to experiment
in the script console, however I can't seem to use `gimp-layer-new` here because it takes an
image parameter. I can't work out where to get the current, active image from - to write a script
that works with the open image, it seems like the script has to declare a parameter of type SF-IMAGE
when being registered.

So I put my example script into the directory and click-ops loading it:

```scheme
    (define (script-fu-pen-add-layer image)
      (let* ( (layer (gimp-layer-new image 100 100 RGBA-IMAGE "pg" 100.0 LAYER-MODE-NORMAL)) )
        (gimp-image-insert-layer image layer 0 0)))

    (script-fu-register
      "script-fu-pen-add-layer"                        ;function name
      "Pen: Add Layer (Test)"                          ;menu label
      "(WIP)"
      "Tom Marks (phy1um)"                             ;author
      ""                                               ;copyright notice
      "March 15th, 2025"                               ;date created
      ""                                               ;image type that the script works on
      SF-IMAGE       "Image"        "" 
    )
    (script-fu-menu-register "script-fu-pen-add-layer" "<Image>/Pen/Test")
```

Clicking to refresh scripts, I am greeted with a popup:

```
Error while loading /home/tom/.config/GIMP/2.10/scripts/test.scm:

Error: (/home/tom/.config/GIMP/2.10/scripts/test.scm : 15) script-fu-register: default IDs must be integer values
```

How mysterious. This is not the best experience for debugging.

Minutes pass, and I work out that the default argument for an SF-IMAGE should be `0`, not an
empty string. I definitely saw examples that used empty string here. I can't find any official documentation
with an opinion, or any detail on what this function expects. Even the official function reference opened
from the scripting console has no entry for `script-fu-register` (this may be because you can't register
a script from the console?).

Overall trying to find any documentation for script-fu is painful. Now that I have a script that I
can run from a new top-level submenu (defining these menu entries is extremely exciting for some reason)
it's time for the next error.

```
Execution error for 'Pen: Add Layer (Test)':
Error: Invalid type for argument 2 to gimp-image-insert-layer 
```

At least it's precise about the function. I can't be sure if the arguments are 1-indexed or 0-indexed, but
I'm going to assume this is the first `0` I am passing in to `gimp-image-insert-layer`.

The third argument is described in the help: 
```
parent    LAYER    The parent layer
```

What if I don't have a parent layer? I was hoping `0` would be acceptable, but perhaps an integer is not valid
here. I could try getting the current active layer first and making this a child? Or maybe create
a new layer **group** to contain all of my pages?

```scheme
    (define (script-fu-pen-add-layer image)
      (let* ( 
          (layer (gimp-layer-new image 100 100 RGBA-IMAGE "pg" 100.0 LAYER-MODE-NORMAL)) 
          (group (gimp-layer-group-new image))
          )
            (gimp-image-insert-layer image layer group 0)))

    (script-fu-register
      "script-fu-pen-add-layer"                        ;function name
      "Pen: Add Layer (Test)"                          ;menu label
      "(WIP)"
      "Tom Marks (phy1um)"                             ;author
      ""                                               ;copyright notice
      "March 15th, 2025"                               ;date created
      ""                                               ;image type that the script works on
      SF-IMAGE       "Image"        0 
    )
    (script-fu-menu-register "script-fu-pen-add-layer" "<Image>/Pen/Test")
```

I am greeted with the same error. I also have to confront the painful experience of forgetting to
click to reload the scripts. This would be much better from a REPL in the console. 

## REPLs Are Faster

After giving up to play some chess and consume lunch, I came back to stare at the REPL. With
a sudden wave of inspiration, I started typing:

```
> (gimp-image-get-layers 0)
Error: Procedure execution of gimp-image-get-layers failed on invalid input arguments: Procedure 'gimp-image-get-layers' has been called with an invalid ID for argument 'image'. Most likely a plug-in is trying to work on an image that doesn't exist any longer. 

> (gimp-image-get-layers 1)
Error: Procedure execution of gimp-image-get-layers failed on invalid input arguments: Procedure 'gimp-image-get-layers' has been called with an invalid ID for argument 'image'. Most likely a plug-in is trying to work on an image that doesn't exist any longer. 

> (gimp-image-get-layers 2)
(1 #(8))
```

Aha! Images are just an integer index, and with some trial and error I can grab the current image! I
had this instance of the GIMP open for a while, and had opened at least one image previously, so
it is possible that these indices are simple counting numbers that increment by 1.

```
> (gimp-image-get-layer-by-name 2 "Background")
(8)
```

Now we're really getting somewhere. Let's try adding a layer again:

```
> (define nl (gimp-layer-new 2 100 100 RGBA-IMAGE "page-0" 100 LAYER-MODE-NORMAL))
nl
> nl
(11)
> (gimp-image-insert-layer 2 nl 8 0)
Error: Invalid type for argument 2 to gimp-image-insert-layer 
```

What if I used the layer index `11` directly:

```
> (gimp-image-insert-layer 2 11 8 0)
Error: Procedure execution of gimp-image-insert-layer failed on invalid input arguments: Item 'Background' (8) cannot be used because it is not a group item 

> (gimp-image-insert-layer 2 11 0 0)
(#t)
```

That was unexpected. Why can't I insert a layer by variable reference? Is this a macro which stops the variable `nl` from being evaluated?
I go back over the history and notice a critical, easy to miss detail.

```
> (define nl (gimp-layer-new 2 100 100 RGBA-IMAGE "page-0" 100 LAYER-MODE-NORMAL))
nl
> nl
(11)
```

Do you see it? `(11)`, aka a list containing one value, the number `11`. So now, if I unwrap that list with a `car`,
I have everything I need to make some progress:

```scheme
    (let* ((page-group 0)
            (once-guard #t))

        (define (script-pre image)
            (if once-guard
                (do
                    (set! page-group (gimp-layer-group-new image))
                    (set! once-guard #f))))

        (define (script-fu-pen-add-layer image)
          (script-pre image)
          (let* ( 
              (layer (car (gimp-layer-new image 100 100 RGBA-IMAGE "pg" 100.0 LAYER-MODE-NORMAL))) 
              )
                (gimp-image-insert-layer image layer page-group 0)))

        (script-fu-register
          "script-fu-pen-add-layer"                        ;function name
          "Pen: Add Layer (Test)"                          ;menu label
          "(WIP)"
          "Tom Marks (phy1um)"                             ;author
          ""                                               ;copyright notice
          "March 15th, 2025"                               ;date created
          ""                                               ;image type that the script works on
          SF-IMAGE       "Image"        0 
        )

        (script-fu-menu-register "script-fu-pen-add-layer" "<Image>/Pen/Test"))

```

I tried being clever with scopes, but this didn't work. It seems like either the function, or the call to `-register`
need to be at the top level. So I re-write my file-local variables with `define` and it works:

```
(define page-group 0)
(define once-guard #t)
(define page-counter 0)

(define (script-pre image)
    (if once-guard
        (do
            (set! page-group (gimp-layer-group-new image))
            (set! once-guard #f))))

(define (script-fu-pen-add-layer image)
  (script-pre image)
  (let* ( 
      (layer (gimp-layer-new image 100 100 RGBA-IMAGE "pg" 100.0 LAYER-MODE-NORMAL)) 
      )
        (gimp-image-insert-layer image (car layer) page-group 0)))

(script-fu-register
  "script-fu-pen-add-layer"                        ;function name
  "Pen: Add Layer (Test)"                          ;menu label
  "(WIP)"
  "Tom Marks (phy1um)"                             ;author
  ""                                               ;copyright notice
  "March 15th, 2025"                               ;date created
  ""                                               ;image type that the script works on
  SF-IMAGE       "Image"        0 
)

(script-fu-menu-register "script-fu-pen-add-layer" "<Image>/Pen/Test")

```

## Moving Between Pages

Now let's get back to the goal of flipping between pages. I add a helper function to
step forwards and backwards, updating the active layer and toggling visibility as required:

```scheme
(gimp-message-set-handler 2)

(define page-group 0)
(define once-guard #t)
(define page-counter 0)

(define (script-pre image)
    (if once-guard
        (do
            (set! page-group (gimp-layer-group-new image))
            (set! once-guard #f))))

; returns a string of the active layer name
(define (get-active-layer-name image)
  (car (gimp-layer-get-name (car (gimp-image-get-active-layer image)))))

; true if any numeric page is active
(define (is-on-any-page image)
  (not (not (string->number (get-active-layer-name image)))))

(define (next-page-number image step)
  (let* (
         (layer-name (get-active-layer-name image))
         (layer-num-raw (string->number layer-name))
         (next-num (if (layer-num-raw) (+ layer-num-raw step) 0))
         (next-bounded (if (< next-num 0) 0 next-num)))
    (gimp-message "set visible")
    (gimp-layer-set-visible (car (gimp-image-get-active-layer image)) 0)
    (gimp-message "test bounded")
    (if (> next-bounded page-counter)
      ; create new layer if out of bounds of our counter
      (let ((layer (car (gimp-layer-new image 1 1 RGBA-IMAGE (number->string next-bounded) 100.0 LAYER-MODE-NORMAL))))
        (gimp-message "resize and insert new layer")
        (gimp-layer-resize-to-image-size layer)
        (gimp-image-insert-layer image layer page-group 0))
        (set! page-counter next-bounded)
      ; else just make the old layer active and visible
      (let ((tgt (car (gimp-get-layer-by-name (number->string next-bounded)))))
        (gimp-message "set visible")
        (gimp-image-layer-set-visible tgt 1)
        (gimp-image-set-active-layer image tgt)))))

(define (script-fu-pen-next-page image)
  (script-pre image)
  (next-page-number image 1))


(define (script-fu-pen-prev-page image)
  (script-pre image)
  (next-page-number image -1))

(script-fu-register
  "script-fu-pen-next-page"                        ;function name
  "Pen: Next Page (Test)"                          ;menu label
  "(WIP)"
  "Tom Marks (phy1um)"                             ;author
  ""                                               ;copyright notice
  "March 15th, 2025"                               ;date created
  ""                                               ;image type that the script works on
  SF-IMAGE       "Image"        0 
)

(script-fu-register
  "script-fu-pen-prev-page"                        ;function name
  "Pen: Prev Page (Test)"                          ;menu label
  "(WIP)"
  "Tom Marks (phy1um)"                             ;author
  ""                                               ;copyright notice
  "March 15th, 2025"                               ;date created
  ""                                               ;image type that the script works on
  SF-IMAGE       "Image"        0 
)



(script-fu-menu-register "script-fu-pen-next-page" "<Image>/Pen/Pages")
(script-fu-menu-register "script-fu-pen-prev-page" "<Image>/Pen/Pages")
```

Take note of the first line, and `gimp-message`. Usually `gimp-message` shows information in
the GUI, but if you set the handler to 2 it shows up in the error console. This was extremely
useful in ironing out the following few issues. The first thing I see in there when running this
is another extremely unhelpful message:

```
Execution error for 'Pen: Next Page (Test)':
Error: illegal function
```

I stare at my screen for about 15 minutes before noticing:

```
...
  (let* (
         (layer-name (get-active-layer-name image))
         (layer-num-raw (string->number layer-name))
         >>>>  (next-num (if (layer-num-raw) (+ layer-num-raw step) 0))  <<<< THIS LINE HERE
...
```

I was trying to call `layer-num-raw` as a function, but it is a number! I suppose
a number really _is_ an illegal function, in a way. I wish it gave me a line number and/or
_the name of the function that I tried to call which cased the error_ but you take
what you get.

Also I had a misplaced bracket in an if statement, but there was no warning that I
was skipping out a third form in the body. That was a very hard mistake to spot!

Finally after some trial and error, I cleanup several remaining errors and typos,
and everything works! I can move backward and forwards through pages, adding new
ones as required, but never going below 0.

The final script:

```scheme
(gimp-message-set-handler 2)

(define page-group 0)
(define once-guard #t)
(define page-counter -1)

(define (script-pre image)
    (if once-guard
        (do
            (set! page-group (gimp-layer-group-new image))
            (set! once-guard #f))))

; returns a string of the active layer name
(define (get-active-layer-name image)
  (car (gimp-layer-get-name (car (gimp-image-get-active-layer image)))))

; true if any numeric page is active
(define (is-on-any-page image)
  (not (not (string->number (get-active-layer-name image)))))

(define (next-page-number image step)
  (let* (
         (layer-name (get-active-layer-name image))
         (layer-num-raw (string->number layer-name))
         (next-num (if layer-num-raw (+ layer-num-raw step) 0))
         (next-bounded (if (< next-num 0) 0 next-num)))
    (gimp-message "set invisible")
    (gimp-layer-set-visible (car (gimp-image-get-active-layer image)) 0)
    (gimp-message "test bounded")
    (if (> next-bounded page-counter)
      ; create new layer if out of bounds of our counter
      (let ((layer (car (gimp-layer-new image 1 1 RGBA-IMAGE (number->string next-bounded) 100.0 LAYER-MODE-NORMAL))))
        (gimp-message "resize and insert new layer")
        (gimp-image-insert-layer image layer page-group 0)
        (gimp-layer-resize-to-image-size layer)
        (set! page-counter next-bounded))
      ; else just make the old layer active and visible
      (let ((tgt (car (gimp-image-get-layer-by-name image (number->string next-bounded)))))
        (gimp-message (string-append "set existing layer visible: " (number->string next-bounded)))
        (gimp-layer-set-visible tgt 1)
        (gimp-image-set-active-layer image tgt)))))

(define (script-fu-pen-next-page image)
  (script-pre image)
  (next-page-number image 1))


(define (script-fu-pen-prev-page image)
  (script-pre image)
  (next-page-number image -1))

(script-fu-register
  "script-fu-pen-next-page"                        ;function name
  "Pen: Next Page (Test)"                          ;menu label
  "(WIP)"
  "Tom Marks (phy1um)"                             ;author
  ""                                               ;copyright notice
  "March 15th, 2025"                               ;date created
  ""                                               ;image type that the script works on
  SF-IMAGE       "Image"        0 
)

(script-fu-register
  "script-fu-pen-prev-page"                        ;function name
  "Pen: Prev Page (Test)"                          ;menu label
  "(WIP)"
  "Tom Marks (phy1um)"                             ;author
  ""                                               ;copyright notice
  "March 15th, 2025"                               ;date created
  ""                                               ;image type that the script works on
  SF-IMAGE       "Image"        0 
)



(script-fu-menu-register "script-fu-pen-next-page" "<Image>/Pen/Pages")
(script-fu-menu-register "script-fu-pen-prev-page" "<Image>/Pen/Pages")

```

## Conclusion

Script-Fu is an interesting and powerful scripting environment. However,
the poor developer experience around error reporting and documentation
makes it extremely rough to work with. There is a serious lack of examples,
and very limited official documentation showing how to actually _do_ anything.

Simple problems I encountered such as not unwrapping results with `car` create
unnecessary friction. If your target audience are experienced programmers, it shouldn't
be hard to document or teach by example that this kind of unwrapping is required.
I am still very confused by why these functions return lists at all!

I wish the REPL was a little bit friendlier. Hitting escape closes the window
immediately, at least on my system (arch btw), and any history you have is
instantly forgotten. I think the console experience would be better if I 
could connect to the script-fu server, but I didn't end up trying that today.

Ultimately my script works, and I'm happy with that. It just took about 1
hour longer than it should have :D

