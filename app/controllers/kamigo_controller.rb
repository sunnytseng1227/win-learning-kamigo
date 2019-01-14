require 'line/bot'
class KamigoController < ApplicationController
  protect_from_forgery with: :null_session

  # Line Bot API 物件初始化
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = '4287d0f92b9461dd4f15c8448e496b0b'
      config.channel_token = '13SitYEKLmxGk/MTzMCPFWmh5q3BXeJaxYAfWS/kAp2rHKCc7MieOD1qnuzGcAyyledP+jpkU/gxv7309f5AyPLqdnvzj/AkEWkmd3kXVAXBNowxgjHKl9zNfrlibaIpAD6NgX5rRZB4+cfbd/2M+gdB04t89/1O/w1cDnyilFU='
    }
  end


  def linecallback
    body = request.body.read

        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
          error 400 do 'Bad Request' end
        end

        events = client.parse_events_from(body)

        events.each { |event|
          case event
            when Line::Bot::Event::Message
              case event.type
                when Line::Bot::Event::MessageType::Text
                  mes_Text(event)
                when Line::Bot::Event::MessageType::Image
                  mes_Image(event)
                when Line::Bot::Event::MessageType::Audio
                  mes_Audio(event)
                when Line::Bot::Event::MessageType::File
                  mes_File(event)
                when Line::Bot::Event::MessageType::Location
                  mes_Location(event)
                when Line::Bot::Event::MessageType::Sticker
                  mes_Sticker(event)
                else
                  mes_Unsupport(event)
              end
            when Line::Bot::Event::Postback
              Postback_action(event)
            end
        }
        # 回應 200
        head :ok
  end

  def  Postback_action(event)
    postback_type = event['postback']['data']
    case postback_type
    when "Call_for_service"
      template_service(event)
    end
  end

  def template_1(event)
    message =  {
       type: "template",
       altText: "您有新訊息 ~ ",
       template: {
           type: "image_carousel",
           columns: [
               {
                 imageUrl: "https://cdn2.ettoday.net/images/3826/d3826516.jpg",
                 action: {
                   type: "postback",
                   label: "點我",
                   data: "Call_for_service"
                 }
               },
               {
                 imageUrl: "https://cdn2.ettoday.net/images/3826/c3826788.jpg",
                 action: {
                   type: "message",
                   label: "Yes",
                   text: "yes"
                 }
               }
           ]
       }
     }
     client.reply_message(event['replyToken'], message)
  end

  #服務選單
  def template_service(event)
    message =  {
        type: 'template',
        altText: '您有新訊息 ~ ',
        template: {
          type: 'carousel',
          columns: [
            {
              title: '鏟屎',
              text: 'fuga',
              imageUrl: "data:image/png;base64,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",
              actions: [
                { label: 'Go to line.me', type: 'uri', uri: 'https://line.me' },
                { label: 'Send postback', type: 'postback', data: 'hello world' },
                { label: 'Send message', type: 'message', text: 'This is message' }
              ]
            },
            {
              title: '上飯',
              text: 'Please select a date, time or datetime',
              imageUrl: "data:image/jpeg;base64,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",
              actions: [
                {
                  type: 'datetimepicker',
                  label: "Datetime",
                  data: 'action=sel',
                  mode: 'datetime',
                  initial: '2017-06-18T06:15',
                  max: '2100-12-31T23:59',
                  min: '1900-01-01T00:00'
                },
                {
                  type: 'datetimepicker',
                  label: "Date",
                  data: 'action=sel&only=date',
                  mode: 'date',
                  initial: '2017-06-18',
                  max: '2100-12-31',
                  min: '1900-01-01'
                },
                {
                  type: 'datetimepicker',
                  label: "Time",
                  data: 'action=sel&only=time',
                  mode: 'time',
                  initial: '12:15',
                  max: '23:00',
                  min: '10:00'
                }
              ]
            }
          ]
        }
      }
     client.reply_message(event['replyToken'], message)
  end

  def mes_Text(event)
    message_txt = event.message["text"]
    case message_txt
      when "我要看兔仔"
        template_1(event)
      else
        message = {
           type: "text",
           text: message_txt + "~!!"
        }
        client.reply_message(event['replyToken'], message)
    end


  end

  def mes_Image(event)
    message = {
       type: 'text',
       text: event.message['id'] + '是一張圖 ~'
    }
    client.reply_message(event['replyToken'], message)
  end

  def mes_Sticker(event)
    message = {
          type: 'sticker',
          packageId: '1',
          stickerId:'402'
    }
    client.reply_message(event['replyToken'], message)
  end

  def mes_Location(event)
     message = {
       type: 'location',
       title: event.message['title'] || event.message['address'],
       address: event.message['address'],
       latitude: event.message['latitude'],
       longitude: event.message['longitude']
    }
    client.reply_message(event['replyToken'], message)
  end

  def mes_Audio(event)
    message = {
       type: 'text',
       text: event.message['id'] + '是一個影音檔 ~'
    }
    client.reply_message(event['replyToken'], message)
  end

  def mes_File(event)
    message = {
       type: 'text',
       text: event.message['id'] + '是一個檔案 ~'
    }
    client.reply_message(event['replyToken'], message)
  end

  def mes_Unsupport(event)
    message = {
          type: 'text',
          text:  "哩共蝦咪~"
        }
    client.reply_message(event['replyToken'], message)
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
           message_txt = message['text']
            case message_txt
            when "我要看兔仔"
                message =  {
                   "type": "template",
                   "altText": "this is a image carousel template",
                   "template": {
                       "type": "image_carousel",
                       "columns": [
                           {
                             "imageUrl": "https://cdn2.ettoday.net/images/3826/d3826516.jpg",
                             "action": {
                               "type": "postback",
                               "label": "Buy",
                               "data": "action=buy&itemid=111"
                             }
                           },
                           {
                             "imageUrl": "https://cdn2.ettoday.net/images/3826/c3826788.jpg",
                             "action": {
                               "type": "message",
                               "label": "Yes",
                               "text": "yes"
                             }
                           }
                       ]
                   }
                 }




            when "我有問題"
              message = {
                "type": "template",
                "altText": "您有新訊息",
                "template": {
                  "type": "buttons",
                  "imageAspectRatio": "square",
                  "imageSize": "cover",
                  "thumbnailImageUrl": "https://cdn2.ettoday.net/images/3826/c3826788.jpg",
                  "imageBackgroundColor": "#ffffff",
                  "title": "常見問題",
                  "text": "標題文字",
                  "defaultAction": {
                    "type": "message",
                    "label": "點到圖片或標題",
                    "text": "0"
                  },
                  "actions": [
                    {
                      "type": "message",
                      "label": "有什麼服務",
                      "text": "有什麼服務"
                    },
                    {
                      "type": "postback",
                      "label": "我的好友推薦序號",
                      "data": "myrecommend"
                    },
                    {
                      "type": "message",
                      "label": "推薦給朋友",
                      "text": "3"
                    }
                  ]
                }
              }

            else
                 {
                type: 'text',
                text:  message_txt + '~'
              }
            end


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
    client.reply_message(reply_token, message)
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