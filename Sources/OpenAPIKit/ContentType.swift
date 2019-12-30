//
//  ContentType.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI {
    public enum ContentType: String, Codable, Equatable, Hashable {
        /// Bitmap image
        case bmp = "image/bmp"
        case css = "text/css"
        case csv = "text/csv"
        /// URL-encoded form data. See also: `multipartForm`.
        case form = "application/x-www-form-urlencoded"
        case html = "text/html"
        case javascript = "application/javascript"
        /// JPEG image
        case jpg = "image/jpeg"
        case json = "application/json"
        /// JSON:API Document
        case jsonapi = "application/vnd.api+json"
        /// Quicktime video
        case mov = "video/quicktime"
        /// MP3 audio
        case mp3 = "audio/mpeg"
        /// MP4 video
        case mp4 = "video/mp4"
        /// MPEG video
        case mpg = "video/mpeg"
        /// Multipart form data. See also: `form`.
        case multipartForm = "multipart/form-data"
        case pdf = "application/pdf"
        /// RAR archive
        case rar = "application/x-rar-compressed"
        case rtf = "application/rtf"
        /// Tape Archive (TAR)
        case tar = "application/x-tar"
        /// TIF image
        case tif = "image/tiff"
        /// Plaintext
        case txt = "text/plain"
        case xml = "application/xml"
        case yaml = "application/x-yaml"
        /// ZIP archive
        case zip = "application/zip"
    }
}
