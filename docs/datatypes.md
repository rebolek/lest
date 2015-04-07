Title: Lest syntax and datatypes
Date: 2015-02-10 11:07 

Lest has come a long way from being a simple template engine. Lot of functionality has been added and it's turning from a dialect to a language. The extended functionality must be also supported internally. So now I'm working on addition of datatypes to Lest (spoiler: they are working already) and I'd like to write about them a bit.

Syntax
======

Because Lest is interpreted in [Rebol](http://www.rebol.com/) using [block parsing](http://www.rebol.com/docs/core23/rebolcore-15.html#section-9), its syntax is same as Rebol's. It's very compact and light weighted but expressive and powerful at the same time. If you're not familiar with Rebol, it's based on premise that code is data and it's very strict in this regard. Unlike most of other languages, every symbol in Rebol has its own datatype. You can read more about Rebol types and values [here](http://www.rebol.com/docs/core23/rebolcore-4.html#section-3). But let's focus on Lest types which are bit different than in Rebol.

Datatypes
=========

Lest is implemented in Rebol but the datatypes have been changed more to fit Lest usage. Let's have a look at them.

string!
---------

**String!** is basic type. Syntax is same as in Rebol, you enclose string in "qoutes" or in {braces}.

integer!
-----------

Unlike Rebol, **integer!** in Lest has two forms. Same as in Rebol -* 1, 23, 1976, ...* and also string form - *"1", {23}, "1976", ...*. both forms are interchangeable, you can write`1 + 1`, `1 + "1"` or `"1" + "1"` - it's the same in Lest.

word!
--------

Words are used for different purposes. They can hold values of different types. Word syntax is simple, words can contain alphanumeric characters and cannot start with a number. *word*, *word23*, *žirafa* are all valid words, *2three* is not. Words also cannot start with a dot character. See **class** below.

id!
---

**Id!** is used as tag id. It's syntax is same as Rebol's issue - *#some-id*.

class!
-------

**Class!** is used as tag class. Class is basically a **word!** that starts with a dot character - *.class*, *.class23*, *.žirafa*.

block!
---------

Same as in Rebol, Lest makes a heavy use of blocks. Block is collection of datatypes, enclosed in brackets: *[this is a block]*, *[this block [is nested]]*, *[h1 #title .header "Different types in one block"]*, etc.

command!
---------------

**Command!** has no special syntax, it looks just like a word. Lest is not as freeform as Rebol and all commands are reserved words. It's possible to create new commands with Lest plugins. Example commands are *if*, *join*, *<*, ...

tag!
-----

**Tag!** is special kind of command. The main difference is that tags emit value, while commands don't. Unlike in Rebol (or HTML), Lest tags are just words. So instead of *<h1>*, you write *h1*. 

template!
-------------

**Template!** is like a function - it's block of Lest code that can take one or more parameters.