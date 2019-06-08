module Bbcode
	# Scans a string and converts it to a stream of bbcode tokens.
	class Tokenizer
		# BBCODE_TAG_PATTERN = /\[(\/?)([a-z0-9_-]*)(\s*=?(?:(?:\s*(?:(?:[a-z0-9_-]+)|(?<=\=))\s*[:=]\s*)?(?:"[^"\\]*(?:\\[\s\S][^"\\]*)*"|'[^'\\]*(?:\\[\s\S][^'\\]*)*'|[^\]\s,]+|(?<=,)(?=\s*,))\s*,?\s*)*)\]/i
		ATTRIBUTE_PATTERN = /(?:\s*(?:([a-z0-9_-]+)|^)\s*[:=]\s*)?("[^"\\]*(?:\\[\s\S][^"\\]*)*"|'[^'\\]*(?:\\[\s\S][^'\\]*)*'|[^\]\s,]+|(?<=,)(?=\s*,))\s*,?/i
		UNESCAPE_PATTERN = /\\(.)/

		# TODO: Rewrite this mess of a gem
		# TODO: Until then, at least fix attribute parsing:
		#  [html a=" c="d"]content[/html] # => {"a"=>" c=", 0=>"d\""}
		def parse_attributes_string( attributes_string )
			attrs = HashWithIndifferentAccess.new
			return attrs if attributes_string.nil?

			next_anonymous_key = -1
			attributes_string.scan ATTRIBUTE_PATTERN do |key, value|
				skip_value = key.blank? && value.blank?
				key = next_anonymous_key+=1 if key.blank?
				unless skip_value
					value = value[1...-1].gsub UNESCAPE_PATTERN, "\\1" if value[0] == value[-1] && ["'", '"'].include?(value[0])
					attrs[key] = value
				end
			end

			return attrs
		end

		# Parses the document as BBCode-formatted text and calls block with bbcode
		# events.
		#
		# The handler will have the following methods called:
		# - .text text
		#   A text-event with an additional parameter containing the actual text.
		# - .start_element element_name, element_arguments
		#   An element-event with 2 additional parameters: The element name as a
		#   symbol and the element attributes as a hash. This events indicate the
		#   start of the element.
		# - .end_element element_name
		#   An element-event indicating the end of an element. Optionally, the
		#   element_name is added as a parameter. If no parameter is present, it is
		#   assumed to be the last started element.
		#
		# Note that :start_element and :end_element are not guaranteed to be called
		# evenly or in the "correct" order. You must match correct start- and end
		# tags yourself to create the elements.
		#
		# Also note that :text events are not guaranteed to match the whole text.
		# In some cases, the text might be separated to multiple :text events, even
		# though there are no nodes in between.
		def tokenize(document, handler)
			pattern = /\[(\/?)(#{handler.element_handler_names.join('|')})([^\[\]]*)\]/i

			while (match = pattern.match(document))
				offset = match.begin(0)
				elem_source = match[0]

				handler.text document[0...offset] unless offset == 0

				elem_is_closing_tag = match[1]=='/'
				elem_name = (match[2].length > 0 && match[2].to_sym) || nil
				elem_attr_string = (match[3].length > 0 && match[3]) || nil

				if (elem_is_closing_tag && !elem_attr_string) || (!elem_is_closing_tag && elem_name)
					if !elem_is_closing_tag
						handler.start_element elem_name, parse_attributes_string(elem_attr_string), elem_source
					else
						handler.end_element elem_name, elem_source
					end
				else
					handler.text elem_source
				end

				document = document[(offset+elem_source.length)..-1]
			end

			handler.text document unless document.length == 0
		end
	end
end
