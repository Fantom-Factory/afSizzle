# Sizzle v1.1.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v1.1.0](http://img.shields.io/badge/pod-v1.1.0-yellow.svg)](http://eggbox.fantomfactory.org/pods/afSizzle)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

Sizzle is a library for querying XML documents by means of [CSS 2.1](http://www.w3.org/TR/CSS21/selector.html) selectors.

Sizzle currently supports:

* The Universal selector - `*`
* Type selectors - `div`
* ID selectors - `#id`
* Class selectors - `.heading`
* Descendant selectors - `html div`
* Child selectors - `html > div`
* Adjacent sibling selectors - `div + p`
* Any value attribute selector - `[att]`
* Exact value attribute selector - `[att=val]`
* Whitespace value attribute selector - `[att~=val]`
* Language value attribute selector - `[att|=val]`
* The pseudo-class `:first-child`
* The language pseudo-class `:lang(xxx)`


Bonus [CSS3](http://www.w3.org/TR/css3-selectors/) selectors:

* The pseudo-class `:last-child`
* The pseudo-class `:nth-child(n)` *(basic numeric implementation)*
* The pseudo-class `:nth-last-child(n)` *(basic numeric implementation)*


Note: Sizzle has no association with [Sizzle - The JavaScript CSS Selector Engine](http://sizzlejs.com/) as used by [JQuery](http://jquery.com/). Well, except for the name of course!

## <a name="Install"></a>Install

Install `Sizzle` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afSizzle

Or install `Sizzle` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afSizzle

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afSizzle 1.1"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afSizzle/) - the Fantom Pod Repository.

## Quick Start

1. Create a text file called `Example.fan`    using xml
    using afSizzle
    
    class Example {
        Void main() {
            xhtml := "<html><p class='welcome'>Hello from Sizzle!</p></html>"
            elems := SizzleXml(xhtml).select("p.welcome")
            echo(elems.first.text)  // --> Hello from Sizzle!
        }
    }


2. Run `Example.fan` as a Fantom script from the command line:    C:\> fan Example.fan
    Hello from Sizzle!




## Usage

`Sizzle` usage is fairly simple and self explanatory; XML document in, XML elements out.

[SizzleDoc](http://eggbox.fantomfactory.org/pods/afSizzle/api/SizzleDoc) contains compiled and cached document information and is intended for re-use with multiple CSS selectors:

    doc    := SizzleXml("<html><p class='welcome'>Hello from Sizzle!</p></html>")
    elems1 := doc.select("p.welcome")
    elems2 := doc.select("html p")

### XML vs HTML

Sizzle only works with parsed XML documents, meaning your data has to be well formed.

HTML allows dodgy, and non well formed, syntax such as void elements `<br>`, and empty attributes `<input required>`. If your HTML contains such syntax then it needs to be converted to XML before it can be used with Sizzle.

Use [HTML Parser](http://eggbox.fantomfactory.org/pods/afHtmlParser) to do this.

Also note that XML does not allow named character references such as `&nbsp;` - they all need to be replaced with numerical character references such as `&#160;` or `&#xA0;`

### Case Insensitivity

Note that the CSS selectors in Sizzle are case insensitive; meaning both `.stripe` and `.STRIPE` will match `<p class="Stripe">`.

### Known Issues

Whitespace around child and sibling selectors is mandatory, meaning:

* `div > p` is valid, and
* `div>p` is **NOT** valid


Also, the following selectors are not / can not be supported:

* The link pseudo-classes `:link` and `:visited` can not be supported because they refer to a DOM model.
* The dynamic pseudo-classes `:hover`, `:active`, and `:focus` can not be supported because they require user input.
* The pseudo-elements `:first-line`, `:first-letter`, `:before`, and `:after` can not be supported because they do not select XML elements.


