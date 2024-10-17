import Vapor

struct Choice: Content {
    var choice: String
    var url: String
}

struct Character: Content {
    var characterName: String
    var characterGender: String
    var fightingSpecialty: String
    var armorClass: String
    var homePlanet: String
    var weapon: String
    var money: Int?
    var chapter: Int?
    var choice: String?
    var inventory: String
}

func routes(_ app: Application) throws {

    /* Intro */
    app.get { req async throws in
        try await req.view.render("intro", [
            "title": "Prologue: Enter Prima Noxa"
        ])
    }

    /* Intro form -> First battle */
    app.post("intro-form") { req async throws -> Response in
        var character = try req.content.decode(Character.self)
        switch character.fightingSpecialty {
            case "Sheer strength":
                character.weapon = "Fission Chainsaw"
            case "Technique":
                character.weapon = "Dual RGB Blades"
            case "Agility":
                character.weapon = "Plasma Katana"
            default:
                character.weapon = ""
        }
        character.money = 0
        let base64String = (try JSONEncoder().encode(character)).base64EncodedString()
        let redirectURL = "first-battle/\(base64String)"
        return req.redirect(to: redirectURL)
    }
    app.get("first-battle", ":code") { req async throws -> View in
        guard let code = req.parameters.get("code"),
              let jsonData = Data(base64Encoded: code),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }

        return try await req.view.render("first-battle", [
            "title": "Chapter 1: Enter the Ring",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet,
            "weapon": character.weapon,
            "money": String(character.money ?? 0),
            "chapter": String(character.chapter ?? 1),
            "inventory": character.inventory
        ])
    }

    /* First battle form -> Shop */
    app.post("first-battle-form") { req async throws -> Response in
        let formData = try req.content.decode(Choice.self)
        guard let range = formData.url.range(of: "first-battle/"),
              let code = formData.url[range.upperBound...].split(separator: "/").first,
              let jsonData = Data(base64Encoded: String(code)),
              var character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }
        character.choice = formData.choice
        switch character.choice {
            case "option1":
                character.money = 499
                character.inventory = character.weapon
                character.weapon = "Legendary trident"
            default:
                character.money = 50
                character.weapon = ""
        }
        let base64String = (try JSONEncoder().encode(character)).base64EncodedString()
        let redirectURL = "shop/\(base64String)"
        return req.redirect(to: redirectURL)
    }
    app.get("shop", ":code") { req async throws -> View in
        guard let code = req.parameters.get("code"),
              let jsonData = Data(base64Encoded: code),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }

        return try await req.view.render("shop", [
            "title": "Chapter 2: Shop",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet,
            "weapon": character.weapon,
            "money": String(character.money ?? 0),
            "chapter": String(character.chapter ?? 2),
            "choice": character.choice ?? "",
            "inventory": character.inventory
        ])
    }

    /* Shop form -> Second battle */
    app.post("shop-form") { req async throws -> Response in
        let formData = try req.content.decode(Choice.self)
        guard let range = formData.url.range(of: "shop/"),
              let code = formData.url[range.upperBound...].split(separator: "/").first,
              let jsonData = Data(base64Encoded: String(code)),
              var character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }
        var redirectURL = "shop/"
        switch formData.choice {
            case "option3":
                character.choice = formData.choice
                if (character.money != nil && character.money! >= 50) {
                    character.money! -= 50
                    if (character.inventory != "") {
                        character.inventory += ", Lightning Greaves"
                    }
                    character.weapon = "Lightning Greaves"
                }
            case "option4":
                character.choice = formData.choice
                if (character.money != nil && character.money! >= 150) {
                    character.money! -= 150
                    if (character.inventory != "") {
                        character.inventory += ", Fission Chainsaw"
                    }
                    if (character.weapon == "") {
                        if (character.inventory != "") {
                            character.inventory += ", "
                        }
                        character.inventory += character.weapon
                    }
                    character.weapon = "Fission Chainsaw"
                }
            case "option5":
                character.choice = formData.choice
                if (character.money != nil && character.money! >= 150) {
                    character.money! -= 150
                    if (character.inventory != "") {
                        character.inventory += ", Plasma Katana"
                    }
                    if (character.weapon == "") {
                        if (character.inventory != "") {
                            character.inventory += ", "
                        }
                        character.inventory += character.weapon
                    }
                    character.weapon = "Plasma Katana"
                }
            case "option6":
                character.choice = formData.choice
                if (character.money != nil && character.money! >= 300) {
                    character.money! -= 300
                    if (character.inventory != "") {
                        character.inventory += ", "
                    }
                    character.inventory += "Pargonian Chestplate"
                }
            case "option7":
                character.choice = formData.choice
                if (character.money != nil && character.money! >= 500) {
                    character.money! -= 500
                    if (character.inventory != "") {
                        character.inventory += ", "
                    }
                    character.inventory += "Ganinite Helmet"
                }
            case "option8":
                character.choice = formData.choice
                var items = character.inventory.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if let index = items.firstIndex(of: "Energy Sword") {
                    items.remove(at: index)
                    character.money = (character.money ?? 0) + 100
                } else {
                    if (character.weapon == "Energy Sword") {
                        character.weapon = ""
                        character.money = (character.money ?? 0) + 100
                    }
                }
                character.inventory = items.joined(separator: ", ")
            default:
                redirectURL = "second-battle/"
        }
        let base64String = (try JSONEncoder().encode(character)).base64EncodedString()
        redirectURL += "\(base64String)"
        return req.redirect(to: redirectURL)
    }
    app.get("second-battle", ":code") { req async throws -> View in
        guard let code = req.parameters.get("code"),
              let jsonData = Data(base64Encoded: code),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }

        return try await req.view.render("second-battle", [
            "title": "Chapter 3: Challenge Battle",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet,
            "weapon": character.weapon,
            "money": String(character.money ?? 0),
            "chapter": String(character.chapter ?? 3),
            "choice": character.choice ?? "",
            "inventory": character.inventory
        ])
    }

    /* Second battle form -> Ending */
    app.post("second-battle-form") { req async throws -> Response in
        let formData = try req.content.decode(Choice.self)
        guard let range = formData.url.range(of: "second-battle/"),
              let code = formData.url[range.upperBound...].split(separator: "/").first,
              let jsonData = Data(base64Encoded: String(code)),
              var character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }
        character.choice = formData.choice
        let base64String = (try JSONEncoder().encode(character)).base64EncodedString()
        let redirectURL = "ending/\(base64String)"
        return req.redirect(to: redirectURL)
    }
    app.get("ending", ":code") { req async throws -> View in
        guard let code = req.parameters.get("code"),
              let jsonData = Data(base64Encoded: code),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }

        return try await req.view.render("ending", [
            "title": "Chapter 4: Till the Dawn Breaks",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet,
            "weapon": character.weapon,
            "money": String(character.money ?? 0),
            "chapter": String(character.chapter ?? 4),
            "choice": character.choice ?? "",
            "inventory": character.inventory
        ])
    }

    /* Ending form -> Secret */
    app.post("ending-form") { req async throws -> Response in
        let formData = try req.content.decode(Choice.self)
        guard let range = formData.url.range(of: "ending/"),
              let code = formData.url[range.upperBound...].split(separator: "/").first,
              let jsonData = Data(base64Encoded: String(code)),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }
        let base64String = (try JSONEncoder().encode(character)).base64EncodedString()
        var redirectURL = ""
        if (character.money! > 599) {
            redirectURL += "secret/\(base64String)"
        } else {
            redirectURL += "ending/\(base64String)"
        }
        return req.redirect(to: redirectURL)
    }
    app.get("secret", ":code") { req async throws -> View in
        guard let code = req.parameters.get("code"),
              let jsonData = Data(base64Encoded: code),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }

        return try await req.view.render("secret", [
            "title": "Chapter 5: Glitch in the System",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet,
            "weapon": character.weapon,
            "money": String(character.money ?? 0),
            "chapter": String(character.chapter ?? 5),
            "choice": character.choice ?? "",
            "inventory": character.inventory
        ])
    }

    /* Secret form -> Secret ending */
    app.post("secret-form") { req async throws -> Response in
        let formData = try req.content.decode(Choice.self)
        guard let range = formData.url.range(of: "secret/"),
              let code = formData.url[range.upperBound...].split(separator: "/").first,
              let jsonData = Data(base64Encoded: String(code)),
              var character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }
        character.choice = formData.choice
        let base64String = (try JSONEncoder().encode(character)).base64EncodedString()
        let redirectURL = "secret-ending/\(base64String)"
        return req.redirect(to: redirectURL)
    }
    app.get("secret-ending", ":code") { req async throws -> View in
        guard let code = req.parameters.get("code"),
              let jsonData = Data(base64Encoded: code),
              let character = try? JSONDecoder().decode(Character.self, from: jsonData) else {
            throw Abort(.badRequest)
        }

        return try await req.view.render("secret-ending", [
            "title": "Chapter 6: Face the Emperor",
            "characterName": character.characterName,
            "characterGender": character.characterGender,
            "fightingSpecialty": character.fightingSpecialty,
            "armorClass": character.armorClass,
            "homePlanet": character.homePlanet,
            "weapon": character.weapon,
            "money": String(character.money ?? 0),
            "chapter": String(character.chapter ?? 5),
            "choice": character.choice ?? "",
            "inventory": character.inventory
        ])
    }
}
