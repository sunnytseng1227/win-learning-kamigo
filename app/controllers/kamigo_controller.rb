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
    when "more_1"
      template_more_1(event)
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
  def template_more_1(event)
    message = {
      "type": "bubble",
      "header": {
        "type": "box",
        "layout": "horizontal",
        "contents": [
          {
            "type": "text",
            "text": "NEWS DIGEST",
            "weight": "bold",
            "color": "#aaaaaa",
            "size": "sm"
          }
        ]
      },
      "hero": {
        "type": "image",
        "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_4_news.png",
        "size": "full",
        "aspectRatio": "20:13",
        "aspectMode": "cover",
        "action": {
          "type": "uri",
          "uri": "http://linecorp.com/"
        }
      },
      "body": {
        "type": "box",
        "layout": "horizontal",
        "spacing": "md",
        "contents": [
          {
            "type": "box",
            "layout": "vertical",
            "flex": 1,
            "contents": [
              {
                "type": "image",
                "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/02_1_news_thumbnail_1.png",
                "aspectMode": "cover",
                "aspectRatio": "4:3",
                "size": "sm",
                "gravity": "bottom"
              },
              {
                "type": "image",
                "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/02_1_news_thumbnail_2.png",
                "aspectMode": "cover",
                "aspectRatio": "4:3",
                "margin": "md",
                "size": "sm"
              }
            ]
          },
          {
            "type": "box",
            "layout": "vertical",
            "flex": 2,
            "contents": [
              {
                "type": "text",
                "text": "7 Things to Know for Today",
                "gravity": "top",
                "size": "xs",
                "flex": 1
              },
              {
                "type": "separator"
              },
              {
                "type": "text",
                "text": "Hay fever goes wild",
                "gravity": "center",
                "size": "xs",
                "flex": 2
              },
              {
                "type": "separator"
              },
              {
                "type": "text",
                "text": "LINE Pay Begins Barcode Payment Service",
                "gravity": "center",
                "size": "xs",
                "flex": 2
              },
              {
                "type": "separator"
              },
              {
                "type": "text",
                "text": "LINE Adds LINE Wallet",
                "gravity": "bottom",
                "size": "xs",
                "flex": 1
              }
            ]
          }
        ]
      },
      "footer": {
        "type": "box",
        "layout": "horizontal",
        "contents": [
          {
            "type": "button",
            "action": {
              "type": "uri",
              "label": "More",
              "uri": "https://linecorp.com"
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
          imageAspectRatio:'square',
          imageSize:'cover',
          columns: [
            {
              title: '鏟屎',
              text: '快來幫朕鏟屎啊！',
              thumbnailImageUrl: "https://dvblobcdnjp.azureedge.net//Content/Upload/DailyArticle/Images/2017-03/2c144528-f992-4104-bb9c-3ed474aa012c_m.jpg",
              imageBackgroundColor: "#a8e8fb",
              actions: [
                { label: '想要瞭解', type: 'postback', data: 'more_1' },
                { label: '我要預約', type: 'postback', data: 'booking_1' }
              ]
            },
            {
              title: '上飯',
              text: '快把罐罐放好放滿！',
              thumbnailImageUrl: "https://i.ytimg.com/vi/UbyGmLpqG-U/maxresdefault.jpg",
              imageBackgroundColor: "#a8e8fb",
              actions: [
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