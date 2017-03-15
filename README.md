# Adding a new theme

Here are the steps to follow:
* Download your bootstrap theme (for instance from http://bootstrap-live-customizer.com/) into [app/assets/stylesheets/themes](https://github.com/bobar/tdfb/tree/master/app/assets/stylesheets/themes)
* Run `gsed -ri "/^\s+(margin[:-]|padding[:-]|(min-)?height:|width:|font-family:\s\"|font-size:|font-weight:|line-height:).*$/d" theme.scss`
* Run `gsed -rzi "s/([{}])[^{}]*\{\s*\}/\1/g" theme.scss` multiple times until it doesn't change anything anymore (check output of `wc -l theme.scss`)
* Add it to the navbar menu in [application.html.erb](https://github.com/bobar/tdfb/blob/master/app/views/layouts/application.html.erb)
