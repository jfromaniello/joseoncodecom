module Jekyll
  # Extensions to the Jekyll Page class.

  class Page
  
    # Chained version of render() method. This version takes the
    # output (from self.output) and "fixes" escaped Liquid
    # strings, allowing Liquid markup to be escaped, for display.
    alias orig_render render
    def render(layouts, site_payload)
        res = orig_render(layouts, site_payload)
        self.output = fix_liquid_escapes(self.output)
        res
    end

    def fix_liquid_escapes(s)
        s.gsub!('\\{\\{', '{{')
        s.gsub!('\\}\\}', '}}')
        s.gsub!('\\%', '%')
        s
    end
  end  

  # Extensions to the Jekyll Post class.

  class Post
  
    # Chained version of render() method. This version takes the
    # output (from self.output) and "fixes" escaped Liquid
    # strings, allowing Liquid markup to be escaped, for display.
    alias orig_render render
    def render(layouts, site_payload)
        res = orig_render(layouts, site_payload)
        self.output = fix_liquid_escapes(self.output)
        res
    end

    def fix_liquid_escapes(s)
        s.gsub!('\\{\\{', '{{')
        s.gsub!('\\}\\}', '}}')
        s.gsub!('\\%', '%')
        s
    end
  end
end