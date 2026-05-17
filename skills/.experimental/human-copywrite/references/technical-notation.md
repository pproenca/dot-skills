# Technical notation

Style and usage rules that apply largely or exclusively to developer documentation.

When writing about a particular programming language, follow the capitalization style of that language.

## Code

Use code font for code.

Develop a method of spacing around punctuation and use it consistently. It's often best to use "English-style" spacing (one space character between words) because it's easy to remember and to stick with.

```
{height, width: extended; quo: integer); PageSize =
1024
```

## Syntax descriptions

- Use code font for **literals** (parts of the language, values, and so on).
- Use **italics** for placeholder names.
- Use **regular text** for the brackets that enclose something that's optional.
- Pay close attention to punctuation.

```
Read ([file,] var)
```

- Use embedded caps to connect words that act as a single placeholder name (`sourceFile`).
- Be consistent when naming placeholders; for example, don't alternate between `commands` and `commandList`.

## Code font in text

Most developer documentation uses code font for computer-language elements in text. Whether to use code font in text for other documents is a matter of judgment.

- Use code font for all text fragments that represent expressions in a programming language.
- Use code font for names of files, volumes, directories, and libraries.

  > `StandardCRuntime.o` library
  > `MainProg.c` file

- **Don't use a function or method name as a verb.**

  > Correct: Run `ls` on both directories.
  > Incorrect: `ls` both directories.
  > Correct: Use `cd` to change to the root directory.
  > Incorrect: `cd` to the root directory.

- **Don't mix fonts within a single word.** Rewrite to avoid forming the plural of a word in code font.

  > Correct: values of type `integer`
  > Incorrect: `integer`s

- Use regular text font, not code font, for punctuation following a word or phrase in code font, unless the punctuation mark is part of the computer-language element represented.

  > `NAN(004)`, `nan(4)`, and `NaN` are examples of acceptable input.

## Placeholder names in text

In running text, use italics when referring to a placeholder name (an artificial term that has meaning only in your documentation and is to be replaced by a value or symbol). Spell the name just as it would appear in a syntax description. Don't use a placeholder as you would use a regular English term.

> Correct: Replace *volumeName* with a name of up to 12 characters.
> Correct: The volume name can be up to 12 characters long.
> Incorrect: The *volumeName* can be up to 12 characters long.

Avoid `foo`, `bar`, and `baz` to represent hierarchical or ordered placeholder names in code examples. Instead, use names that suggest the kind of item.

> `TObject.`*FirstMethod*
> `TObject.`*SecondMethod*
