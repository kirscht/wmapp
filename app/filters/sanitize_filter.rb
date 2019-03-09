# encoding: utf-8

class SanitizeFilter < Filter
  def process(post)
    # Normalize <script> tags so the parser will find them
    post = post.gsub(%r{<script[\s/]*}i, "<script ")

    parser = Nokogiri::HTML::DocumentFragment.parse(post)

    remove_unsafe_tags(parser)
    strip_event_handlers(parser)
    strip_ujs_attributes(parser)
    enforce_allowscriptaccess(parser)

    parser.to_html
  end

  private

  def remove_unsafe_tags(parser)
    %w(applet base meta link script form).each do |tag_name|
      parser.search(tag_name).remove
    end
  end

  def jquery_ujs_attributes
    %w(
      data-confirm
      data-disable-with
      data-method
      data-params
      data-remote
      data-type
      data-url
    )
  end

  def strip_event_handlers(parser)
    parser.search("*").each do |elem|
      elem.attributes.each do |name, attr|
        # XSS fix
        if attr.value &&
           attr.value.downcase.gsub(/[\\]*/, "") =~ /^[\s]*javascript\:/
          elem.remove_attribute(name)
        end
        # Strip out event handlers
        elem.remove_attribute(name) if name.downcase =~ /^on/
      end
    end
  end

  def strip_ujs_attributes(parser)
    parser.search("*").each do |elem|
      elem.attributes.each do |name, _|
        if jquery_ujs_attributes.include?(name.downcase)
          elem.remove_attribute(name)
        end
      end
    end
  end

  # Enforces allowScriptAccess = sameDomain on iframes and other embeds.
  def enforce_allowscriptaccess(parser)
    parser.search("*")
          .each { |e| change_allowscriptaccess_attribute_on(e) }

    parser.search("embed")
          .each { |e| enforce_allowscriptaccess_attribute_on(e) }

    # Change allowScriptAccess in param tags
    parser.search("param")
          .each { |e| change_allowscriptaccess_for_param(e) }

    # Make sure there's a <param name="allowScriptAccess" value="sameDomain">
    # in object tags
    parser.search("object")
          .each { |e| enforce_allowscriptaccess_param_in(e) }
  end

  # Changes allowScriptAccess to sameDomain on element if the attribute
  # is present.
  def change_allowscriptaccess_attribute_on(element)
    element.attributes.each do |name, _value|
      if name.downcase =~ /^allowscriptaccess/
        element.set_attribute name, "sameDomain"
      end
    end
  end

  # Adds allowScriptAccess to element if the attribute isn't present.
  def enforce_allowscriptaccess_attribute_on(element)
    element.set_attribute "allowScriptAccess", "sameDomain"
  end

  # Changes value on param to sameDomain if name = allowScriptAccess.
  def change_allowscriptaccess_for_param(element)
    element.attributes.each do |name, attr|
      # Change allowScriptAccess to sameDomain
      next unless name.casecmp("name").zero? &&
                  attr.value.casecmp("allowscriptaccess").zero?
      element.set_attribute "name", "allowScriptAccess"
      element.set_attribute "value", "sameDomain"
    end
  end

  # Makes sure the element contains an allowScriptAccess param.
  def enforce_allowscriptaccess_param_in(element)
    if element.search(">param[name=allowScriptAccess]").empty?
      element.inner_html +=
        '<param name="allowScriptAccess" value="sameDomain" />'
    end
  end
end
