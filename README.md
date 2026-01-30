# ppersist — Convenient long-term storage of python data

## Introduction

There are [many ways](#Alternatives) to save data from python for
future use, but none are quite as convenient as Matlab and Octave’s
“save”:

    save filename.mat variableA variableB ...
    
which saves the named variables directly to a file. The corresponding

    load filename.mat
    
reloads the saved variables and dumps them into the global namespace.

This packages aims to offer the closest pythonic equivalent. With it,
you can write

    ppersist.save("filename.pkl", variableA, variableB, ...)
    
to save some variables, and

    data = ppersist.load("filename.pkl")
    
to reload them into a `namedtuple`. 


## Installation

As easy as:

    pip install ppersist


## Saving data

The most straightforward way to save your data is

    ppersist.save("filename.pkl", variableA, variableB, ...)

Note that this uses the `inspect` module to discover the names of the
variables to be saved. That means that *variableA*, *variableB*, etc.,
must all be simple variables, not arbitrary expressions. (In other
words, you cannot `ppersist.save("filename.pkl", x + 3)`.)

Alternatively, if your data are already contained in a dictionary, you
can write

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

Both forms may be used without restriction with files created by
`ppersist.save` or `ppersist.savedict`.

Finally, the form

    ppersist.mload("filename.pkl")
    
comes closest to the simplicity of Octave and Matlab by creating
variables directly in the caller’s namespace. This is decidedly
unpythonic and confuses IDEs, so is not generally recommended except
for throw-away code typed directly into a console.


## Fetching data from the web

To retrieve data from a website, you can write

    data = ppersist.fetch("https://somewhere.net/data.pkl")
    
This provides a very convenient way to distribute example data for
Jupyter notebooks demonstrating data analysis packages. Internally,
`fetch` makes use of a [whitelist mechanism](#Security) to
ensure only safe data types are loaded.


## Considerations of security and reliability

Naturally, you want to be sure that you will be able to reload your
data and that loading files your receive from others are safe to load.

First of all, be reminded that ppersist is Free Software. As such, it
is “distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.” (Please read the [Full license
terms](https://github.com/wagenadl/ppersist/blob/main/LICENSE).)

That said, the author shares your concerns and has made efforts to
make ppersist safe and reliable. Read on for details.


### Security

By this I mean: How certain can you be that ppersist will not run
arbitrary code contained in a file it loads?

Internally, ppersist uses `pickle` to save and load its files. Any
quick glance online will tell you that `pickle` is not inherently
safe. To mitigate this concern, `ppersist.load` and friends use a
whitelist to strictly limit what can be loaded. Objects with types not
on the whitelist are not loaded and their defining modules are not
imported. This should provide some reassurance that files you receive
from others are safe to load.

All of that said, if lives depend on the integrity of your server, you
should absolutely do your own due diligence.


### Reliability

By this I mean: How likely is it that you will be able to still access
your data in the (distant) future? Here, the use of `pickle` is
actually an advantage, as that module is part of core Python and is
therefore unlikely to go away.

Before writing anything to disk, `ppersist.save` and friends check
whether variables can be safely reloaded. If not, they raise an
exception. This should provide some reassurance that you will be able
to reload your files in the future.

Should this fail, and you find yourself unable to load a file you
definitely trust, you can disable the whitelist by passing
`trusted=True` to `ppersist.load`. (If you find yourself in that
position, it indicates a bug in ppersist. Please [raise an issue on
github](https://github.com/wagenadl/ppersist/issues) or send me an
email, and I will attempt to release a fix asap.)

In the worst case, if you find yourself without access to ppersist
entirely, you can always reload your data with

    dct = pickle.load("filename.pkl")
    
even though that provides no security at all.


## Alternatives

To help you decide whether ppersist is for you, here are several
alternatives I considered before writing ppersist.

### JSON

Widely supported, human-readable, **JSON** is a great file format for
small quantities of data. It naturally supports basic Python data
types and structures. However, for larger datasets, its main
strength—storage as text—becomes a liability as it imposes a
significant cost both in processing time and storage space. Also,
there is no agreed-upon standard for represention numpy arrays in
JSON.

### CSV

Also widely supported and human-readable, **CSV** is good for handling
straight-up two-dimensional arrays of data, but it does not naturally
handle other Python structures. Also, inefficient for larger datasets.

### NPY

Numpy can store its main data format (`np.ndarray`) in **.NPY** files,
simply using `np.save`, and reload it with `np.load`. However, this
format cannot hold multiple `np.ndarray`s in one file. Neither can it
store other Python data structures (even when wrapped inside an
`np.ndarray`.)

### HDF5

A very capacious file format, **HDF5** can in principle store all the
data formats that ppersist supports and is excellent for long-term
storage of very large datasets, as files can be written
incrementally. However, the mapping between Python datatypes and HDF5
datatypes is not quite one-to-one. The `pandas` library can use HDF5
for storing its `DataFrame`s on disk, if only for a subset of the
datatypes and structures it support.

I considered using HDF5 as a backend for ppersist. (Using it directly
was not attractive to me as the syntax for storing and retrieving data
is more elaborate than I wanted.) What kept me from choosing it, in
the end, was the complexity of supporting all the basic Python
datatypes, especially when considering their hierarchical inclusion in
pandas `DataFrames` and the like.

### Parquet

Developed by Apache, **Parquet** provides [“high performance
compression and encoding schemes to handle complex data in
bulk”](https://github.com/apache/parquet-format). Similar
considerations to HDF5 apply: the `fastparquet` library does not (yet)
support all Python datatypes, so constructing an easy-to-use API like
ppersist’s on top of it would be complex.


## Development

Development of ppersist is on 
[github](https://github.com/wagenadl/ppersist).
