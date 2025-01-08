const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const print = @import("std").debug.print;
pub fn main() !void {
    //print("Hello World \n", .{});
    // Should be:
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var todo_list = try TodoList.init(allocator);
    defer todo_list.deinit();
    //var matched_todos = init_arr**5;
    var new_todo = Todo{ .id = 0, .title = "First Todo", .completed = false, .priority = priority.low, .due_date = "2024-11-05", .created_at = std.time.timestamp(), .description = "This is the first todo", .tags = "first todo" };

    try todo_list.addTodo(new_todo);
    print("added new todo \n", .{});

    new_todo = Todo{
        .id = 1,
        .title = "First Todo",
        .completed = false,
        .priority = priority.low,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the first todo",
        .tags = "first todo",
    };
    try todo_list.addTodo(new_todo);
    new_todo = Todo{
        .id = 2,
        .title = "Second Todo",
        .completed = false,
        .priority = priority.medium,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the second todo",
        .tags = "second todo",
    };
    try todo_list.addTodo(new_todo);
    new_todo = Todo{
        .id = 3,
        .title = "third Todo",
        .completed = false,
        .priority = priority.low,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the third todo",
        .tags = "third todo",
    };
    try todo_list.addTodo(new_todo);
    new_todo = Todo{
        .id = 4,
        .title = "fourth Todo",
        .completed = false,
        .priority = priority.high,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the fourth todo",
        .tags = "fourth todo",
    };
    try todo_list.addTodo(new_todo);
    new_todo = Todo{
        .id = 5,
        .title = "fifth Todo",
        .completed = false,
        .priority = priority.low,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the fifth todo",
        .tags = "fifth todo",
    };
    try todo_list.addTodo(new_todo);
    //print("debugging  todos len {d}", .{todo_list.todos.len});
    //delete todo here
    //try todo_list.deleteTodo(1);
    //print("deleted todo \n", .{});
    //add new todo---should not throw array full error
    new_todo = Todo{
        .id = 6,
        .title = "sixth Todo",
        .completed = false,
        .priority = priority.high,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the sixth todo",
        .tags = "sixth todo",
    };
    try todo_list.addTodo(new_todo);
    //print("debugging  todos len {d}", .{todo_list.todos.len});
    try todo_list.toggleComplete(6);
    //print("debugging todo_list: {any}", .{todo_list});
    //matched_todos = try todo_list.findByPriority(priority.high);
    //try todo_list.sortByPriority();

    for (0..todo_list.todos_count) |i| {
        print("Current todo title: {s}, description: {s}, created at: {d}, priority: {s}, due date: {s}, completed: {any}\n", .{ todo_list.todos[i].title, todo_list.todos[i].description, todo_list.todos[i].created_at, @tagName(todo_list.todos[i].priority), todo_list.todos[i].due_date, todo_list.todos[i].completed });
    }
    //save to file
    try todo_list.savetoFile("todologfile");
    //load from file and show entries
    for (0..todo_list.todos_count) |i| {
        var delcount: u8 = 0;

        // print("debugging todo struct: {any} \n \n", .{todo_list});
        print("deleting todo with id {any} \n", .{todo_list.todos[i - i].id});
        try todo_list.deleteTodo(todo_list.todos[i - i].id);

        delcount = delcount + 1;
    }
    print("cleared todo's \n", .{});
    //print("debugging todo struct after clearing todos: {any}", .{todo_list});

    try todo_list.loadFromFile("todologfile");
    for (0..todo_list.todos_count) |i| {
        print("Current todo title: {s}, description: {s}, created at: {d}, priority: {s}, due date: {s}, completed: {any}\n", .{ todo_list.todos[i].title, todo_list.todos[i].description, todo_list.todos[i].created_at, @tagName(todo_list.todos[i].priority), todo_list.todos[i].due_date, todo_list.todos[i].completed });
    }
}
pub const priority = enum {
    low,
    medium,
    high,
};

pub const Todo = struct {
    id: u64,
    title: []const u8,
    completed: bool,
    priority: priority,
    //find a method to create a data datatype
    due_date: []const u8,
    created_at: i64,
    description: []const u8,
    tags: []const u8,
};
pub const TodoList = struct {
    todos: []Todo,
    allocator: std.mem.Allocator,
    todos_count: usize,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const initial_capacity = 4;
        const todos = try allocator.alloc(Todo, initial_capacity);

        return Self{
            .todos = todos,
            .allocator = allocator,
            .todos_count = 0,
        };
    }
    pub fn deinit(self: *Self) void {
        self.allocator.free(self.todos);
    }
    pub fn grow(self: *Self) !void {
        const initial_capacity = self.todos.len;
        const new_capacity = self.todos.len * 3 / 2; // 1.5x growth factor
        const new_todos = try self.allocator.realloc(self.todos, new_capacity);
        self.todos = new_todos;
        print("size grew to: {any} from: {any} \n", .{ self.todos.len, initial_capacity });
    }

    pub fn shrink(self: *Self) !void {
        const initial_capacity = self.todos.len;
        const new_capacity = self.todos.len / 2;
        if (new_capacity < 4) return; // Don't shrink below initial capacity
        const new_todos = try self.allocator.realloc(self.todos, new_capacity);
        self.todos = new_todos;
        print("size shrank to: {any} from: {any} \n", .{ self.todos.len, initial_capacity });
    }
    pub fn addTodo(self: *Self, todo: Todo) TodoError!void {
        // Implementation will go here
        //check whether array size has been met or exceeded
        if (self.todos_count >= self.todos.len) {
            try self.grow();
            //return TodoError.ArrayFull;
        }
        //check whether index already exists
        for (self.todos) |existingtodo| {
            // print("Current todo title {s} \n, description {s} \n, created at {d}, priority: {s}\n due date: {s} completed: {any} \n", .{ existingtodo.title, existingtodo.description, existingtodo.created_at, @tagName(existingtodo.priority), existingtodo.due_date, existingtodo.completed });
            if (existingtodo.id == todo.id) {
                return TodoError.DuplicateId;
            }
        }
        //all checks passed
        self.todos[self.todos_count] = todo;
        self.todos_count = self.todos_count + 1;
    }

    pub fn deleteTodo(self: *Self, index: u64) TodoError!void {
        // Implementation will go here
        //check for empty list
        //EMPTY LIST CHECK
        if (self.todos_count == 0) {
            return TodoError.EmptyList;
        }
        //Bounds check
        if (self.todos_count > self.todos.len + 1) {
            return TodoError.OutOfBounds;
        }
        var indexexists: bool = false;
        for (self.todos, 0..) |todo, i| {
            if (todo.id == index) {
                indexexists = true;
                if (self.todos_count > 0) {
                    //delete todo
                    for (i..self.todos_count - 1) |j| {
                        self.todos[j] = self.todos[j + 1];
                    }
                    self.todos_count = self.todos_count - 1;
                }
            }
        }
        if (indexexists == false) {
            return TodoError.TodoNotFound;
        }
        if (self.todos_count < self.todos.len / 4) {
            try self.shrink();
        }
    }
    pub fn toggleComplete(self: *Self, id: u64) TodoError!void {
        if (self.todos_count == 0) {
            return TodoError.EmptyList;
        }
        var indexexists: bool = false;
        for (self.todos, 0..) |todo, i| {
            if (todo.id == id) {
                indexexists = true;
                //toggle complete
                self.todos[i].completed = !self.todos[i].completed;
                print("todo index: {d} , todo title: {s}, todo status completed: {any} \n", .{ self.todos[i].id, self.todos[i].title, self.todos[i].completed });
            }
        }
        if (indexexists == false) {
            return TodoError.TodoNotFound;
        }
    }
    pub fn findByPriority(self: *Self, priority_level: priority) TodoError![5]Todo {
        //find all todo's with supplied priority

        var matched_todos = try self.allocator.alloc(self.todos, self.todos.len);
        var matchindex: u8 = 0;
        // return or print matching todos
        for (self.todos) |todo| {
            if (todo.priority == priority_level) {
                matched_todos[matchindex] = todo;
                matchindex = matchindex + 1;
            }
        }

        //handle cases where no todos match
        if (matchindex == 0) {
            return TodoError.PriorityTodonotFound;
        }
        for (matched_todos) |todo| {
            print("Matched todo titled: {s} , priority level: {any}, Id: {d}", .{ todo.title, todo.priority, todo.id });
        }

        return matched_todos;
    }
    pub fn sortByPriority(self: *Self) TodoError!void {
        //choose sorting algorithm
        //implement algorithm either by inplace vs returning new array
        //check for empty array
        if (self.todos_count == 0) {
            return TodoError.EmptyList;
        }
        var tempTodo: Todo = undefined;
        var flag: bool = false;
        for (0..self.todos.len) |i| {
            for (0..self.todos.len - i - 1) |j| {
                if (@intFromEnum(self.todos[j].priority) > @intFromEnum(self.todos[j + 1].priority)) {
                    tempTodo = self.todos[j + 1];
                    self.todos[j + 1] = self.todos[j];
                    self.todos[j] = tempTodo;
                    flag = true;
                }
            }
            if (flag == false) {
                break;
            }
        }
    }
    pub fn savetoFile(self: *Self, filename: []const u8) FileError!void {
        const file = try fs.cwd().createFile(
            filename,
            .{ .read = true, .truncate = true },
        ); //catch {
        // return FileError.WriteError;
        // };
        defer file.close();
        //create a buffered writer
        var writer = file.writer();

        // write each todo
        for (0..self.todos_count) |i| {
            try writer.print("{d}|{s}|{any}|{s}|{s}|{d}|{s}|{s}\n", .{
                self.todos[i].id,
                self.todos[i].title,
                self.todos[i].completed,
                @tagName(self.todos[i].priority),
                self.todos[i].due_date,
                self.todos[i].created_at,
                self.todos[i].description,
                self.todos[i].tags,
            }); //catch {
            // return FileWriteError.WriteError;
            // };
        }
    }
    pub fn loadFromFile(self: *Self, filename: []const u8) LoadingErrors!void {
        const file = try fs.cwd().openFile(
            filename,
            .{},
        ); //catch  {
        //     return FileError.ReadError;
        // };
        defer file.close();

        //create a buffered reader
        var buffered = std.io.bufferedReader(file.reader());
        var reader = buffered.reader();
        var buf: [1024]u8 = undefined;

        while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            // For a line like: "1|Title|false|low|2024-01-01|12345|Description|tags"

            var iter = mem.split(u8, line, "|");
            const todo = Todo{
                .id = try std.fmt.parseInt(u64, iter.next() orelse return error.InvalidFormat, 10),
                .title = iter.next() orelse return error.InvalidFormat,
                .completed = mem.eql(u8, iter.next() orelse return error.InvalidFormat, "true"),
                .priority = std.meta.stringToEnum(priority, iter.next() orelse return error.InvalidFormat) orelse return error.InvalidFormat,
                .due_date = iter.next() orelse return error.InvalidFormat,
                .created_at = try std.fmt.parseInt(i64, iter.next() orelse return error.InvalidFormat, 10),
                .description = iter.next() orelse return error.InvalidFormat,
                .tags = iter.next() orelse return error.InvalidFormat,
            };
            //print("\n todo: {any} \n", .{todo});
            //self.todos[self.todos_count] = todo;
            //self.todos_count = self.todos_count + 1;
            try self.addTodo(todo);

            // ... and so on
        }
    }
};

const TodoError = error{ ArrayFull, InvalidIndex, TodoNotFound, DuplicateId, EmptyList, PriorityTodonotFound, OutOfMemory, OutOfBounds };
const FileError = error{ FileNotFound, InvalidFormat, WriteError, ReadError, AccessDenied, ProcessFdQuotaExceeded, SystemFdQuotaExceeded, Unexpected, FileTooBig, NoSpaceLeft, DeviceBusy, SystemResources, WouldBlock, SharingViolation, PathAlreadyExists, PipeBusy, NameTooLong, InvalidUtf8, InvalidWtf8, BadPathName, NetworkNotFound, AntivirusInterference, SymLinkLoop, NoDevice, IsDir, NotDir, FileLocksNotSupported, FileBusy, DiskQuota, InputOutput, InvalidArgument, BrokenPipe, OperationAborted, NotOpenForWriting, LockViolation, ConnectionResetByPeer, ConnectionTimedOut, NotOpenForReading, SocketNotConnected, StreamTooLong, Overflow, InvalidCharacter };
const LoadingErrors = error{ FileNotFound, InvalidFormat, WriteError, ReadError, AccessDenied, ProcessFdQuotaExceeded, SystemFdQuotaExceeded, Unexpected, FileTooBig, NoSpaceLeft, DeviceBusy, SystemResources, WouldBlock, SharingViolation, PathAlreadyExists, PipeBusy, NameTooLong, InvalidUtf8, InvalidWtf8, BadPathName, NetworkNotFound, AntivirusInterference, SymLinkLoop, NoDevice, IsDir, NotDir, FileLocksNotSupported, FileBusy, DiskQuota, InputOutput, InvalidArgument, BrokenPipe, OperationAborted, NotOpenForWriting, LockViolation, ConnectionResetByPeer, ConnectionTimedOut, NotOpenForReading, SocketNotConnected, StreamTooLong, Overflow, InvalidCharacter, ArrayFull, InvalidIndex, TodoNotFound, DuplicateId, EmptyList, PriorityTodonotFound, OutOfMemory, OutOfBounds };
