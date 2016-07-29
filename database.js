.import QtQuick.LocalStorage 2.0 as Sql


function clearDatabase() {
    var db = getDatabase()

    db.transaction(function(tx) {
        tx.executeSql("DROP TABLE TRACKS")
        tx.executeSql("DROP TABLE RATINGS")
        tx.executeSql("DROP TABLE CATEGORIES")
        tx.executeSql("DROP TABLE FOLDERS")
        tx.executeSql("DROP TABLE CRATES")
     })
}

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync("Ratings", "1.0", "Track rating database", 100000)

    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS CATEGORIES("
                      + "CategoryId INTEGER PRIMARY KEY, "
                      + "Name TEXT UNIQUE"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS CRATES("
                      + "CrateId INTEGER PRIMARY KEY, "
                      + "Name TEXT UNIQUE"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS FOLDERS("
                      + "FolderId INTEGER PRIMARY KEY, "
                      + "Folder TEXT UNIQUE, "
                      + "CrateId INTEGER, "
                      + "FOREIGN KEY(CrateId) REFERENCES CRATES(CrateId)"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS TRACKS("
                      + "TrackId INTEGER PRIMARY KEY, "
                      + "Artist TEXT, "
                      + "Title TEXT, "
                      + "Location TEXT, "
                      + "Filename TEXT, "
                      + "CrateId INTEGER, "
                      + "FOREIGN KEY(CrateId) REFERENCES CRATES(CrateId) "
                      + "UNIQUE (Location, CrateId) ON CONFLICT IGNORE"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS RATINGS("
                      + "RatingId INTEGER PRIMARY KEY, "
                      + "TrackId INTEGER, "
                      + "Rating INTEGER, "
                      + "MoreThanId INTEGER, "
                      + "LessThanId INTEGER, "
                      + "CategoryId INTEGER, "
                      + "CrateId INTEGER, "
                      + "FOREIGN KEY(TrackId) REFERENCES TRACKS(TrackId) "
                      + "FOREIGN KEY(MoreThanId) REFERENCES TRACKS(TrackId) "
                      + "FOREIGN KEY(LessThanId) REFERENCES TRACKS(TrackId) "
                      + "FOREIGN KEY(CategoryId) REFERENCES CATEGORIES(CategoryId)"
                      + "FOREIGN KEY(CrateId) REFERENCES CRATES(CrateId)"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS TAGS("
                      + "TagId INTEGER PRIMARY KEY, "
                      + "Name TEXT UNIQUE, "
                      + "CHECK(Name <> '')"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS TRACK_TAGS("
                      + "TrackId INTEGER, "
                      + "TagId INTEGER, "
                      + "FOREIGN KEY(TrackId) REFERENCES TRACKS(TrackId) "
                      + "FOREIGN KEY(TagId) REFERENCES TAGS(TagId) "
                      + "UNIQUE (TrackId, TagId)"
                      + ")")

        tx.executeSql("INSERT OR IGNORE INTO CRATES (Name) VALUES ('Default')")
    })

    return db
}

function toArray(arrayLike) {
    return Array.prototype.slice.call(arrayLike)
}

function decorateWithTags(track) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT Name FROM TAGS NATURAL JOIN TRACK_TAGS WHERE TrackId = ?", [track.TrackId])
        track["Tags"] = toArray(rs.rows).map(function(row) { return row.Name }).join(", ")
    })
    return track
}

function decorateTracksWithTags(tracks) {
    return tracks.map(decorateWithTags)
}

function getTracks(crateId, sort, filter, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM TRACKS WHERE CrateId = ? ORDER BY ?", [crateId, sort])
        callback(decorateTracksWithTags(toArray(rs.rows)))
    })
}

function getCategories(callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT Name, CategoryId FROM CATEGORIES ORDER BY Name")
        callback(rs.rows)
    })
}

function addTag(track, tag) {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql("INSERT INTO TRACK_TAGS (TrackId, TagId) VALUES (?, ?)", [track.TrackId, tag.TagId])
    })
}

function getTags(callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT Name, TagId FROM TAGS ORDER BY Name")
        callback(rs.rows)
    })
}

function getNextTags(callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT Name, TagId FROM TAGS WHERE TagId NOT IN (SELECT TagId from TRACK_TAGS WHERE TrackId = ?) ORDER BY Name LIMIT 9", [root.track.TrackId])
        callback(toArray(rs.rows))
    })
}

function getCrates(callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT Name, CrateId FROM CRATES ORDER BY Name")
        callback(rs.rows)
    })
}

function getRatedTracksFor(categoryId, crateId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.*, RATINGS.*, TRACKS.TrackId AS TrackId "
                                   + "FROM TRACKS "
                                     + "LEFT OUTER JOIN RATINGS ON RATINGS.TrackId = TRACKS.TrackId "
                                   + "WHERE TRACKS.CrateId IS ? "
                                     + "AND RATINGS.CrateId IS ? "
                                     + "AND RATINGS.CategoryId IS ? "
                                     + "AND RATINGS.MoreThanId IS NULL "
                                     + "AND RATINGS.LessThanId IS NULL "
                                     + "AND RATINGS.Rating IS NOT NULL "
                                   + "ORDER BY Rating DESC", [crateId, crateId, categoryId])

        callback(decorateTracksWithTags(toArray(rs.rows)))
    })
}

function getUnratedTracksFor(categoryId, crateId, excludeTrackId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.* "
                               + "FROM TRACKS "
                               + "WHERE TRACKS.TrackId IS NOT ? "
                                 + "AND TRACKS.CrateId IS ? "
                                 + "AND TRACKS.TrackId NOT IN "
                                   + "(SELECT TRACKS.TrackId "
                                     + "FROM TRACKS "
                                     + "LEFT OUTER JOIN RATINGS ON RATINGS.TrackId = TRACKS.TrackId "
                                     + "WHERE RATINGS.CategoryId IS ? "
                                       + "AND RATINGS.CrateId IS ? "
                                       + "AND RATINGS.Rating IS NOT NULL) "
                               + "ORDER BY TRACKS.Artist, TRACKS.Title", [excludeTrackId, crateId, categoryId, crateId])
        callback(decorateTracksWithTags(toArray(rs.rows)))
    })
}

function getTaggedTracksFor(tagId, crateId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.*, TAGS.*, TRACKS.TrackId AS TrackId "
                                   + "FROM TRACKS "
                                     + "JOIN TRACK_TAGS ON TRACK_TAGS.TrackId = TRACKS.TrackId "
                                     + "JOIN TAGS ON TAGS.TagId = TRACK_TAGS.TagId "
                                   + "WHERE TRACKS.CrateId IS ? "
                                     + "AND TAGS.TagId IS ? "
                                   + "ORDER BY TRACKS.Artist, TRACKS.Title", [crateId, tagId])
        callback(decorateTracksWithTags(toArray(rs.rows)))
    })
}

function getAllTracksFor(crateId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.*, TRACKS.TrackId AS TrackId "
                                   + "FROM TRACKS "
                                   + "WHERE TRACKS.CrateId IS ? "
                                   + "ORDER BY TRACKS.Artist, TRACKS.Title", [crateId])
        callback(decorateTracksWithTags(toArray(rs.rows)))
    })
}

function addTrack(artist, title, filename, location, crateId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("INSERT OR IGNORE INTO TRACKS (Artist, Title, Filename, Location, CrateId) VALUES (?,?,?,?,?)", [artist, title, filename, location, crateId])
    })
}

function addFolder(folder, crateId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("INSERT OR IGNORE INTO FOLDERS (Folder, CrateId) VALUES (?,?)", [folder, crateId])
    })
}

function createCategory(name) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("INSERT INTO CATEGORIES (Name) VALUES (?)", [name])
    })
}

function createCrate(name) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("INSERT INTO CRATES (Name) VALUES (?)", [name])
    })
}

function createTag(name) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("INSERT INTO TAGS (Name) VALUES (?)", [name])
    })
}

function setTrackRating(trackId, categoryId, crateId, rating) {
    var db = getDatabase()
    db.transaction(function(tx) {
        incrementRatings(categoryId, crateId, rating, function() {
            tx.executeSql("DELETE FROM RATINGS WHERE TrackId = ? AND CategoryId = ? AND CrateId = ?", [trackId, categoryId, crateId])
            tx.executeSql("INSERT INTO RATINGS (TrackId, CategoryId, CrateId, Rating) VALUES (?, ?, ?, ?)", [trackId, categoryId, crateId, rating])
        })
    })
}

function rateTrack(trackId, isMoreThan, comparisonId, categoryId, crateId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE RATINGS SET " + (isMoreThan ? "MoreThanId" : "LessThanId") + "=? WHERE TrackId=? AND CategoryId=? AND CrateId=?", [comparisonId, trackId, categoryId, crateId])
    })
}

function rateTrackAbove(trackId, comparisonId, categoryId, crateId) {
    getTrackRating(comparisonId, categoryId, crateId, function(ratingInfo) {
        setTrackRating(trackId, categoryId, crateId, ratingInfo.Rating + 1)
    })
}

function rateTrackBelow(trackId, comparisonId, categoryId, crateId) {
    getTrackRating(comparisonId, categoryId, crateId, function(ratingInfo) {
        setTrackRating(trackId, categoryId, crateId, ratingInfo.Rating)
    })
}

function updateRatings(categoryId, crateId, fromRating, delta, callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE RATINGS SET Rating=Rating+? WHERE CrateId=? AND CategoryId=? AND Rating>=?", [delta, crateId, categoryId, fromRating])
        if (callback) callback()
    })
}

function incrementRatings(categoryId, crateId, fromRating, callback) {
    updateRatings(categoryId, crateId, fromRating, 1, callback)
}

function decrementRatings(categoryId, crateId, fromRating, callback) {
    updateRatings(categoryId, crateId, fromRating, -1, callback)
}

function getTrackRating(trackId, categoryId, crateId, callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var results = tx.executeSql("SELECT TRACKS.*, RATINGS.* FROM TRACKS LEFT JOIN RATINGS ON RATINGS.TrackId = TRACKS.TrackId WHERE TRACKS.TrackId = ? AND RATINGS.CategoryId = ? AND RATINGS.CrateId = ? AND TRACKS.CrateId = ?", [trackId, categoryId, crateId, crateId])
        if (results.rows.length === 1) {
            callback(results.rows.item(0))
        } else {
            callback(undefined)
        }
    })
}

// TODO: remove trackId if not used?
function getNextComparisonId(trackId, comparisonId, categoryId, crateId, callback) {
    var db = getDatabase()

    db.transaction(function(tx) {
        var trackRating = getTrackRating(trackId, categoryId, crateId, function(track) {
            if (!track) {
                throw("Error fetching track rating information")
            }

            getTrackRating(track.LessThanId, categoryId, crateId, function(lessThanRating) {
                getTrackRating(track.MoreThanId, categoryId, crateId, function(moreThanRating) {
                    var lessThanStatement = lessThanRating !== undefined ? "AND RATINGS.Rating < " + lessThanRating.Rating : ""
                    var moreThanStatement = moreThanRating !== undefined ? "AND RATINGS.Rating > " + moreThanRating.Rating : ""

                    var tracksInBetween = tx.executeSql("SELECT TRACKS.TrackId FROM TRACKS LEFT JOIN RATINGS ON TRACKS.TrackId = RATINGS.TrackId "
                                                        + "WHERE RATINGS.CategoryId = ? "
                                                        + "AND RATINGS.CrateId = ?"
                                                        + "AND RATINGS.LessThanId IS NULL "
                                                        + "AND RATINGS.MoreThanId IS NULL "
                                                        + "AND RATING IS NOT NULL "
                                                        + "AND TRACKS.TrackId IS NOT ?"
                                                        + lessThanStatement + " "
                                                        + moreThanStatement,
                                                        [categoryId, crateId, comparisonId])

                    if (tracksInBetween.rows.length === 0) {
                        callback(null)
                    } else {
                        callback(tracksInBetween.rows.item(Math.floor(tracksInBetween.rows.length/2)).TrackId)
                    }
                })
            })
        })
    })
}

function ensureRatingExists(trackId, categoryId, crateId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var trackExists = tx.executeSql("SELECT RatingId FROM RATINGS WHERE TrackId=? AND CategoryId=? AND CrateId=?", [trackId, categoryId, crateId])

        if (trackExists.rows.length === 0) {
            tx.executeSql("INSERT INTO RATINGS (TrackId, CategoryId, CrateId) VALUES (?, ?, ?)", [trackId, categoryId, crateId])
        }
    })
}

function getTrackInfo(trackId, callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT TRACKS.* FROM TRACKS WHERE TRACKS.TrackId = ?", [trackId])

        if (result.rows.length === 0) {
            throw("Track not found for id " + trackId)
        }

        callback(result.rows.item(0))
    })
}

function initiateCategoryRating(trackId, categoryId, crateId, callback) {
    getRatedTracksFor(categoryId, crateId, function(rated) {
        if (rated.length === 0) {
            getUnratedTracksFor(categoryId, crateId, trackId, function(unrated) {
                var referenceTrack = unrated[Math.floor(unrated.length/2)]

                var db = getDatabase()
                db.transaction(function(tx) {
                    tx.executeSql("INSERT INTO RATINGS (TrackId, CategoryId, CrateId, Rating) VALUES (?, ?, ?, 1)", [referenceTrack.TrackId, categoryId, crateId])
                    callback()
                })
            })
        } else {
            callback()
        }
    })
}

function resetRating(trackId, categoryId, crateId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        getTrackRating(trackId, categoryId, crateId, function(track) {
            tx.executeSql("DELETE FROM RATINGS WHERE TrackId=? AND CategoryId=? AND CrateId=?", [trackId, categoryId, crateId])
            if (track && track.Rating) {
                decrementRatings(categoryId, crateId, track.Rating)
            }
        })
    })
}

function removeTrack(trackId, crateId) {
    if (trackId) {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM RATINGS WHERE TrackId=? AND CrateId=?", [trackId, crateId])
            tx.executeSql("DELETE FROM TRACK_TAGS WHERE TrackId=?", [trackId])
            tx.executeSql("DELETE FROM TRACKS WHERE TrackId=? AND CrateId=?", [trackId, crateId])
        })
    }
}

function getTrackCount(callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT COUNT(TrackId) AS Count FROM TRACKS")
        callback(result.rows.item(0).Count)
    })
}
