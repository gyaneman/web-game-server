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

gulp.task 'build', ['clean'], ->
  gulp.run 'coffee'
  gulp.src ['public/libs/*']
    .pipe gulp.dest 'build'

gulp.task 'default', ->
  gulp.run 'build'

gulp.task 'watch', ['build'], ->
  gulp.watch 'public/scripts/*.coffee', ['coffee']
  gulp.watch './*.coffee', ['coffee']

gulp.task 'clean', (cb) ->
  rimraf './build', cb
