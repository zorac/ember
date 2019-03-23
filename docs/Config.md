# Ember Config File Format

## Keys

* last_id - The last used unique book ID
* recents - IDs of the most recently viewed books (comma-separated)
* id:{path} - Unique ID of the book at the given path
* {id}:{meta} - Metadata for the book with the given id
    * path - filesystem path
    * chapter - last chapter viewed
    * pos - reading position in the chapter
    * last - time of last access
    * search - search terms
    * Any of the fields defined in `@Ember::Metadata::FIELDS`
* i:{word} - IDs of books containing {word} in their metadata
* s:{word} - Chracters which can be suffixed to {word} to make a longer word
* p:{word} - Chracters which can be prefixed to {word} to make a longer word
