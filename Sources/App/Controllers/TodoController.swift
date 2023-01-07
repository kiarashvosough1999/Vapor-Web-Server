import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        let submit = todos.grouped("submit")
        let download = todos.grouped("download")
        
        submit.get { req async throws in
            try await req.view.render("index", ["title": "Hello Vapor!"])
        }
        submit.post(use: create)

        download.get { req async throws in

            try await req.view.render("download", ["title": "Hello Vapor Download!"])
        }

        download.post { req async throws in
            let path = DirectoryConfiguration.detect().publicDirectory + "MyText.txt"
            return req.fileio.streamFile(at: path)
        }

        todos.get(use: index)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Todo] {
        try await Todo.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Todo {
        let todo = try req.content.decode(Todo.self)
        try await todo.save(on: req.db)
        return todo
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: req.db)
        return .noContent
    }
}
