//
//  ContentType.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI {
    public enum ContentType: Codable, Equatable, Hashable {
        /// Bitmap image
        case bmp
        case css
        case csv
        /// URL-encoded form data. See also: `multipartForm`.
        case form
        case html
        case javascript
        /// JPEG image
        case jpg
        case json
        /// JSON:API Document
        case jsonapi
        /// Quicktime video
        case mov
        /// MP3 audio
        case mp3
        /// MP4 video
        case mp4
        /// MPEG video
        case mpg
        /// Multipart form data. See also: `form`.
        case multipartForm
        case pdf
        /// RAR archive
        case rar
        case rtf
        /// Tape Archive (TAR)
        case tar
        /// TIF image
        case tif
        /// Plaintext
        case txt
        case xml
        case yaml
        /// ZIP archive
        case zip

        case other(String)

        // MARK: - patterns

        case anyApplication
        case anyAudio
        case anyImage
        case anyText
        case anyVideo

        case any
    }
}

extension OpenAPI.ContentType: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .bmp: return "image/bmp"
        case .css: return "text/css"
        case .csv: return "text/csv"
        case .form: return "application/x-www-form-urlencoded"
        case .html: return "text/html"
        case .javascript: return "application/javascript"
        case .jpg: return "image/jpeg"
        case .json: return "application/json"
        case .jsonapi: return "application/vnd.api+json"
        case .mov: return "video/quicktime"
        case .mp3: return "audio/mpeg"
        case .mp4: return "video/mp4"
        case .mpg: return "video/mpeg"
        case .multipartForm: return "multipart/form-data"
        case .pdf: return "application/pdf"
        case .rar: return "application/x-rar-compressed"
        case .rtf: return "application/rtf"
        case .tar: return "application/x-tar"
        case .tif: return "image/tiff"
        case .txt: return "text/plain"
        case .xml: return "application/xml"
        case .yaml: return "application/x-yaml"
        case .zip: return "application/zip"

        case .anyApplication: return "application/*"
        case .anyAudio: return "audio/*"
        case .anyImage: return "image/*"
        case .anyText: return "text/*"
        case .anyVideo: return "video/*"
        case .any: return "*/*"

        case .other(let contentTypeString):
            return contentTypeString
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "image/bmp": self = .bmp
        case "text/css": self = .css
        case "text/csv": self = .csv
        case "application/x-www-form-urlencoded": self = .form
        case "text/html": self = .html
        case "application/javascript": self = .javascript
        case "image/jpeg": self = .jpg
        case "application/json": self = .json
        case "application/vnd.api+json": self = .jsonapi
        case "video/quicktime": self = .mov
        case "audio/mpeg": self = .mp3
        case "video/mp4": self = .mp4
        case "video/mpeg": self = .mpg
        case "multipart/form-data": self = .multipartForm
        case "application/pdf": self = .pdf
        case "application/x-rar-compressed": self = .rar
        case "application/rtf": self = .rtf
        case "application/x-tar": self = .tar
        case "image/tiff": self = .tif
        case "text/plain": self = .txt
        case "application/xml": self = .xml
        case "application/x-yaml": self = .yaml
        case "application/zip": self = .zip

        case "application/*": self = .anyApplication
        case "audio/*": self = .anyAudio
        case "image/*": self = .anyImage
        case "text/*": self = .anyText
        case "video/*": self = .anyVideo
        case "*/*": self = .any

        default:
            let split = rawValue.split(separator: "/")
            if split.count == 2 {
                self = .other(rawValue)
            } else {
                return nil
            }
        }
    }
}

extension OpenAPI.ContentType: Validatable {}
