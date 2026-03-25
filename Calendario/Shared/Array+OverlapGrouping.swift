import EventKit

extension Array where Element == EKEvent {
    func groupedByOverlap() -> [[EKEvent]] {
        var clusters: [[EKEvent]] = []
        var sorted = self.sorted { ($0.startDate as Date?) ?? Date.distantPast < ($1.startDate as Date?) ?? Date.distantPast }
        while !sorted.isEmpty {
            var cluster = [sorted.removeFirst()]
            var clusterEnd: Date = (cluster[0].endDate as Date?) ?? (cluster[0].startDate as Date?) ?? Date.distantPast
            sorted = sorted.filter { event in
                let eventStart: Date = (event.startDate as Date?) ?? Date.distantPast
                if eventStart < clusterEnd {
                    cluster.append(event)
                    let eventEnd: Date = (event.endDate as Date?) ?? eventStart
                    clusterEnd = Swift.max(clusterEnd, eventEnd)
                    return false
                }
                return true
            }
            clusters.append(cluster)
        }
        return clusters
    }
}
