# Custom build scripts, replacing the Rakefile. To invoke (for example):
#
# bin/node_coffee -r tasks.coffee -- parser

fs: require 'fs'
coffee: require 'coffee-script'

# Run a CoffeeScript through our node/coffee interpreter.
run: (args) ->
  proc: process.createChildProcess 'bin/node_coffee', args
  proc.addListener 'error', (err) -> if err then puts err

# Print the usage message for the build scripts.
usage: ->
  puts "tasks.coffee usage goes here..."

# Build the CoffeeScript source code -- if you're editing the parser, run
# this before you run "build parser".
build_compiler: ->
  fs.readdir('src').addCallback (files) ->
    files: 'src/' + file for file in files when file.match(/\.coffee$/)
    run ['-o', 'lib/coffee_script'].concat(files)

# Rebuild the Jison parser from the compiled lib/grammar.js file.
build_parser: ->
  parser: require('grammar').parser
  js: parser.generate()
  parser_path: 'lib/coffee_script/parser.js'
  fs.open(parser_path, process.O_CREAT | process.O_WRONLY | process.O_TRUNC, parseInt('0755', 8)).addCallback (fd) ->
    fs.write(fd, js)

# Run the CoffeeScript test suite.
run_tests: ->
  process.mixin require 'assert'
  fs.readdir('test').addCallback (files) ->
    for file in files
      fs.cat('test/' + file).addCallback (source) ->
        js: coffee.compile source
        process.compile js, file


switch process.ARGV[0]
  when undefined     then usage()
  when 'compiler'    then build_compiler()
  when 'parser'      then build_parser()
  when 'test'        then run_tests()
  when 'highlighter' then build_highlighter()
  when 'underscore'  then build_underscore()