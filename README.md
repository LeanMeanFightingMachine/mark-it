# mark-it

**mark-it** is a simple tool to match patterns in your files and replace they with the content of another markdown file instead.

This tool was created specially for our personal need of editing/adding html content to JSON files, where the content of your object can't have multi-line strings.

But you are not strict to JSON files only, **mark-it** can process any other text format file.

## Instalation
```
[sudo] npm install -g mark-it
```

## CLI
Command line interface help screen.

```
Usage:
  mark-it [options]

Options:
  -h, --help           display the help information
  -i, --input <path>   input folder of your files (required)
  -o, --output <path>  output folder where your files will be saved (default to --input)

Example:
  mark-it -i input/ -o output/
```

## How?
**mark-it** will read all your files, look for any tags on it and then it will replace they by a markdown content specified on your tag. The tag should look like this:

```
{{#md path/to/your/markdown.md }}
```
*The path of your markdown file is relative to the `--input` parameter.*


## Example

#### Command

```
mark-it -i input/ -o output/
```


#### input/post.json

```
{
   "title": "Title of my post",
   "image": "/img/image.png",
   "content": "{{#md md/post-content.md}}"
}
```

#### input/md/post-content.md

```
# Hello world, I am a h1
## And I am a h2

You can also add **paragraphs**, **lists**, **tables**, etc… Basically everything that [Markdown](http://daringfireball.net/projects/markdown/) has to offer.

- Creating
- lists
- were
- never
- easier
```

#### output/post.json

```
{
   "title": "Title of my post",
   "image": "/img/image.png",
   "content": "<h1>Hello world, I am a h1</h1><h2>And I am a h2</h2><p>You can also add <strong>paragraphs</strong>, <strong>lists</strong>, <strong>tables</strong>, etc… Basically everything that <a href='http://daringfireball.net/projects/markdown/'>Markdown</a> has to offer.</p><ul><li>Creating</li><li>lists</li><li>were</li><li>never</li><li>easier</li></ul>"
}
```