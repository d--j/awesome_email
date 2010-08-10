class SimpleMailer < ActionMailer::Base
  layout 'test'
  
  def test
    setup_multipart_mail
  end
  
  protected
    
  def setup_multipart_mail
    headers       'Content-transfer-encoding' => '8bit'
    sent_on       Time.now
    content_type  'text/html'
  end
  
end
