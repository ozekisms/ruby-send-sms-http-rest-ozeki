require 'base64'
require 'json'
require 'faraday'
require 'securerandom'
require 'date'


class Configuration
    def initialize(username, password, apiurl)
        @username = username
        @password = password
        @apiurl = apiurl
    end

    def username
        @username
    end

    def username=(username)
        @username = username
    end

    def password
        @password
    end

    def password=(password)
        @password = password
    end

    def apiurl
        @apiurl
    end

    def apiurl=(apiurl)
        @apiurl = apiurl
    end
end

class MessageApi
    def initialize(configuration)
        @_configuration = configuration
    end

    def create_authorization_header(username, password)
        username_password = username + ':' + password
        username_password_encoded = Base64.encode64(username_password)
        'Basic ' + username_password_encoded
    end

    def create_request_body(messages)
        messages_array= Array.new
        messages_hash = Hash.new
        if messages.kind_of?(Array)
            messages.each do |message|
                if message.kind_of?(Message)
                    messages_array.append(message.get_hash)
                end
            end
            messages_hash[:messages] = messages_array
            messages_hash.to_json
        elsif messages.kind_of?(Message)
            messages_array.append(messages.get_hash)
            messages_hash[:messages] = messages_array
            messages_hash.to_json
        else
            messages_hash[:messages] = messages_array
            messages_hash.to_json
        end
    end

    def create_request_body_to_manipualte(messages, folder)
        message_ids_array= Array.new
        message_ids_hash = Hash.new
        if messages.kind_of?(Array)
            messages.each do |message|
                if message.kind_of?(Message)
                    message_ids_array.append(message.id)
                end
            end
            message_ids_hash[:folder] = folder
            message_ids_hash[:message_ids] = message_ids_array
            message_ids_hash.to_json
        elsif messages.kind_of?(Message)
            message_ids_array.append(messages.id)
            message_ids_hash[:folder] = folder
            message_ids_hash[:message_ids] = message_ids_array
            message_ids_hash.to_json
        else
            message_ids_hash[:folder] = folder
            message_ids_hash[:message_ids] = message_ids_array
            message_ids_hash.to_json
        end
    end

    def get_response_delete(response, messages)
        if messages.kind_of?(Array)
            json = JSON.parse(response)
            result = MessageDeleteResult.new(json['data']['folder'])
            message_ids = json['data']['message_ids']
            messages.each do |message|
                success = false
                message_ids.each do |id|
                    if id.eql? message.id
                        success = true
                    end
                end
                if success
                    result.add_message_id_remove_succeeded(message.id)
                else
                    result.add_message_id_remove_failed(message.id)
                end
            end
        elsif messages.kind_of?(Message)
            json = JSON.parse(response)
            result = MessageDeleteResult.new(json['data']['folder'])
            message_ids = json['data']['message_ids']
            success = false
            message_ids.each do |id|
                if messages.id.eql? id
                    success = true
                end
            end
            if success
                result.add_message_id_remove_succeeded(messages.id)
            else
                result.add_message_id_remove_failed(messages.id)
            end
        else
            result = MessageDeleteResult.new('')
        end
        result
    end

    def get_response_mark(response, messages)
        if messages.kind_of?(Array)
            json = JSON.parse(response)
            result = MessageMarkResult.new(json['data']['folder'])
            message_ids = json['data']['message_ids']
            messages.each do |message|
                success = false
                message_ids.each do |id|
                    if id.eql? message.id
                        success = true
                    end
                end
                if success
                    result.add_message_id_mark_succeeded(message.id)
                else
                    result.add_message_id_mark_failed(message.id)
                end
            end
        elsif messages.kind_of?(Message)
            json = JSON.parse(response)
            result = MessageMarkResult.new(json['data']['folder'])
            message_ids = json['data']['message_ids']
            success = false
            message_ids.each do |id|
                if messages.id.eql? id
                    success = true
                end
            end
            if success
                result.add_message_id_mark_succeeded(messages.id)
            else
                result.add_message_id_mark_failed(messages.id)
            end
        else
            result = MessageMarkResult.new('')
        end
        result
    end

    def get_response_send(response)
        json_object = JSON.parse(response)
        total_count = json_object['data']['total_count']
        success_count = json_object['data']['success_count']
        failed_count = json_object['data']['failed_count']
        messages = json_object['data']['messages']
        results_array = Array.new
        messages.each do |message|
            msg = Message.new
            if message['message_id']
                msg.id = message['message_id']
            end
            if message['from_connection']
                msg.from_connection = message['from_connection']
            end
            if message['from_address']
                msg.from_address = message['from_address']
            end
            if message['from_station']
                msg.from_station = message['from_station']
            end
            if message['to_connection']
                msg.to_connection = message['to_connection']
            end
            if message['to_address']
                msg.to_address = message['to_address']
            end
            if message['to_station']
                msg.to_station = message['to_station']
            end
            if message['text']
                msg.text = message['text']
            end
            if message['create_date']
                msg.create_date = message['create_date']
            end
            if message['valid_until']
                msg.valid_until = message['valid_until']
            end
            if message['time_to_send']
                msg.time_to_send = message['time_to_send']
            end
            if message['submit_report_requested']
                if message['submit_report_requested'].eql? 'true'
                    msg.is_submit_report_requested = true
                else
                    msg.is_submit_report_requested = false
                end
            end
            if message['delivery_report_requested']
                if message['delivery_report_requested'].eql? 'true'
                    msg.is_delivery_report_requested= true
                else
                    msg.is_delivery_report_requested = false
                end
            end
            if message['view_report_requested']
                if message['view_report_requested'].eql? 'true'
                    msg.is_view_report_requested = true
                else
                    msg.is_view_report_requested = false
                end
            end
            if message['tags']
                message['tags'].each do |tag|
                    key = tag['name']
                    value = tag['value']
                    msg.add_tag(key, value)
                end
            end
            if message['status'].eql? 'SUCCESS'
                result = MessageSendResult.new(msg, DeliveryStatus.new().success, '')
                results_array.append(result)
            else
                result = MessageSendResult.new(msg, DeliveryStatus.new().failed, message['status'])
                results_array.append(result)
            end
        end
        MessageSendResults.new(total_count, success_count, failed_count, results_array)
    end

    def get_response_receive(response)
        json_object = JSON.parse(response)
        result = MessageReceiveResult.new(json_object['data']['folder'], json_object['data']['limit'])
        messages = json_object['data']['data']
        messages.each do |message|
            msg = Message.new
            if message['message_id']
                msg.id = message['message_id']
            end
            if message['from_connection']
                msg.from_connection = message['from_connection']
            end
            if message['from_address']
                msg.from_address = message['from_address']
            end
            if message['from_station']
                msg.from_station = message['from_station']
            end
            if message['to_connection']
                msg.to_connection = message['to_connection']
            end
            if message['to_address']
                msg.to_address = message['to_address']
            end
            if message['to_station']
                msg.to_station = message['to_station']
            end
            if message['text']
                msg.text = message['text']
            end
            if message['create_date']
                msg.create_date = message['create_date']
            end
            if message['valid_until']
                msg.valid_until = message['valid_until']
            end
            if message['time_to_send']
                msg.time_to_send = message['time_to_send']
            end
            if message['submit_report_requested']
                if message['submit_report_requested'].eql? 'true'
                    msg.is_submit_report_requested = true
                else
                    msg.is_submit_report_requested = false
                end
            end
            if message['delivery_report_requested']
                if message['delivery_report_requested'].eql? 'true'
                    msg.is_delivery_report_requested= true
                else
                    msg.is_delivery_report_requested = false
                end
            end
            if message['view_report_requested']
                if message['view_report_requested'].eql? 'true'
                    msg.is_view_report_requested = true
                else
                    msg.is_view_report_requested = false
                end
            end
            if message['tags']
                message['tags'].each do |tag|
                    key = tag['name']
                    value = tag['value']
                    msg.add_tag(key, value)
                end
            end
            result.append_message(msg)
        end
        self.delete(json_object['data']['folder'], result.messages)
        result
    end

    def create_uri_to_send_sms(url)
        base_url = url.split('?')[0]
        '%s?action=sendmsg' % [base_url]
    end

    def create_uri_to_delete_sms(url)
        base_url = url.split('?')[0]
        '%s?action=deletemsg' % [base_url]
    end

    def create_uri_to_mark_sms(url)
        base_url = url.split('?')[0]
        '%s?action=markmsg' % [base_url]
    end

    def create_uri_to_receive_sms(url, folder)
        base_url = url.split('?')[0]
        '%s?action=receivemsg&folder=%s' % [base_url, folder]
    end

    

    def do_request_post(url, authorization_header, request_body)
        headers = {
            'Authorization' => authorization_header,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
        }
        response = Faraday.post(url, request_body, headers)
        response.body
    end

    def do_request_get(url, authorization_header)
        headers = {
            'Authorization' => authorization_header,
            'Accept' => 'application/json'
        }
        response = Faraday.get(url, nil, headers)
        response.body
    end

    def send(messages)
        authorization_header = self.create_authorization_header(@_configuration.username, @_configuration.password)
        request_body = self.create_request_body(messages)
        response = self.do_request_post(self.create_uri_to_send_sms(@_configuration.apiurl), authorization_header, request_body)
        if self.get_response_send(response).total_count.eql? 1
            result = self.get_response_send(response).results[0]
        else
            result = self.get_response_send(response)
        end
        result
    end

    def delete(folder, messages)
        authorization_header = self.create_authorization_header(@_configuration.username, @_configuration.password)
        request_body = self.create_request_body_to_manipualte(messages, folder)
        response = self.do_request_post(self.create_uri_to_delete_sms(@_configuration.apiurl), authorization_header, request_body)
        result = self.get_response_delete(response, messages)
        if messages.kind_of?(Message)
            if result.total_count.eql? 1 and result.failed_count.eql? 0
                result = true
            else
                result = false
            end
        end
        result
    end

    def mark(folder, messages)
        authorization_header = self.create_authorization_header(@_configuration.username, @_configuration.password)
        request_body = self.create_request_body_to_manipualte(messages, folder)
        response = self.do_request_post(self.create_uri_to_mark_sms(@_configuration.apiurl), authorization_header, request_body)
        result = self.get_response_mark(response, messages)
        if messages.kind_of?(Message)
            if result.total_count.eql? 1 and result.failed_count.eql? 0
                result = true
            else
                result = false
            end
        end
        result
    end

    def download_incoming()
        authorization_header = self.create_authorization_header(@_configuration.username, @_configuration.password)
        response = self.do_request_get(self.create_uri_to_receive_sms(@_configuration.apiurl, Folder.new().inbox), authorization_header)
        result = self.get_response_receive(response)
        result
    end
end

class Message
    def initialize
        @id = SecureRandom.uuid
        @from_connection = nil
        @from_address = nil
        @from_station = nil
        @to_connection = nil
        @to_address = nil
        @to_station = nil
        @text = nil
        @create_date = DateTime.now().strftime("%Y-%m-%dT%H:%M:%S")
        @valid_until = DateTime.now().next_day(7).strftime("%Y-%m-%dT%H:%M:%S")
        @time_to_send = DateTime.now().strftime("%Y-%m-%dT%H:%M:%S")
        @is_submit_report_requested = true
        @is_delivery_report_requested = true
        @is_view_report_requested = true
        @tags = []
    end

    def id
        @id
    end

    def id=(id)
        @id = id
    end

    def from_connection
        @from_connection
    end

    def from_connection=(from_connection)
        @from_connection = from_connection
    end

    def from_address
        @from_address
    end

    def from_address=(from_address)
        @from_address = from_address
    end

    def from_station
        @from_station
    end

    def from_station=(from_station)
        @from_station = from_station
    end

    def to_connection
        @to_connection
    end

    def to_connection=(to_connection)
        @to_connection = to_connection
    end

    def to_address
        @to_address
    end

    def to_address=(to_address)
        @to_address = to_address
    end

    def to_station
        @to_station
    end

    def to_station=(to_station)
        @to_station = to_station
    end

    def text
        @text
    end

    def text=(text)
        @text = text
    end

    def create_date
        @create_date
    end

    def create_date=(create_date)
        @create_date = create_date
    end

    def valid_until
        @valid_until
    end

    def valid_until=(valid_until)
        @valid_until = valid_until
    end

    def time_to_send
        @time_to_send
    end

    def time_to_send=(time_to_send)
        if time_to_send.kind_of?(DateTime)
            @time_to_send = time_to_send.strftime("%Y-%m-%dT%H:%M:%S")
        else
            @time_to_send = DateTime.now().strftime("%Y-%m-%dT%H:%M:%S")
        end
    end

    def is_submit_report_requested
        @is_submit_report_requested
    end

    def is_submit_report_requested=(is_submit_report_requested)
        @is_submit_report_requested = is_submit_report_requested
    end

    def is_delivery_report_requested
        @is_delivery_report_requested
    end

    def is_delivery_report_requested=(is_delivery_report_requested)
        @is_delivery_report_requested = is_delivery_report_requested
    end

    def is_view_report_requested
        @is_view_report_requested
    end

    def is_view_report_requested=(is_view_report_requested)
        @is_view_report_requested = is_view_report_requested
    end

    def add_tag(key, value)
        tag = { key => value }
        @tags.append(tag)
    end

    def get_tags
        @tags
    end

    def get_hash
        object = {}
        if @id != nil
            object[:message_id] = @id
        end
        if @from_connection != nil
            object[:from_connection] = @from_connection
        end
        if @from_address != nil
            object[:from_address] = @from_address
        end
        if @from_station != nil
            object[:from_station] = @from_station
        end
        if @to_connection != nil
            object[:to_connection] = @to_connection
        end
        if @to_address != nil
            object[:to_address] = @to_address
        end
        if @to_station != nil
            object[:to_station] = @to_station
        end
        if @text != nil
            object[:text] = @text
        end
        if @create_date != nil
            object[:create_date] = @create_date
        end
        if @valid_until != nil
            object[:valid_until] = @valid_until
        end
        if @time_to_send != nil
            object[:time_to_send] = @time_to_send
        end
        if @is_submit_report_requested != nil
            object[:is_submit_report_requested] = @is_submit_report_requested
        end
        if @is_delivery_report_requested != nil
            object[:is_delivery_report_requested] = @is_delivery_report_requested
        end
        if @is_view_report_requested != nil
            object[:is_view_report_requested] = @is_view_report_requested
        end
        if @tags != {}
            object[:tags] = self.get_tags
        end
        object
    end

    def to_s
        "%s->%s '%s'" % [@from_address, @to_address, @text]
    end
end

class Folder
    def initialize
        @inbox = "inbox"
        @outbox = "outbox"
        @sent = "sent"
        @notnent = "notsent"
        @deleted = "deleted"
    end

    def inbox
        @inbox
    end

    def outbox
        @outbox
    end

    def sent
        @sent
    end

    def notnent
        @notnent
    end

    def deleted
        @deleted
    end
end

class DeliveryStatus
    def initialize
        @success = "Success"
        @failed = "Failed"
    end

    def failed
        @failed
    end

    def success
        @success
    end
end

class MessageSendResult
    def initialize(message, status, status_message)
        @message = message
        @delivery_status = status
        @status_message = status_message
    end

    def to_s
        '%s, %s' % [@delivery_status, @message.to_s]
    end
end

class MessageSendResults
    def initialize(total_count, success_count, failed_count, results)
        @total_count = total_count
        @success_count = success_count
        @failed_count = failed_count
        @results = results
    end

    def total_count
        @total_count
    end

    def success_count
        @success_count
    end
    
    def failed_count
        @failed_count
    end

    def results
        @results
    end

    def to_s
        "Total: %d. Success: %d. Failed: %d." % [@total_count, @success_count, @failed_count]
    end
end

class MessageDeleteResult
    def initialize(folder)
        @folder = folder
        @message_ids_remove_succeeded = []
        @message_ids_remove_failed = []
        @total_count = 0
        @success_count = 0
        @failed_count = 0
    end

    def add_message_id_remove_succeeded(id)
        @message_ids_remove_succeeded.append(id)
        @total_count += 1
        @success_count += 1
    end

    def add_message_id_remove_failed(id)
        @message_ids_remove_failed.append(id)
        @total_count += 1
        @failed_count += 1
    end

    def total_count
        @total_count
    end

    def success_count
        @success_count
    end

    def failed_count
        @failed_count
    end

    def to_s
        "Total: %d. Success: %d. Failed: %d." % [@total_count, @success_count, @failed_count]
    end
end

class MessageMarkResult
    def initialize(folder)
        @folder = folder
        @message_ids_mark_succeeded = []
        @message_ids_mark_failed = []
        @total_count = 0
        @success_count = 0
        @failed_count = 0
    end

    def add_message_id_mark_succeeded(id)
        @message_ids_mark_succeeded.append(id)
        @total_count += 1
        @success_count += 1
    end

    def add_message_id_mark_failed(id)
        @message_ids_mark_failed.append(id)
        @total_count += 1
        @failed_count += 1
    end

    def total_count
        @total_count
    end

    def success_count
        @success_count
    end

    def failed_count
        @failed_count
    end

    def to_s
        "Total: %d. Success: %d. Failed: %d." % [@total_count, @success_count, @failed_count]
    end
end

class MessageReceiveResult
    def initialize(folder, limit)
        @folder = folder
        @limit = limit
        @messages = Array.new
    end

    def append_message(message)
        if message.kind_of?(Message)
            @messages.append(message)
        end
    end

    def messages
        @messages
    end

    def to_s
        'Message count: %d.' % [@messages.length()]
    end
end
