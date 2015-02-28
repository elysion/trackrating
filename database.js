.import QtQuick.LocalStorage 2.0 as Sql


function clearDatabase() {
    var db = getDatabase()

    db.transaction(function(tx) {
        tx.executeSql("DROP TABLE TRACKS")
        tx.executeSql("DROP TABLE RATINGS")
        tx.executeSql("DROP TABLE CATEGORIES")
    })
}

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync("Ratings", "1.0", "Track rating database", 100000)

    //create table
    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS TRACKS("
                      + "TrackId INTEGER PRIMARY KEY, "
                      + "Artist TEXT, "
                      + "Title TEXT, "
                      + "Location TEXT UNIQUE"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS RATINGS("
                      + "RatingId INTEGER PRIMARY KEY, "
                      + "TrackId INTEGER, "
                      + "Rating INTEGER, "
                      + "MoreThanId INTEGER, "
                      + "LessThanId INTEGER, "
                      + "CategoryId INTEGER, "
                      + "FOREIGN KEY(TrackId) REFERENCES TRACKS(Id) "
                      + "FOREIGN KEY(MoreThanId) REFERENCES TRACKS(Id) "
                      + "FOREIGN KEY(LessThanId) REFERENCES TRACKS(Id) "
                      + "FOREIGN KEY(CategoryId) REFERENCES CATEGORIES(Id)"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS CATEGORIES("
                      + "CategoryId INTEGER PRIMARY KEY, "
                      + "Name TEXT"
                      + ")")
    })

    return db
}

function getTracks(sort, filter, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM TRACKS ORDER BY ?", sort)
        callback(rs.rows)
    })
}

function getCategories(callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT DISTINCT(Name), CategoryId FROM CATEGORIES ORDER BY Name")
        callback(rs.rows)
    })
}

function getRatedTracksFor(categoryId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.*, RATINGS.*, TRACKS.TrackId AS TrackId FROM TRACKS LEFT OUTER JOIN RATINGS ON RATINGS.TrackId = TRACKS.TrackId WHERE RATINGS.CategoryId IS ?  AND RATINGS.MoreThanId IS NULL AND RATINGS.LessThanId IS NULL AND RATINGS.Rating IS NOT NULL", [categoryId])
        callback(rs.rows)
    })
}

function getUnratedTracksFor(categoryId, excludeTrackId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.* FROM TRACKS LEFT OUTER JOIN RATINGS ON RATINGS.TrackId = TRACKS.TrackId WHERE RATINGS.CategoryId IS NOT ? AND TRACKS.TrackId IS NOT ? AND RATINGS.Rating IS NULL", [categoryId, excludeTrackId])
        callback(rs.rows)
    })
}

function addOrReplaceTrack(artist, title, location) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("DELETE FROM TRACKS WHERE Location = ?", location)
        tx.executeSql("INSERT INTO TRACKS (Artist, Title, Location) VALUES (?,?,?)", [artist, title, location])
    })
}

function createCategory(name) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("INSERT INTO CATEGORIES (Name) VALUES (?)", [name])
    })
}

function setTrackRating(trackId, categoryId, rating) {
    var db = getDatabase()
    db.transaction(function(tx) {
        bumpRatings(categoryId, rating, function() {
            tx.executeSql("DELETE FROM RATINGS WHERE TrackId = ? AND CategoryId = ?", [trackId, categoryId])
            tx.executeSql("INSERT INTO RATINGS (TrackId, CategoryId, Rating) VALUES (?, ?, ?)", [trackId, categoryId, rating])
        })
    })
}

function rateTrack(trackId, isMoreThan, comparisonId, categoryId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE RATINGS SET " + (isMoreThan ? "MoreThanId" : "LessThanId") + "=? WHERE TrackId=? AND CategoryId=?", [comparisonId, trackId, categoryId])
    })
}

function rateTrackAbove(trackId, comparisonId, categoryId) {
    getTrackRating(comparisonId, categoryId, function(rating) {
        setTrackRating(trackId, categoryId, rating + 1)
    })
}

function rateTrackBelow(trackId, comparisonId, categoryId) {
    getTrackRating(comparisonId, categoryId, function(rating) {
        setTrackRating(trackId, categoryId, rating)
    })
}

function bumpRatings(categoryId, fromRating, callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE RATINGS SET Rating=Rating+1 WHERE CategoryId=? AND Rating>=?", [categoryId, fromRating])
        callback()
    })
}

function getTrackRating(trackId, categoryId, callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var results = tx.executeSql("SELECT Rating FROM TRACKS LEFT JOIN RATINGS ON RATINGS.TrackId = TRACKS.TrackId WHERE TRACKS.TrackId = ? AND RATINGS.CategoryId = ?", [trackId, categoryId])
        if (results.rows.length === 1) {
            callback(results.rows.item(0).Rating)
        } else {
            callback(undefined)
        }
    })
}

// TODO: remove trackId if not used?
function getNextComparisonId(trackId, comparisonId, categoryId, callback) {
    var db = getDatabase()

    db.transaction(function(tx) {
        // TODO use getTrackRating() instead
        var trackResults = tx.executeSql("SELECT * FROM TRACKS LEFT OUTER JOIN RATINGS ON TRACKS.TrackId = RATINGS.TrackId WHERE TRACKS.TrackId = ?", [trackId])

        if (trackResults.rows.length !== 1) {
            throw("Error fetching track information")
        }

        var track = trackResults.rows.item(0)

        getTrackRating(track.LessThanId, categoryId, function(lessThanRating) {
            getTrackRating(track.MoreThanId, categoryId, function(moreThanRating) {
                var lessThanStatement = lessThanRating !== undefined ? "AND RATINGS.Rating < " + lessThanRating : ""
                var moreThanStatement = moreThanRating !== undefined ? "AND RATINGS.Rating > " + moreThanRating : ""

                var tracksInBetween = tx.executeSql("SELECT TRACKS.TrackId FROM TRACKS LEFT JOIN RATINGS ON TRACKS.TrackId = RATINGS.TrackId "
                                                    + "WHERE RATINGS.CategoryId = ? "
                                                    + "AND RATINGS.LessThanId IS NULL "
                                                    + "AND RATINGS.MoreThanId IS NULL "
                                                    + "AND RATING IS NOT NULL "
                                                    + "AND TRACKS.TrackId IS NOT ?"
                                                    + lessThanStatement + " "
                                                    + moreThanStatement,
                                                    [categoryId, comparisonId])

                if (tracksInBetween.rows.length === 0) {
                    callback(null)
                } else {
                    callback(tracksInBetween.rows.item(Math.floor(tracksInBetween.rows.length/2)).TrackId)
                }
            })
        })
    })
}

function ensureRatingExists(trackId, categoryId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var trackExists = tx.executeSql("SELECT RatingId FROM RATINGS WHERE TrackId=? AND CategoryId=?", [trackId, categoryId])

        if (trackExists.rows.length === 0) {
            tx.executeSql("INSERT INTO RATINGS (TrackId, CategoryId) VALUES (?, ?)", [trackId, categoryId])
        }
    })
}

function getTrackInfo(trackId, callback) {
    var db = getDatabase()
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT TRACKS.*, RATINGS.*, TRACKS.TrackId AS TrackId FROM TRACKS LEFT OUTER JOIN RATINGS ON TRACKS.TrackId = RATINGS.TrackId WHERE TRACKS.TrackId = ?", [trackId])

        if (result.rows.length === 0) {
            throw("Track not found for id " + trackId)
        }

        callback(result.rows.item(0))
    })
}

function initiateCategoryRating(trackId, categoryId, callback) {
    getRatedTracksFor(categoryId, function(rated) {
        if (rated.length === 0) {
            getUnratedTracksFor(categoryId, trackId, function(unrated) {
                var referenceTrack = unrated.item(Math.floor(unrated.length/2))

                var db = getDatabase()
                db.transaction(function(tx) {
                    tx.executeSql("INSERT INTO RATINGS (TrackId, CategoryId, Rating) VALUES (?, ?, 1)", [referenceTrack.TrackId, categoryId])
                    callback()
                })
            })
        } else {
            callback()
        }
    })
}

function resetRating(trackId, categoryId) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("DELETE FROM RATINGS WHERE TrackId=? AND CategoryId=?", [trackId, categoryId])
    })
}
