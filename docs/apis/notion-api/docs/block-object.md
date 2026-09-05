# Block

**Source:** https://developers.notion.com/reference/block
**Date:** 2026-03-01

---

A block object represents a piece of content within Notion. The API translates the headings, toggles, paragraphs, lists, media, and more that you can interact with in the Notion UI as different block type objects.

## Example Block Object

```json
{
  "object": "block",
  "id": "c02fc1d3-db8b-45c5-a222-27595b15aea7",
  "parent": {
    "type": "page_id",
    "page_id": "59833787-2cf9-4fdf-8782-e53db20768a5"
  },
  "created_time": "2022-03-01T19:05:00.000Z",
  "last_edited_time": "2022-07-06T19:41:00.000Z",
  "created_by": {
    "object": "user",
    "id": "ee5f0f84-409a-440f-983a-a5315961c6e4"
  },
  "last_edited_by": {
    "object": "user",
    "id": "ee5f0f84-409a-440f-983a-a5315961c6e4"
  },
  "has_children": false,
  "archived": false,
  "in_trash": false,
  "type": "heading_2",
  "heading_2": {
    "rich_text": [
      {
        "type": "text",
        "text": {
          "content": "Lacinato kale",
          "link": null
        },
        "annotations": {
          "bold": false,
          "italic": false,
          "strikethrough": false,
          "underline": false,
          "code": false,
          "color": "green"
        },
        "plain_text": "Lacinato kale",
        "href": null
      }
    ],
    "color": "default",
    "is_toggleable": false
  }
}
```

Use the Retrieve block children endpoint to list all of the blocks on a page.

## Keys

> **Note:** Fields marked with an * are available to integrations with any capabilities. Other properties require read content capabilities in order to be returned from the Notion API.

| Field | Type | Description | Example value |
|-------|------|-------------|---------------|
| `object`* | `string` | Always `"block"`. | `"block"` |
| `id`* | `string` (UUIDv4) | Identifier for the block. | `"7af38973-3787-41b3-bd75-0ed3a1edfac9"` |
| `parent` | `object` | Information about the block's parent. See Parent object. | `{ "type": "block_id", "block_id": "7d50a184-5bbe-4d90-8f29-6bec57ed817b" }` |
| `type` | `string` (enum) | Type of block. Possible values: `"bookmark"`, `"breadcrumb"`, `"bulleted_list_item"`, `"callout"`, `"child_database"`, `"child_page"`, `"column"`, `"column_list"`, `"divider"`, `"embed"`, `"equation"`, `"file"`, `"heading_1"`, `"heading_2"`, `"heading_3"`, `"image"`, `"link_preview"`, `"numbered_list_item"`, `"paragraph"`, `"pdf"`, `"quote"`, `"synced_block"`, `"table"`, `"table_of_contents"`, `"table_row"`, `"template"`, `"to_do"`, `"toggle"`, `"transcription"`, `"unsupported"`, `"video"` | `"paragraph"` |
| `created_time` | `string` (ISO 8601 date time) | Date and time when this block was created. | `"2020-03-17T19:10:04.968Z"` |
| `created_by` | Partial User | User who created the block. | `{"object": "user","id": "45ee8d13-687b-47ce-a5ca-6e2e45548c4b"}` |
| `last_edited_time` | `string` (ISO 8601 date time) | Date and time when this block was last updated. | `"2020-03-17T19:10:04.968Z"` |
| `last_edited_by` | Partial User | User who last edited the block. | `{"object": "user","id": "45ee8d13-687b-47ce-a5ca-6e2e45548c4b"}` |
| `archived` | `boolean` | **Deprecated.** Use `in_trash` instead. Alias for `in_trash`. | `false` |
| `in_trash` | `boolean` | Whether the block has been trashed. Use as body parameter in Update a block to trash or restore a block. | `false` |
| `has_children` | `boolean` | Whether or not the block has children blocks nested within it. | `true` |
| `{type}` | block type object | An object containing type-specific block information. | See block type object section |

### Block types that support child blocks

Some block types contain nested blocks. The following block types support child blocks:
- Bulleted list item
- Callout
- Child database
- Child page
- Column
- Heading 1 (when `is_toggleable` property is `true`)
- Heading 2 (when `is_toggleable` property is `true`)
- Heading 3 (when `is_toggleable` property is `true`)
- Numbered list item
- Paragraph
- Quote
- Synced block
- Table
- Template
- To do
- Transcription
- Toggle

> **Note — The API does not support all block types.**
> Only the block type objects listed in the reference below are supported. Any unsupported block types appear in the structure, but contain a `type` set to `"unsupported"`.

## Block type objects

Every block object has a key corresponding to the value of `type`. Under the key is an object with type-specific block information.

Many block types support rich text. In cases where it is supported, a `rich_text` object is included.

### Audio

An audio block has the following structure. It supports external file references and file uploads.

**Supported audio types:** `.aac`, `.aiff`, `.amr`, `.flac`, `.m4a`, `.mp3`, `.mp4`, `.mpeg`, `.mpga`, `.oga`, `.ogg`, `.opus`, `.wav`, `.webm`

### Bookmark

A bookmark block contains a `url` field (string, required).

```json
{
  "type": "bookmark",
  "bookmark": {
    "caption": [],
    "url": "https://companywebsite.com"
  }
}
```

### Breadcrumb

A breadcrumb block is an empty object: `"breadcrumb": {}`

### Bulleted list item

```json
{
  "type": "bulleted_list_item",
  "bulleted_list_item": {
    "rich_text": [{
      "type": "text",
      "text": {
        "content": "Lacinato kale",
        "link": null
      }
    }],
    "color": "default"
  }
}
```

### Callout

```json
{
  "type": "callout",
  "callout": {
    "rich_text": [],
    "icon": {
      "emoji": "💡"
    },
    "color": "default"
  }
}
```

### Child database

```json
{
  "type": "child_database",
  "child_database": {
    "title": "My database"
  }
}
```

### Child page

```json
{
  "type": "child_page",
  "child_page": {
    "title": "Lacinato kale"
  }
}
```

### Code

```json
{
  "type": "code",
  "code": {
    "caption": [],
    "rich_text": [{
      "type": "text",
      "text": {
        "content": "const a = 3"
      }
    }],
    "language": "javascript"
  }
}
```

Supported code block languages: `abap`, `arduino`, `bash`, `basic`, `c`, `clojure`, `coffeescript`, `c++`, `c#`, `css`, `dart`, `diff`, `docker`, `elixir`, `elm`, `erlang`, `flow`, `fortran`, `f#`, `gherkin`, `glsl`, `go`, `graphql`, `groovy`, `haskell`, `html`, `java`, `javascript`, `json`, `julia`, `kotlin`, `latex`, `less`, `lisp`, `livescript`, `lua`, `makefile`, `markdown`, `markup`, `matlab`, `mermaid`, `nix`, `objective-c`, `ocaml`, `pascal`, `perl`, `php`, `plain text`, `powershell`, `prolog`, `protobuf`, `python`, `r`, `reason`, `ruby`, `rust`, `sass`, `scala`, `scheme`, `scss`, `shell`, `sql`, `swift`, `typescript`, `vb.net`, `verilog`, `vhdl`, `visual basic`, `webassembly`, `xml`, `yaml`, `java/c/c++/c#`

### Column list and column

Column lists contain columns. Columns support child blocks.

```json
{
  "type": "column_list",
  "column_list": {}
}
```

To retrieve column content: use Retrieve block children on the `column_list` block ID to get each `column` block, then use Retrieve block children on each `column` block ID to get its content.

### Divider

`"divider": {}`

### Embed

```json
{
  "type": "embed",
  "embed": {
    "url": "https://website.domain"
  }
}
```

### Equation

```json
{
  "type": "equation",
  "equation": {
    "expression": "e=mc^2"
  }
}
```

### File

```json
{
  "type": "file",
  "file": {
    "caption": [],
    "type": "external",
    "external": {
      "url": "https://companywebsite.com/files/doc.txt"
    }
  }
}
```

### Headings

Heading 1, 2, and 3. All have `rich_text`, `color`, and `is_toggleable` fields.

```json
{
  "type": "heading_1",
  "heading_1": {
    "rich_text": [],
    "color": "default",
    "is_toggleable": false
  }
}
```

### Image

Supports external URLs and file uploads.

**Supported external image types:** `.bmp`, `.gif`, `.heic`, `.jpeg`, `.jpg`, `.png`, `.svg`, `.tif`, `.tiff`

```json
{
  "type": "image",
  "image": {
    "type": "external",
    "external": {
      "url": "https://website.domain/images/image.png"
    }
  }
}
```

### Link Preview

```json
{
  "type": "link_preview",
  "link_preview": {
    "url": "https://github.com/..."
  }
}
```

### Numbered list item

```json
{
  "type": "numbered_list_item",
  "numbered_list_item": {
    "rich_text": [{
      "type": "text",
      "text": {
        "content": "Finish reading the docs",
        "link": null
      }
    }],
    "color": "default"
  }
}
```

### Paragraph

```json
{
  "type": "paragraph",
  "paragraph": {
    "rich_text": [],
    "color": "default"
  }
}
```

### PDF

Supports external and file upload types.

### Quote

```json
{
  "type": "quote",
  "quote": {
    "rich_text": [{
      "type": "text",
      "text": {
        "content": "Design is not just what it looks like..."
      }
    }],
    "color": "default"
  }
}
```

### Synced block

**Original synced block** — the source block:
```json
{
  "type": "synced_block",
  "synced_block": {
    "synced_from": null,
    "children": []
  }
}
```

**Duplicate synced block** — references the original:
```json
{
  "type": "synced_block",
  "synced_block": {
    "synced_from": {
      "type": "block_id",
      "block_id": "original_block_id"
    }
  }
}
```

### Table

```json
{
  "type": "table",
  "table": {
    "table_width": 2,
    "has_column_header": false,
    "has_row_header": false
  }
}
```

### Table rows

```json
{
  "type": "table_row",
  "table_row": {
    "cells": [
      [{ "type": "text", "text": { "content": "column 1" } }],
      [{ "type": "text", "text": { "content": "column 2" } }]
    ]
  }
}
```

### Table of contents

```json
{
  "type": "table_of_contents",
  "table_of_contents": {
    "color": "default"
  }
}
```

### Template

A template block supports child blocks.

### To do

```json
{
  "type": "to_do",
  "to_do": {
    "rich_text": [],
    "checked": false,
    "color": "default"
  }
}
```

### Toggle blocks

```json
{
  "type": "toggle",
  "toggle": {
    "rich_text": [],
    "color": "default",
    "children": []
  }
}
```

### Video

Supports external URLs and file uploads.

**Supported video types:** `.amv`, `.asf`, `.avi`, `.f4v`, `.flv`, `.gifv`, `.mkv`, `.mov`, `.mpg`, `.mpeg`, `.mp4`, `.m4v`, `.mp4v`, `.qt`, `.wmv`

YouTube URLs are also supported.
