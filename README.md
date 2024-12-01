# ppersist — Convenient long-term storage of python data

## Introduction

There are many ways to save data from python for future use, but none
are quite as convenient as Matlab and Octave’s “save”:

    save filename.mat variableA variableB ...
    
which saves the named variables directly to a file. The corresponding

    load filename.mat
    
reloads the saved variables and dumps them into the global namespace.

This packages offers the closest pythonic equivalent. With it, you can write

    ppersist.save("filename.pkl", variableA, variableB, ...)
    
to save some variables, and

    data = ppersist.load("filename.pkl")
    
to reload them into a `namedtuple`. 


## Installation

Will soon be as easy as

    pip install ppersist
    
For now, please copy the file “ppersist.py” into your local environment.


## Saving data

The most straightforward way to save your data is

    ppersist.save("filename.pkl", variableA, variableB, ...)

This uses `inspect` to extract the names of the variables. This poses
some restrictions on the arguments. In particular, the filename may
only be given either as a simple variable or as a direct string not
containing commas or quotation marks. Also, variable names must start
with a letter and may only contain letters, numbers, and underscores. 

As an alternative, you can use the idiom

    with ppersist.Saver(filename) as pp:
        pp.save(variableA, variableB, ...)
        
In this form, the filename may be any valid python expression. Also,
if the variable list is too long to fit comfortably on a line, you can
write

    with ppersist.Saver("filename.pkl") as pp:
        pp.save(variableA, variableB, ...)
        pp.save(variableC, variableD, ...)
        ...

which is not possible with plain `save`. (Continuation lines are not
supported to keep the `inspect` system as simple as possible.)


Finally, if your data are already packaged in a dictionary, you can write

    ppersist.savedict("filename.pkl", dct)
    
which results in a ppersist-loadable file in which the variables are
the items of the dictionary.


## Loading data

The most straightforward way to load previously saved data is

    dat = ppersist.load("filename.pkl")
    
This returns a named tuple in which the members are named according to
the variables in the file.

As an alternative,

    dct = ppersist.loaddict("filename.pkl")
   
returns the variables as items in a dictionary.

Both form may be used without restriction with files created by
`ppersist.save` or `ppersist.savedict`.

Finally, the form

    ppersist.mload("filename.pkl")
    
comes closest to the simplicity of Octave and Matlab by creating
variables directly in the caller’s namespace. This is decidedly
unpythonic and confuses IDEs, so is not generally recommended except
for throw-away code typed into a terminal.


## Considerations of security and reliability

Naturally, you want to be sure that you will be able to reload your
data and that loading files your receive from others are safe to load.

First of all, be reminded that ppersist is Free Software. As such, it
is “distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.” 
(Please read the [Full license terms](./LICENSE).)

That said, the author shares your concerns and has made efforts to
make ppersist safe and reliable. Read on for details.


### Security

By this I mean: How certain can you be that ppersist will not run
arbitrary code contained in a file it loads?

Internally, ppersist uses `pickle` to save and load its files. Any
quick glance online will tell you that `pickle` is not inherently
safe. To mitigate this, `ppersist.load` and friends use a whitelist to
strictly limit what can be loaded. Objects with types not on the
whitelist are not loaded and their defining modules are not
imported. This should provide some reassurance that files you receive
from others are safe to load.

All of that said, if human lives depend on the integrity of your
server, you should absolutely do your own due diligence.


### Reliability

By this I mean: How likely is it that you will be able to still access
your data in the distant future? Here, the use of `pickle` is actually
an advantage, as that module is part of core Python and unlikely to
ever go away.

Before actually writing anything to disk, `ppersist.save` and friends
check whether variables can be safely reloaded. If not, they raise an
exception. This should provide some reassurance that you will be able
to reload your files in the future.

In case you do find yourself unable to load a definitely trusted file
due to an inconsistency between ppersist’s save-time and load-time
checking, you can disable the whitelist by passing `trusted=True` to
`ppersist.load`. (If that happens, it is a bug, and the author wants
to hear from you.)

In the worst case, if you find yourself without access to ppersist
entirely, you can always reload your data with

    dct = pickle.load("filename.pkl")
    
even though that provides no security at all.

