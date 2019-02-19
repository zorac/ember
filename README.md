# Ember - a CLI eBook reader

Ember is a very basic command-line interface to reading eBooks. Features:

- Supports EPUB format ebooks (tested with generic and iBooks-purchased)
- Handles books in single-file or uncompressed formats
- Supports macOS (tested) and Linux (hopefully), but not yet Windows
- Remembers last position in each book

## Installation

```
perl Makefile.PL
make install
```

## Usage

Open an eBook using the command `ember SomeBook.epub`. The following keypresses
are supported to navigate the applcation:

- **n**, ***space*** - next page
- **p**,  **b** - previous page
- **i** - view book info
- **c** - view table of contents
- **r** - refresh screen
- **q**, ***escape*** - quit

## Requirements

The following non-standard Perl modules can be installed via CPAN.

- Archive::Zip
- File::Slurp
- HTML::FormatText
- Term::ANSIScreen
- Term::ReadKey
- XML::Simple
