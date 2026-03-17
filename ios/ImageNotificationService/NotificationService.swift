import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Try to get image URL from FCM payload
        let imageUrl = bestAttemptContent.userInfo["fcm_options"] as? [String: Any]
        let imageUrlString = (imageUrl?["image"] as? String)
            ?? (bestAttemptContent.userInfo["image"] as? String)
            ?? (bestAttemptContent.userInfo["image_url"] as? String)
            ?? (bestAttemptContent.userInfo["imageUrl"] as? String)

        guard let urlString = imageUrlString,
              let url = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        downloadImage(from: url) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadImage(
        from url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                completion(nil)
                return
            }

            let tmpDir = FileManager.default.temporaryDirectory
            let ext = self.fileExtension(for: response)
            let tmpFile = tmpDir.appendingPathComponent(UUID().uuidString + ext)

            do {
                try FileManager.default.moveItem(at: location, to: tmpFile)
                let attachment = try UNNotificationAttachment(
                    identifier: "image",
                    url: tmpFile,
                    options: nil
                )
                completion(attachment)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    private func fileExtension(for response: URLResponse?) -> String {
        let mimeType = response?.mimeType ?? ""
        switch mimeType {
        case "image/png": return ".png"
        case "image/gif": return ".gif"
        case "image/jpeg": return ".jpg"
        default: return ".jpg"
        }
    }
}
