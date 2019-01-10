require 'line/bot'
class KamigoController < ApplicationController
  protect_from_forgery with: :null_session

  def eat
    render plain: "吃土啦~123"
  end 

  def webhook
    head :ok    
  end
  

  # Line Bot API 物件初始化
  def line
    @line ||= Line::Bot::Client.new { |config|
      config.channel_secret = '4287d0f92b9461dd4f15c8448e496b0b'
      config.channel_token = '13SitYEKLmxGk/MTzMCPFWmh5q3BXeJaxYAfWS/kAp2rHKCc7MieOD1qnuzGcAyyledP+jpkU/gxv7309f5AyPLqdnvzj/AkEWkmd3kXVAXBNowxgjHKl9zNfrlibaIpAD6NgX5rRZB4+cfbd/2M+gdB04t89/1O/w1cDnyilFU='
    }
  end

  def webhook_
    # 設定回覆文字
    reply_text = keyword_reply(received_text)

    # 傳送訊息到 line
    response = reply_to_line(reply_text)
    
    # 回應 200
    head :ok
  end 


  # 取得對方說的話
  def received_text
    message = params['events'][0]['message']
    message['text'] unless message.nil?
  end

  # 關鍵字回覆
  def keyword_reply(received_text)
    # 學習紀錄表
    keyword_mapping = {
      'QQ' => '神曲支援：https://www.youtube.com/watch?v=T0LfHEwEXXw&feature=youtu.be&t=1m13s',
      '我難過' => '別難過 送上神曲支援：https://www.youtube.com/watch?v=T0LfHEwEXXw&feature=youtu.be&t=1m13s'
    }
    
    # 查表
    keyword_mapping[received_text]
  end

  # 傳送訊息到 line
  def reply_to_line(reply_text)
    return nil if reply_text.nil?
    
    # 取得 reply token
    reply_token = params['events'][0]['replyToken']
    
    # 設定回覆訊息
    message = {
      type: 'text',
      text: reply_text
    } 

    # 傳送訊息
    line.reply_message(reply_token, message)
  end


  #測試過程

  def request_headers
    render plain: request.headers.to_h.reject{ |key, value|
      key.include? '.'
    }.map{ |key, value|
      "#{key}: #{value}"
    }.sort.join("\n")
  end

  def response_headers
    response.headers['5566'] = 'QQ'
    render plain: response.headers.to_h.map{ |key, value|
      "#{key}: #{value}"
    }.sort.join("\n")
  end

  def request_body
    render plain: request.body
  end

  def show_response_body
    puts "===這是設定前的response.body:#{response.body}==="
    render plain: "虎哇花哈哈哈123"
    puts "===這是設定後的response.body:#{response.body}==="
  end

  def sent_request
    uri = URI('https://learning-kamigo.herokuapp.com/kamigo/response_body')
    response = Net::HTTP.get(uri).force_encoding("UTF-8")
    render plain: translate_to_korean(response)
  end

  def translate_to_korean(message)
    "#{message}油~"
  end


end