gulp = require 'gulp'
coffee = require 'gulp-coffee'
rimraf = require 'rimraf'

gulp.task 'coffee', ->
  gulp.src 'app.coffee'
    .pipe coffee()
    .pipe gulp.dest('')
  gulp.src 'public/scripts/*.coffee'
    .pipe coffee()
    .pipe gulp.dest('build/')

gulp.task 'stylesheets', ->
  gulp.src ['public/stylesheets/**']
    .pipe gulp.dest 'build/stylesheets'

gulp.task 'libs', ->
  gulp.src ['public/libs/*']
    .pipe gulp.dest 'build'

gulp.task 'build', ['clean'], ->
  gulp.run 'coffee'
  gulp.run 'libs'
  gulp.run 'stylesheets'

gulp.task 'default', ->
  gulp.run 'build'

gulp.task 'watch', ['build'], ->
  gulp.watch 'public/scripts/*.coffee', ['coffee']
  gulp.watch './*.coffee', ['coffee']
  gulp.watch 'public/stylesheets/**', ['stylesheets']
  gulp.watch 'public/libs/*', ['libs']

gulp.task 'clean', (cb) ->
  rimraf './build', cb
