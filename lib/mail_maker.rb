class MailMaker
  extend ActionView::Helpers::CaptureHelper

  def self.stylesheet
    @stylesheet ||= {}
  end

  def self.stylesheet=(val)
    @stylesheet = val
  end

  def self.template_root
    @template_root = Rails.root.join("app", "views", "mail")
  end

  def self.layout
    @layout ||= "application"
  end

  def self.layout=(val)
    @layout = val
  end

  def self.parse_template(name, vars, opts={})
    fp = File.join(template_root, name)
    fp += ".html.erb" unless fp.include?(".")
    tpl = File.read(fp)
    ltpl = nil
    if layout || opts[:layout]
      lf = (layout || opts[:layout])
      lf += ".html.erb" if !lf.include?(".")
      lp = File.join(template_root, "layouts", lf)
      ltpl = File.read(lp)
    end
    html = MailMaker::Renderer.new(vars).render(tpl, layout: ltpl)
    #puts html
    return html
  end

  class Renderer

    def initialize(vars, opts={})
      @vars = vars
      vars.each {|k,v|
        self.instance_variable_set("@#{k}".to_sym, v)
      }
    end

    def render(template, opts={})
      @content = template
      tpl = opts[:layout] ? opts[:layout] : template
      ERB.new(tpl, nil, "<>", "@_erbout").result(binding)
    end

    def yield_content
      MailMaker::Renderer.new(@vars).render(@content)
    end

    def capture(&block)
      tmp_buffer, @_erbout = @_erbout, ""
      result = block.yield
      @_erbout
    ensure
      @_erbout = tmp_buffer
    end

    def concat(str)
      @_erbout << str
    end

    def block_wrap(opts={}, &block)
      ret = "<tr><td #{build_style(opts)}>"
      ret += capture(&block) if block_given?
      ret += "</td></tr>"
      concat(ret)
      return ret
    end

    def img(src, opts={})
      iopts = {vertical_align: 'middle'}.merge(opts)
      ret = "<img src=\"#{src}\" #{build_style(opts)}/>"
      return ret
    end

    def media_block(opts)
      ropts = {padding: [0, 0, 20, 0]}.merge(opts[:block] || {})
      ret = "<tr><td #{build_style(ropts)}>"
      ret += "<table style='width: 100%;'><tr>"
      ret += "<td style=\"width: 160px;\">"
      ret += img(opts[:image_url], width: 150)
      ret += "</td>"
      ret += "<td style='padding-left: 10px;'>"
      ret += "<div style='font-weight: bold; padding-bottom: 10px;'>#{opts[:title]}</div>"
      ret += "#{opts[:body]}"
      ret += "</td>"
      ret += "</tr></table>"
      ret += "</td></tr>"
      return ret
    end

    def build_style(opts)
      ret = "style=\""
      if cls = opts[:class]
        cls.split(" ").each do |tc|
          cs = MailMaker.stylesheet[tc]
          next if cs.nil?
          cs += ";" if !cs.strip.end_with?(";")
          ret += "#{cs} "
        end
      end
      if pad = opts[:padding]
        if pad.is_a?(Array)
          ps = pad.collect{|p| "#{p}px"}.join(" ")
          ret += "padding: #{ps}; "
        else
          ret += "padding: #{pad}px; "
        end
      end
      if width = opts[:width]
        ret += "width: #{width}px; "
      end
      if height = opts[:height]
        ret += "width: #{height}px; "
      end
      if bg = opts[:background]
        ret += "background-color: #{bg}; "
      end
      if align = opts[:align]
        ret += "text-align: #{align}; "
      end
      if va = opts[:vertical_align]
        ret += "vertical-align: #{va}; "
      end
      if style = opts[:style]
        style += ";" if !style.strip.end_with?(";")
        ret += "#{style} "
      end
      ret = ret.strip
      ret += "\""
      return ret
    end

  end
end
