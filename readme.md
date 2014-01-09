# Sizzle

`Sizzle` is a [Fantom](http://fantom.org/) library for querying XML documents by means of [CSS 2.1](http://www.w3.org/TR/CSS21/selector.html) selectors.

`Sizzle` currently supports:

 - The Universal selector - `*`
 - Type selectors - `div`
 - ID selectors - `#id`
 - Class selectors - `.heading`
 - Descendant selectors - `html div`
 - Child selectors - `html > div`
 - Adjacent sibling selectors - `div + p`
 - Any value attribute selector - `[att]`
 - Exact value attribute selector - `[att=val]`
 - Whitespace value attribute selector - `[att~=val]`
 - Language value attribute selector - `[att|=val]`
 - The pseudo-class `:first-child`
 - The language pseudo-class `:lang(xxx)`
 


## Install

Install `Sizzle` with the Fantom Respository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    $ fanr install -r http://repo.status302.com/fanr/ afSizzle

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afSizzle 0+"]



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afSizzle/#overview).



## Quick Start

1). Create a text file called `Example.fan`:

    using afSizzle

    class Example {
        Void main() {
            xml   := """<html><p class="welcome">Hello from Sizzle!</p></html>"""
            elems := Sizzle().selectFromStr(xml, "p.welcome")
            echo(elems.first.text)  // -> Hello from Sizzle!
        }
    }

2). Run 'Example.fan' as a Fantom script from the command line:

    C:\> fan Example.fan
    Hello from Sizzle!

