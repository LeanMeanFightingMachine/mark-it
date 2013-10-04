colors	= require "colors"
marked = require "marked"
program = require "commander"
expand = require "glob-expand"
htmlminifier = require "html-minifier"
fs = require "fs-extra"
path = require "path"

MATCH_MD = /{{#md\s*([^}]+)\s*}}/g

module.exports = class Main

	_input : null
	_output : null
	_files : null


	constructor: ->
		# Package
		pkg = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../package.json")).toString())

		# Commander options
		program
			.version(pkg.version)
			.option("-i, --input <path>", "Input folder of your files")
			.option("-o, --output <path>", "Output file where your files will be saved")
			.parse(process.argv)

		# Marked options
		marked.setOptions gfm: true, breaks: true, sanitize:false

		# Get the parameters
		@_input = program.input
		@_output = program.output or program.input

		@_files = @_findFiles()
		@_parseFile()

	###
	Find the files on the directory
	###
	_findFiles: -> expand cwd:@_input, ["**/*.*", "!node_modules/**", "!**/*.md"]

	###
	Load and parse the file
	###
	_parseFile: ->
		# Get the next file name to load
		fileName = @_files.shift()

		# Load the file content
		@_debug "Reading".yellow, "#{@_input + fileName}".yellow.bold + "...".yellow
		data = fs.readFileSync(@_input + fileName).toString()
		return @_debug "An error ocurred when reading the file".red, "#{fileName}".red.bold unless data?

		# Return all the matched tags on your file
		tags = (start:match.index, end:match.index + match[0].length, name:@_input + match[1] while match = MATCH_MD.exec data)

		if tags.length
			# Load the markdown files (it has to be a decrementing loop because of the index)
			i = tags.length
			succeeded = 0
			while i--
				# Check if the markdown file exists
				unless fs.existsSync tags[i].name
					@_debug "- The file".red, "#{tags[i].name}".red.bold, "could not be found! Skipping it...".red
					continue
				# Get the markdown content
				markdownData = fs.readFileSync(tags[i].name).toString()
				# Compile the markdown to html
				markdownData = marked(markdownData)
				# Minify the html by removing the white space
				markdownData = htmlminifier.minify markdownData, collapseWhitespace: true
				# Replace 
				data = data.substring(0, tags[i].start) + markdownData + data.substring(tags[i].end)
				succeeded++

			@_debug "- #{succeeded}".bold.blue, "tag(s) were found and replaced successfuly in".blue, "#{@_output + fileName}\n".bold.blue

		# Save the file to your output folder
		fs.outputFileSync @_output + fileName, data
		
		if @_files.length then @_parseFile() else @_completed()

	_debug: (args...) -> console.log args.join(" ")
	###
	Complete the process
	###
	_completed: ->
		console.log "Completed! :)".bold.green
		process.exit(code=0)