# sltable
Generate nicely-formatted LaTeX tables from S-Lang objects, full of
properly-rounded values and (possibly asymmetric) uncertainties.

# Synopsis
SLTable is a set of routines which generate good-looking,
properly-formatted, and properly rounded LaTeX tables given a set of
values and (possible asymmetric) uncertainties. The present version
I wrote a couple of years back after being frustrated by the amount
of code I was rewriting for every project just to produce tables for
publication. This means it is designed for my specific needs, and so it
won't generate arbitrarily complex tables. The types of tables I
typically produce with SLTable are tables of fitted parameter values
with their uncertainties, usually listed one parameter per line, with
multiple columns for different datasets or different models, which may
or may not share parameters. So, if that's your use case, this might be
useful to you.

My astrophysics work is primarily carried out using the [Interactive
Spectral Interpretation System](https://space.mit.edu/CXC/isis/)
(ISIS), which uses [S-Lang](http://www.jedsoft.org/slang/) as
its scripting language, hence why these routines are written in
S-Lang - this way I can go from initial analysis all the way to
publication using the same system.

Formally, this is part of the [Remeis
ISISscripts](https://www.sternwarte.uni-erlangen.de/isis/), and as a
result it depends on several functions from that library. Really, it's
easier to just download the ISISscripts and use `sltable()` from there.

# Requirements
- [ISIS](https://space.mit.edu/CXC/isis/)
- The [Remeis
ISISscripts](https://www.sternwarte.uni-erlangen.de/isis/),
specifically the `create_struct_field()`, `empty_struct()`, `round2()`,
`round_err()`, `round_conf()`, and `TeX_value_pm_error()` functions.

# Installation
Put `sltable.sl` somewhere that ISIS can find it (use
`prepend_to_isis_load_path()`), and call `require("sltable.sl")`. Or
install and `require` the full ISISscripts.

# Usage
I wrote up a short
[tutorial](https://www.sternwarte.uni-erlangen.de/wiki/index.php/Making_
tables_with_sltable) on how to use SLTable! There is also quite a bit of
documentation in the code; if you use SLTable via the ISISscripts, this
should be accessible to you using ISIS' `help` command.
