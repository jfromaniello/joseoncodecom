require 'net/http'
require 'uri'

# Replace the default pygments implementation with a call 
# to an implementation of pygments in heroku cedar exposed through HTTP.
module Jekyll
    class HighlightBlock < Liquid::Block
        include Liquid::StandardFilters
        def lang
            @lang
        end
    end
    AOP.around(HighlightBlock, :render_pygments) do |hl_instance, args, proceed, abort|
        context = args[0]
        code = args[1].gsub("<", "&lt;").gsub(">", "&gt;")
        output = "<pre><code class='#{hl_instance.lang}'>#{code}</code></pre>"
        # request = Net::HTTP.post_form(URI('http://pygmentize.herokuapp.com/'), {'lang'=>hl_instance.lang, 'code'=>code})
        # output = request.body
        # output = context["pygments_prefix"] + output if context["pygments_prefix"]
        # output = output + context["pygments_suffix"] if context["pygments_suffix"]
        output
    end
end