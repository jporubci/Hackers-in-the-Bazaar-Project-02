import Vapor

struct Character: Content {
    var characterName: String
    var characterGender: String
    var fightingSpecialty: String
    var armorClass: String
    var homePlanet: String
}

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", [
            "title": "Prologue: Enter Prima Noxa"
        ])
    }

    app.post("create-character") { req async throws -> View in
        let character = try req.content.decode(Character.self)
        return try await req.view.render("prologue", [
            "title": "Prologue: Enter Prima Noxa",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet
        ])
    }
}
