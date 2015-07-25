//
// TelegramBot+sendMessage.swift
//
// Copyright (c) 2015 Andrey Fidrya
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

extension TelegramBot {
    
    /// Send text messages. On success, the sent Message is returned.
    ///
    /// This is an asynchronous version of the method,
    /// a blocking one is also available.
    ///
    /// - Parameter chatId: Unique identifier for the message recipient — User or GroupChat id.
    /// - Parameter text: Text of the message to be sent.
    /// - Parameter disableWebPagePreview: Disables link previews for links in this message.
    /// - Parameter replyToMessageId: If the message is a reply, ID of the original message.
    /// - Parameter replyMarkup: Additional interface options.
    /// - Returns: Sent message on success. Null on error, in which case `error`
    ///            contains the details.
    /// - SeeAlso: `func sendMessageWithChatId(text:disableWebPagePreview:replyToMessageId:replyMarkup:)->Message?`
    func sendMessageToChatId(chatId: Int, text: String, disableWebPagePreview: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil, completion: (message: Message?, error: DataTaskError?)->()) {
        sendMessageToChatId(chatId, text: text, disableWebPagePreview: disableWebPagePreview, replyToMessageId: replyToMessageId, replyMarkup: replyMarkup, queue: queue, completion: completion)
    }

    /// Send text messages. On success, the sent Message is returned.
    ///
    /// This is a blocking version of the method,
    /// an asynchronous one is also available.
    ///
    /// - Parameter chatId: Unique identifier for the message recipient — User or GroupChat id.
    /// - Parameter text: Text of the message to be sent.
    /// - Parameter disableWebPagePreview: Disables link previews for links in this message.
    /// - Parameter replyToMessageId: If the message is a reply, ID of the original message.
    /// - Parameter replyMarkup: Additional interface options.
    /// - Returns: Sent message on success. Null on error, in which case `error`
    ///            contains the details.
    /// - SeeAlso: `func sendMessageWithChatId(text:disableWebPagePreview:replyToMessageId:replyMarkup:completion:)->()`
    func sendMessageToChatId(chatId: Int, text: String, disableWebPagePreview: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Message? {
        var result: Message!
        let sem = dispatch_semaphore_create(0)
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        sendMessageToChatId(chatId, text: text, disableWebPagePreview: disableWebPagePreview, replyToMessageId: replyToMessageId, replyMarkup: replyMarkup, queue: queue) {
                message, error in
            result = message
            self.lastError = error
            dispatch_semaphore_signal(sem)
        }
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
        return result
    }
    
    private func sendMessageToChatId(chatId: Int, text: String, disableWebPagePreview: Bool?, replyToMessageId: Int?, replyMarkup: ReplyMarkup?, queue: dispatch_queue_t, completion: (message: Message?, error: DataTaskError?)->()) {
        let parameters: [String: Any?] = [
            "chat_id": chatId,
            "text": text,
            "disable_web_page_preview": disableWebPagePreview,
            "reply_to_message_id": replyToMessageId,
            "reply_markup": replyMarkup
        ]
        startDataTaskForEndpoint("sendMessage", parameters: parameters) {
            (result, var error) in
            var message: Message?
            if error == nil {
                message = Message(json: result)
                if message == nil {
                    error = .ResultParseError(json: result)
                }
            }
            dispatch_async(queue) {
                completion(message: message, error: error)
            }
        }
    }
}