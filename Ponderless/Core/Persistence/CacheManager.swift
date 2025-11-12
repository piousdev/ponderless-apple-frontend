//
//  CacheManager.swift
//  Ponderless
//
//  Actor-based cache manager for offline-first experience
//

import Foundation

/// Thread-safe cache manager using actor isolation
actor CacheManager {
    static let shared = CacheManager()

    private let documentsDirectory: URL
    private let cacheDirectory: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var memoryCache: [String: (data: Any, expiry: Date)] = [:]

    private init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.documentsDirectory = paths[0]

        let cachePaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = cachePaths[0].appendingPathComponent("PonderlessCache")

        // Create cache directory if needed - fail silently if unable
        do {
            try FileManager.default.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Warning: Could not create cache directory: \(error.localizedDescription)")
            // App will still work, just without disk caching
        }

        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Memory Cache

    func getFromMemory<T>(key: String, type: T.Type) -> T? {
        guard let cached = memoryCache[key] else { return nil }

        // Check expiry
        if cached.expiry < Date() {
            memoryCache.removeValue(forKey: key)
            return nil
        }

        return cached.data as? T
    }

    func saveToMemory<T>(key: String, data: T, expiresIn seconds: TimeInterval = 300) {
        let expiry = Date().addingTimeInterval(seconds)
        memoryCache[key] = (data: data, expiry: expiry)
    }

    func clearMemoryCache() {
        memoryCache.removeAll()
    }

    // MARK: - Disk Cache

    func save<T: Codable>(_ object: T, key: String, isPersistent: Bool = false) async throws {
        let data = try encoder.encode(object)
        let directory = isPersistent ? documentsDirectory : cacheDirectory
        let fileURL = directory.appendingPathComponent("\(key).json")

        try data.write(to: fileURL)

        // Also save to memory cache for quick access
        saveToMemory(key: key, data: object)
    }

    func load<T: Codable>(_ type: T.Type, key: String, isPersistent: Bool = false) async throws -> T? {
        // Check memory cache first
        if let cached = getFromMemory(key: key, type: type) {
            return cached
        }

        // Load from disk
        let directory = isPersistent ? documentsDirectory : cacheDirectory
        let fileURL = directory.appendingPathComponent("\(key).json")

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let object = try decoder.decode(type, from: data)

        // Cache in memory for quick subsequent access
        saveToMemory(key: key, data: object)

        return object
    }

    func delete(key: String, isPersistent: Bool = false) async throws {
        // Remove from memory cache
        memoryCache.removeValue(forKey: key)

        // Remove from disk
        let directory = isPersistent ? documentsDirectory : cacheDirectory
        let fileURL = directory.appendingPathComponent("\(key).json")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func clearCache() async throws {
        // Clear memory cache
        clearMemoryCache()

        // Clear disk cache
        if FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.removeItem(at: cacheDirectory)
            try FileManager.default.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true
            )
        }
    }

    // MARK: - Specialized Methods

    func saveLessons(_ lessons: [Lesson]) async throws {
        try await save(lessons, key: "lessons", isPersistent: true)

        // Also save individual lessons for quick lookup
        for lesson in lessons {
            try await save(lesson, key: "lesson_\(lesson.id)", isPersistent: true)
        }
    }

    func loadLessons() async throws -> [Lesson]? {
        try await load([Lesson].self, key: "lessons", isPersistent: true)
    }

    func loadLesson(id: UUID) async throws -> Lesson? {
        try await load(Lesson.self, key: "lesson_\(id)", isPersistent: true)
    }

    func saveProgress(_ progress: UserProgress) async throws {
        try await save(progress, key: "user_progress", isPersistent: true)
    }

    func loadProgress() async throws -> UserProgress? {
        try await load(UserProgress.self, key: "user_progress", isPersistent: true)
    }

    func saveJournalEntries(_ entries: [JournalEntry]) async throws {
        try await save(entries, key: "journal_entries", isPersistent: true)
    }

    func loadJournalEntries() async throws -> [JournalEntry]? {
        try await load([JournalEntry].self, key: "journal_entries", isPersistent: true)
    }

    // MARK: - Cache Information

    func cacheSize() async -> Int64 {
        let fileManager = FileManager.default
        var size: Int64 = 0

        if let enumerator = fileManager.enumerator(at: cacheDirectory,
                                                    includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let attributes = try? fileURL.resourceValues(forKeys: [.fileSizeKey]) {
                    size += Int64(attributes.fileSize ?? 0)
                }
            }
        }

        return size
    }

    func isDataCached(key: String, isPersistent: Bool = false) -> Bool {
        let directory = isPersistent ? documentsDirectory : cacheDirectory
        let fileURL = directory.appendingPathComponent("\(key).json")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}

// MARK: - Cache Keys

enum CacheKey {
    static let lessons = "lessons"
    static let exercises = "exercises"
    static let reflections = "reflections"
    static let coaches = "coaches"
    static let userProgress = "user_progress"
    static let journalEntries = "journal_entries"
    static let chatSessions = "chat_sessions"

    static func lesson(_ id: UUID) -> String {
        "lesson_\(id)"
    }

    static func exercise(_ id: UUID) -> String {
        "exercise_\(id)"
    }

    static func chatSession(_ id: UUID) -> String {
        "chat_session_\(id)"
    }
}