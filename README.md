[![Code Climate](https://codeclimate.com/github/bobar/tdfb.png)](https://codeclimate.com/github/bobar/tdfb)

# Setup tdb database with user bob

* Run mysql
* `CREATE DATABASE tdb;`
* `CREATE USER 'bob'@'localhost' IDENTIFIED BY 'zde';`
* `GRANT ALL PRIVILEGES ON tdb.* TO 'bob'@'localhost';`
* `FLUSH PRIVILEGES;`
* Exit mysql ands run the rake task `rake "db:sync_from_save[gmailpassword]"`

# Adding a new theme

Here are the steps to follow:
* Download your bootstrap theme (for instance from http://bootstrap-live-customizer.com/) into [app/assets/stylesheets/themes](https://github.com/bobar/tdfb/tree/master/app/assets/stylesheets/themes)
* Run `gsed -ri "/^\s+(margin[:-]|padding[:-]|(min-)?height:|(border-)?width:|font-family:\s['\"]|font-size:|font-weight:|line-height:).*$/d" theme.scss`
* Run `gsed -rzi "s/([{}])[^{}]*\{\s*\}/\1/g" theme.scss` multiple times until it doesn't change anything anymore (check output of `wc -l theme.scss`)
* Add it to the navbar menu in [application.html.erb](https://github.com/bobar/tdfb/blob/master/app/views/layouts/application.html.erb)

# Adding a new Highcharts theme
* Choose one [official](https://github.com/highcharts/highcharts/tree/master/js/themes) or [unofficial](http://jkunst.com/highcharts-themes-collection)
* Eventually [clean the json](http://www.jsoneditoronline.org/) for the official themes
* Save the json in [app/assets/stylesheets/highcharts_themes](https://github.com/bobar/tdfb/tree/master/app/assets/stylesheets/highcharts_themes)

# Running the electron app
- `npm install`
- `electron .` or `npm start`
