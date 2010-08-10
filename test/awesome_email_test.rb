# coding: utf-8
$KCODE = 'u' unless RUBY_VERSION >= '1.9'

require File.join(File.dirname(__FILE__), 'test-app', 'config', 'environment')

require 'awesome_email'

require 'test/unit'
require 'test_helper'

ActionMailer::Base.delivery_method = :test

CSS_TEST_FILE = Rails.root.join('public', 'stylesheets', 'test.css').to_s


###############################################################

# test mailer
class MyMailer
  def render_message(method_name, body)
  end
  
  def parse_css_from_file(file_name)
    'h1 {font-size: 140.0% !important}'
  end
  
  def mailer_name
    'my_mailer'
  end
  
  # include neccessary mixins
  include ActionMailer::AdvAttrAccessor
  include ActionMailer::ConvertEntities
  include ActionController::Layout
  include ActionMailer::InlineStyles
end

MyMailer.send(:public, *MyMailer.protected_instance_methods)
MyMailer.send(:public, *MyMailer.private_instance_methods)

###############################################################

# not so great actually, please do help improve this
class AwesomeEmailTest < Test::Unit::TestCase
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @css = 'h1 {font-size: 140.0% !important}'
    @mailer = MyMailer.new
  end
  
  #######################
  # inline styles tests #
  #######################
  
  def test_should_build_correct_find_css_file_name
    assert_equal CSS_TEST_FILE, @mailer.build_css_file_name('test')
  end
  
  def test_should_build_correct_file_name_from_set_css
    @mailer.css 'test'
    assert_equal CSS_TEST_FILE, @mailer.build_css_file_name_from_css_setting
  end
  
  def test_should_build_no_file_name_if_css_not_set
    assert_equal '', @mailer.build_css_file_name_from_css_setting
  end
  
  def test_should_not_change_html_if_no_styles_were_found
    html = build_html('', '')
    result = render_inline(html)
    assert_not_nil result
    assert_equal html.gsub(/\n/, ''), result.gsub(/\n/, '')
  end
  
  def test_should_add_style_information_found_in_css_file
    html = build_html('<h1>bla</h1>')
    result = render_inline(html)
    assert_not_nil result
    assert_not_equal html, result
    assert result =~ /<h1 style="(.*)font-size:/
  end
  
  def test_should_create_css_for_h1
    inlined = render_inline(build_html('<h1>bla</h1>'))
    assert_not_nil inlined
    assert_equal "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<html>\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"></head>\n<body><h1 style=\"font-size: 140.0%;\">bla</h1></body>\n</html>\n", inlined
  end
  
  def test_should_cummulate_style_information
    html = build_html(%Q{<h1 id="oh-hai" class="green-thing" style="border-bottom: 1px solid black;">u haz a flavor</h1>})
    inlined = render_inline(html)
    assert inlined =~ /border-bottom/
  end
  
  ##########################
  # convert entities tests #
  ##########################
  
  def test_should_replace_entities
    expected = '&auml; &Auml;'
    result = @mailer.convert_to_entities('ä Ä')
    assert_equal expected, result
  end
  
  ################
  # layout tests #
  ################
  
  # make sure the accessors are available
  def test_should_have_awesome_email_accessor_methods
    if RUBY_VERSION >= '1.9'
      assert ActionMailer::Base.instance_methods.include?(:'css')
      assert ActionMailer::Base.instance_methods.include?(:'css=')
      assert ActionMailer::Base.methods.include?(:'layout')
    else
      assert ActionMailer::Base.instance_methods.include?('css')
      assert ActionMailer::Base.instance_methods.include?('css=')
      assert ActionMailer::Base.methods.include?('layout')
    end
  end
  
  # check for delivery errors
  def test_should_deliver
    SimpleMailer.deliver_test
    assert SimpleMailer.deliveries.size > 0
  end
  
  # test all of the awesomeness
  def test_should_render_layout_convert_entities_and_apply_css
    SimpleMailer.deliver_test
    assert SimpleMailer.deliveries.last.body =~ /<h1>F&auml;ncy<\/h1><p>test inner content<\/p>/
  end
  
end
