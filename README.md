A BBcode parser designed to be used with Ruby on Rails
======================================================
A bbcode parser gem you can include in your rails app to parse bbcode-formatted
strings to HTML or any other format you like.

The bbcode gem consists of 4 parts:

- The `Tokenizer`-class, which converts the bbcode-formatted string to a stream
  of tokens.
- The `Parser`-class, which attempts to pair bbcode tags to bbcode elements.
- The `Handler`-class, which converts bbcode elements anyway you like.
- The `Helpers`-module, which adds a method to String, allowing you to convert
  bbcode-formatted strings with a registered handler.

Additionally, a `HtmlHandler` class is available. This class is a Handler
designed to convert bbcode elements to HTML more easily.

Installation:
-------------
Add the gem to the gemfile of your project.
(todo: add examples)

Usage:
------
Create and register a handler. In this example, I'm creating a HtmlHandler and
I'm going to register it as `:html`.

```ruby
Bbcode::Base.register_handler :html, Bbcode::HtmlHandler.new(
	:b => :strong,
	:i => :em,
	:url => [ :a, { :href => "%{0}" } ],
	:txt => ->(element){ "#{element.content.source}" },
	:img => ->(element){ %(<img src="#{CGI.escapeHTML(element.content.source)}">) },
	:color => [ :span, { :style => "color: %{0};" } ]
)
```

That's it! You can now parse any string as bbcode and convert it to html with
the `:html`-handler like this:

```ruby
"[b]Hello, bold world![/]".as_bbcode.to :html
# => <strong>Hello, bold world!</strong>
```

If you're using this gem in a rails project, I would recommend registering your
handlers in an initializer.

See examples in `spec/` folder for detailed examples of usage.

Features:
---------
* Parsing regular bbcode tags like `[b]` and `[/b]`.
* Parsing anonymous closing bbcode tags like `[/]`.
* Parsing bbcode tags with arguments like `[a=foo, bar]`, `[a foo=1 bar:2]`,
  `[a=foo, bar bar:1 foo=2]` and `[a="foo" b='bar']`.
* Parsing nested bbcode elements like `[b]bold[i]and italic[/]only bold[/]`,
  which might result to `<b>bold<i>and italic</i>only bold</b>`.
* Parsing incorrectly nested bbcode elements like `[b]bold[i]and italic[/b]only
  italic[/]`, which might result to `<b>bold<i>and italic</i></b><i>only
  italic</i>`.

Todo:
-----
* An easier way to handle text around bbcode tags to, for example, add smileys
  and wrap hyperlinks to URLs. Currently, the only way to achieve this is by
  adding a `:"#text"`-handler to your handler and adding the functionality
  yourself.
* An easier way to include the content, source or content-source in the
  `HtmlHandler`-class.
* Review handleability of element interrupts.
* Review regular expression matching bbcode tags to allow tags having names
  containing characters other than `A-Z`, `0-9`, `_` and `-`, possibly based on
  the current registered tags.
* Add CDATA-like feature for bbcode tags to allow tags to be ignored within
  certain elements. Useful for `[code]`-tags.
* Add a default handler with the most common bbcode tags.