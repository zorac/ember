# Ember - a CLI eBook reader

Ember is a very basic command-line interface to reading eBooks. Features:

- Supports EPUB format ebooks (tested with generic and iBooks-purchased)
- Handles books in single-file or uncompressed formats
- Supports macOS (tested) and Linux (hopefully), but not yet Windows
- Remembers last position in each book

## Requirements

Ember uses a number of third-party CPAN modules. If any are missing, it will
provide an error mrssaga on startup tellling you how to install them.

## Installation

You can run Ember directly from the bin directory, or install the scrupt and
libraries into the standard locations for your Perl installation:

```sh
perl Makefile.PL
make install
```

## Usage

Open an eBook using the command `ember SomeBook.epub`. If you don't specify a
file, a list of nay recently-opened books will be displayed.

The following keypresses are supported to navigate the application:

- **N**, ***Space*** - next page
- **P**,  **B** - previous page
- **I** - view book info
- **C** - view table of contents
- **R** - refresh screen
- **Q**, ***Escape*** - go back to the previous screen, or quit
- **H** - display help for the current screen

## Supported eBook Formats:

- EPUB (only partial support for EPUB3)
