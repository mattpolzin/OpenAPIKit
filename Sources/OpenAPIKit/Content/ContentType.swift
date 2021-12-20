//
//  ContentType.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// The Content Type of an API request or response body.
    public struct ContentType: Codable, Equatable, Hashable, RawRepresentable, HasWarnings {
        internal let underlyingType: Builtin
        public let warnings: [OpenAPI.Warning]

        public var rawValue: String {
            underlyingType.rawValue
        }

        public init?(rawValue: String) {
            if let underlying = Builtin.init(rawValue: rawValue) {
                underlyingType = underlying
                warnings = []
            } else {
                underlyingType = .other(rawValue)
                warnings = [
                    .message(
                        "'\(rawValue)' could not be parsed as a Content Type. Content Types should have the format '<type>/<subtype>'"
                    )
                ]
            }
        }

        internal init(_ builtin: Builtin) {
            underlyingType = builtin
            warnings = []
        }
    }
}

// convenience constructors
public extension OpenAPI.ContentType {
    /// Bitmap image
    static let bmp: Self = .init(.bmp)
    static let css: Self = .init(.css)
    static let csv: Self = .init(.csv)
    /// URL-encoded form data. See also: `multipartForm`.
    static let form: Self = .init(.form)
    static let html: Self = .init(.html)
    static let javascript: Self = .init(.javascript)
    /// JPEG image
    static let jpg: Self = .init(.jpg)
    static let json: Self = .init(.json)
    /// JSON:API Document
    static let jsonapi: Self = .init(.jsonapi)
    /// Quicktime video
    static let mov: Self = .init(.mov)
    /// MP3 audio
    static let mp3: Self = .init(.mp3)
    /// MP4 video
    static let mp4: Self = .init(.mp4)
    /// MPEG video
    static let mpg: Self = .init(.mpg)
    /// Multipart form data. See also: `form`.
    static let multipartForm: Self = .init(.multipartForm)
    static let pdf: Self = .init(.pdf)
    /// RAR archive
    static let rar: Self = .init(.rar)
    static let rtf: Self = .init(.rtf)
    /// Tape Archive (TAR)
    static let tar: Self = .init(.tar)
    /// TIF image
    static let tif: Self = .init(.tif)
    /// Plaintext
    static let txt: Self = .init(.txt)
    static let xml: Self = .init(.xml)
    static let yaml: Self = .init(.yaml)
    /// ZIP archive
    static let zip: Self = .init(.zip)

    static func other(_ raw: String) -> Self { .init(Builtin.other(raw)) }

    // MARK: - patterns

    static let anyApplication: Self = .init(.anyApplication)
    static let anyAudio: Self = .init(.anyAudio)
    static let anyImage: Self = .init(.anyImage)
    static let anyText: Self = .init(.anyText)
    static let anyVideo: Self = .init(.anyVideo)

    static let any: Self = .init(.any)
}

extension OpenAPI.ContentType {
    // This internal representation makes it easier to ensure that the popular
    // builtin types supported are fully covered in their rawValue implementation.
    internal enum Builtin: Codable, Equatable, Hashable {
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

extension OpenAPI.ContentType.Builtin: RawRepresentable {
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
