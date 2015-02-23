.import QtQuick.LocalStorage 2.0 as Sql


function clearDatabase() {
    var db = getDatabase()

    db.transaction(function(tx) {
        tx.executeSql("DROP TABLE TRACKS")
        tx.executeSql("DROP TABLE RATINGS")
    })
}

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync("Ratings", "1.0", "Track rating database", 100000)

    //create table
    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS TRACKS("
                      + "Id INTEGER PRIMARY KEY, "
                      + "Artist TEXT, "
                      + "Title TEXT, "
                      + "Location TEXT UNIQUE"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS RATINGS("
                      + "Id INTEGER PRIMARY KEY, "
                      + "TrackId INTEGER, "
                      + "CategoryId INTEGER, "
                      + "FOREIGN KEY(TrackId) REFERENCES TRACKS(Id) "
                      + "FOREIGN KEY(CategoryId) REFERENCES CATEGORIES(Id)"
                      + ")")
        tx.executeSql("CREATE TABLE IF NOT EXISTS CATEGORIES("
                      + "Id INTEGER PRIMARY KEY, "
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
        var rs = tx.executeSql("SELECT DISTINCT(Name), Id FROM CATEGORIES ORDER BY Name")
        callback(rs.rows)
    })
}

function getRatedTracksFor(categoryId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.*,RATINGS.* FROM TRACKS LEFT OUTER JOIN RATINGS ON RATINGS.TrackId = TRACKS.Id WHERE RATINGS.CategoryId IS ?", [categoryId])
        callback(rs.rows)
    })
}

function getUnratedTracksFor(categoryId, callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT TRACKS.*,RATINGS.* FROM TRACKS LEFT OUTER JOIN RATINGS ON RATINGS.TrackId = TRACKS.Id WHERE RATINGS.CategoryId IS NOT ?", [categoryId])
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
