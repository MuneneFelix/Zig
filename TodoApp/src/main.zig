const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const print = @import("std").debug.print;
pub fn main() !void{
    //print("Hello World \n", .{});
    
    var new_todo = Todo {
        .id = 0,
        .title = "First Todo",
        .completed = false,
        .priority = priority.low,
        .due_date = "2024-11-05",
        .created_at = std.time.timestamp(),
        .description = "This is the first todo",
        .tags = "first todo", 
    };
    const init_arr = [1]Todo{undefined};
    var todo_list = TodoList{
        .todos_arr = init_arr**20,
        .todos_count =  0,
    };
    //var matched_todos_arr = init_arr**5;
    try todo_list.addTodo(new_todo);
    //print("added new todo \n", .{});

    new_todo  = Todo {
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
    new_todo = Todo {
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
    new_todo = Todo {
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
    new_todo = Todo {
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
    new_todo = Todo {
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
    //delete todo here
    try todo_list.deleteTodo(1);
    print("deleted todo \n", .{});
    //add new todo---should not throw array full error
    new_todo = Todo {
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
    //try todo_list.toggleComplete(6);
    //matched_todos_arr = try todo_list.findByPriority(priority.high);
    try todo_list.sortByPriority();
    for (todo_list.todos_arr) |elem|
    {
        print("Current todo title {s} \n, description {s} \n, created at {d}, priority: {s}\n due date: {s} completed: {any} \n"
        , .{elem.title,elem.description,elem.created_at,@tagName(elem.priority),elem.due_date, elem.completed});
    }
    //save to file
    try todo_list.savetoFile("todologfile");
    //load from file and show entries
    for (todo_list.todos_arr) |elem|
    {
        try todo_list.deleteTodo(elem.id);
    }
    print("cleared todo's \n", .{});

    try todo_list.loadFromFile("todologfile");
    for (todo_list.todos_arr) |elem|
    {
        print("Current todo title {s} \n, description {s} \n, created at {d}, priority: {any}\n due date: {s} completed: {any} \n"
        , .{elem.title,elem.description,elem.created_at,elem.priority,elem.due_date, elem.completed});
    }

}
pub const priority = enum{
    low,
    medium,
    high,
    };


pub const Todo = struct{
    id: u64,
    title: [] const u8,
    completed: bool,
    priority:  priority,
    //find a method to create a data datatype
    due_date: [] const u8,
    created_at: i64,
    description:[] const u8,
    tags:[] const u8,
    
};
pub const TodoList = struct{
    todos: ?*Todo,
    capacity:usize,
    allocator: *std.mem.Allocator,
    todos_count: usize,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self
    {
        const initial_capacity = 8;
        const todos = try allocator.alloc(Todo,initial_capacity);

        return Self{
            .todos = todos,
            .capacity = initial_capacity,
            .allocator = allocator,
            .todos_count = 0,
        };
    }
    pub fn deinit(self: *Self) void{
        self.allocator.free(self.todos);
    }
    fn grow(self: *Self) !void {
        const new_capacity = self.capacity * 3 / 2; // 1.5x growth factor
        const new_todos = try self.allocator.realloc(self.todos, new_capacity);
        self.todos = new_todos;
        self.capacity = new_capacity;
    }

    fn shrink(self: *Self) !void {
        const new_capacity = self.capacity / 2;
        if (new_capacity < 8) return; // Don't shrink below initial capacity
        const new_todos = try self.allocator.realloc(self.todos, self.capacity, new_capacity);
        self.todos = new_todos;
        self.capacity = new_capacity;
    }
    pub fn addTodo(self: *Self, todo: Todo) TodoError!void {
        // Implementation will go here
        //check whether array size has been met or exceeded
        if (self.todos_count>=self.capacity)
        {
           try self.grow();
            //return TodoError.ArrayFull;
        }
        //check whether index already exists
        for (self.todos[0..self.todos_count]) |existingtodo| {
            if (existingtodo.id == todo.id)
            {
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
       if (self.todos_count == 0)
       {
        return TodoError.EmptyList;
       }
       var indexexists: bool = false;
       for (self.todos[0..self.todos_count]) |todo,i|
       {
            if (todo.id == index)
            {
                indexexists = true;
                if (self.todos_count>0) {
                //delete todo
                    for (i..self.todos_count-1) |j|
                    {
                        self.todos[j] = self.todos[j+1];
                    }
                    self.todos_count = self.todos_count-1; 
                }               
            }
       }
       if (indexexists == false)
       {
        return TodoError.TodoNotFound;
       }
       if (self.todos_count< self.capacity/4)
       {
        try self.shrink();
       }
    }
    pub fn toggleComplete(self: *Self,id:u64) TodoError!void
    {
        if (self.todos_count == 0)
       {
        return TodoError.EmptyList;
       }
       var indexexists: bool = false;
       for (self.todos_arr,0..) |todo,i|
       {
            if (todo.id == id)
            {
                indexexists = true;
                //toggle complete
                self.todos_arr[i].completed = !self.todos_arr[i].completed;
                print("todo index: {d} , todo title: {s}, todo status completed: {any} \n", .{self.todos_arr[i].id,self.todos_arr[i].title,self.todos_arr[i].completed});               
            }
       }
       if (indexexists == false)
       {
        return TodoError.TodoNotFound;
       }
    }
    pub fn findByPriority(self: *Self, priority_level: priority) TodoError![5]Todo
    {
        //find all todo's with supplied priority
        const init_todo_arr = [1] Todo{undefined};
        var matched_todos = init_todo_arr**20;
        var matchindex: u8 = 0;
        // return or print matching todos
        for (self.todos_arr) |todo|
        {
            if (todo.priority == priority_level)
            {
                matched_todos[matchindex] = todo;
                matchindex = matchindex + 1;
            }
        }
        
        //handle cases where no todos match
        if (matchindex == 0 )
        {
            return TodoError.PriorityTodonotFound;
        }
        for (matched_todos) |todo|
        {
            print("Matched todo titled: {s} , priority level: {any}, Id: {d}", .{todo.title,todo.priority,todo.id});
        }

        return matched_todos;
    }
    pub fn sortByPriority(self: *Self) TodoError!void
    {
        //choose sorting algorithm
        //implement algorithm either by inplace vs returning new array
        //check for empty array
        if (self.todos_count == 0)
        {
            return TodoError.EmptyList;
        } 
        var tempTodo: Todo = undefined ;
        var flag: bool = false;
        for (0..self.todos_arr.len) |i|
        {
            for(0..self.todos_arr.len-i-1) |j|
            {
                if (@intFromEnum(self.todos_arr[j].priority)>@intFromEnum(self.todos_arr[j+1].priority))
                {
                    tempTodo = self.todos_arr[j+1];
                    self.todos_arr[j+1] = self.todos_arr[j];
                    self.todos_arr[j] = tempTodo;
                    flag = true;
                }
            }
            if (flag==false)
            {
                break;
            }
        }
    }
    pub fn savetoFile(self: *Self, filename: []const u8) FileError!void
    {  
        const file = try fs.cwd().createFile(
            filename, .{ .read = true, .truncate = true},
        );//catch {
           // return FileError.WriteError;
       // };
        defer file.close();
        //create a buffered writer
        var writer = file.writer();

        // write each todo
        for (self.todos_arr) |todo|
        {
            try writer.print("{d}|{s}|{any}|{s}|{s}|{d}|{s}|{s}\n", .{
                todo.id,
                todo.title,
                todo.completed,
                @tagName(todo.priority),
                todo.due_date,
                todo.created_at,
                todo.description,
                todo.tags,
            }); //catch {
               // return FileWriteError.WriteError;
           // };
        }
    }
    pub fn loadFromFile(self: *Self, filename: []const u8) FileError!void
    {
        const file = try fs.cwd().openFile(
            filename, .{},
         ) ;//catch  {
        //     return FileError.ReadError;
        // };
        defer file.close();

        //create a buffered reader
        var buffered = std.io.bufferedReader(file.reader());
        var reader = buffered.reader();
        var buf: [1024]u8 = undefined;

        while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| 
        {
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
            self.todos_arr[self.todos_count] = todo;
            self.todos_count = self.todos_count + 1;
            //try self.addTodo(todo);
                        
            // ... and so on
        }


    }
};

const TodoError = error{
    ArrayFull,
    InvalidIndex,
    TodoNotFound,
    DuplicateId,
    EmptyList,
    PriorityTodonotFound,
};
const FileError = error{
    FileNotFound,
    InvalidFormat,
    WriteError,
    ReadError,
    AccessDenied,ProcessFdQuotaExceeded,
    SystemFdQuotaExceeded,
    Unexpected,
    FileTooBig,
    NoSpaceLeft,
    DeviceBusy,
    SystemResources,
    WouldBlock,
    SharingViolation,
    PathAlreadyExists,
    PipeBusy,
    NameTooLong,
    InvalidUtf8,
    InvalidWtf8,BadPathName
    ,NetworkNotFound,AntivirusInterference,
    SymLinkLoop,NoDevice,IsDir,
    NotDir,FileLocksNotSupported,FileBusy,
    DiskQuota,InputOutput,InvalidArgument,BrokenPipe,
    OperationAborted,NotOpenForWriting,LockViolation,
    ConnectionResetByPeer,
    ConnectionTimedOut,
    NotOpenForReading,
    SocketNotConnected,
    StreamTooLong,
    Overflow,
    InvalidCharacter

};