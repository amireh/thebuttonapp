# thebuttonapp 

A consulting work time tracking app. The app is written in Ruby, and uses the following primary dependencies:

* Sinatra
* DataMapper (against a MySQL back-end)
* Pony for sending emails
* Gravatarify for gravatar integration
* OmniAuth (FB, Twitter, and Github) for authentication

For unit testing, RSpec is used primary. Integration testing is done using Capybara and Capybara-webkit for headless browser testing.

The front-end uses valid HTML5 semantics, CSS3, and some JavaScript using jQuery. No CoffeeScript or SASS at the moment of writing.

## Installation

Get the required gems (using bundler) and set up the database:

```bash
rake db:setup
```

Afterwards, you need to set up the `config/credentials.yml` file. See the credentials template file for its structure and what should be in it.

## Testing

Run `rspec` using bundler:

`bundler exec rspec spec/`

## License

```text
Copyright (c) 2012-2013 Algol Labs LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
