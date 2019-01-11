require 'line/bot'
class KamigoController < ApplicationController
  protect_from_forgery with: :null_session

  # Line Bot API 物件初始化
  def line
    @line ||= Line::Bot::Client.new { |config|
      config.channel_secret = '4287d0f92b9461dd4f15c8448e496b0b'
      config.channel_token = '13SitYEKLmxGk/MTzMCPFWmh5q3BXeJaxYAfWS/kAp2rHKCc7MieOD1qnuzGcAyyledP+jpkU/gxv7309f5AyPLqdnvzj/AkEWkmd3kXVAXBNowxgjHKl9zNfrlibaIpAD6NgX5rRZB4+cfbd/2M+gdB04t89/1O/w1cDnyilFU='
    }
  end

  def webhook

    # 傳送訊息
    response = reply_to_line(received_text)

    # 回應 200
    head :ok

  end


  # 取得對方說的話
  def received_text
    message = params['events'][0]['message']
    message_type = message['type']
     case message_type
        when "text"
          get_usertxt = message['text'];

          when  "已幫您完成預約"
             message = {
            type: 'text',
            text:  "OK"
          }
        else

          message = {
          "type": "template",
            "altText": "確定要預約嗎？",
            "template": {
                "type": "confirm",
                "text": message['text'] + '~',
                "actions": [
                    {
                      "type": "message",
                      "label": "確定喔！",
                      "text": "已幫您完成預約"
                    },
                    {
                      "type": "message",
                      "label": "讓我想想！",
                      "text": " ~ 再跟我說"
                    }
                ]
            }
          }
        when "image"
           message = {
          type: 'text',
          text:  "是一張圖"
        }
       when "sticker"
         message = {
          type: 'sticker',
          packageId: '1',
          stickerId:'402'
        }
        when "audio"
           message = {
          type: 'text',
          text:  "是一個音檔"
        }
        when "file"
           message = {
          type: 'text',
          text:  "是一個檔案"
        }
        when "location"
           message = {
          type: 'text',
          text:  "你好懶喔~~ 居然不打給我地址~~ \n\n\n " +message['address'] + "\n 對嗎？"
        }
        else
          message = {
          type: 'text',
          text:  "哩共蝦咪~"
        }

      end

  end

  # 傳送訊息到 line
  def reply_to_line(message)
    # 取得 reply token
    reply_token = params['events'][0]['replyToken']
    # 傳送訊息
    line.reply_message(reply_token, message)
  end




  #測試過程
  def eat
    render plain: "吃土啦~123"
  end

  def webhook_beta
    head :ok
  end

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