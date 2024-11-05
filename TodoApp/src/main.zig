const std = @import("std");
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
        .todos_arr = init_arr**5,
        .todos_count =  0,
    };
    //try todo_list.addTodo(new_todo);
    print("added new todo \n", .{});

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
        .priority = priority.high,
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
        .priority = priority.high,
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

    for (todo_list.todos_arr) |elem|
    {
        print("Current todo title {s} \n, description {s} \n, created at {d}, priority: {any}\n due date: {s} \n"
        , .{elem.title,elem.description,elem.created_at,elem.priority,elem.due_date});
    }

    
    
    

}

const priority = enum{
    high,
    medium,
    low,
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
    todos_arr: [5]Todo,
    todos_count: u8,

    const Self = @This();

    pub fn addTodo(self: *Self, todo: Todo) TodoError!void {
        // Implementation will go here
        //check whether array size has been met or exceeded
        if (self.todos_count>=self.todos_arr.len)
        {
            return TodoError.ArrayFull;
        }
        //check whether index already exists
        for (self.todos_arr) |existingtodo| {
            if (existingtodo.id == todo.id)
            {
                return TodoError.DuplicateId;
            }
        }
        //all checks passed
        self.todos_arr[self.todos_count] = todo;
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
       for (self.todos_arr,0..) |todo,i|
       {
            if (todo.id == index)
            {
                indexexists = true;
                //delete todo
                for (i..self.todos_count-1) |j|
                {
                    self.todos_arr[j] = self.todos_arr[j+1];
                }
                self.todos_count = self.todos_count-1;                
            }
       }
       if (indexexists == false)
       {
        return TodoError.TodoNotFound;
       }




    }
};

const TodoError = error{
    ArrayFull,
    InvalidIndex,
    TodoNotFound,
    DuplicateId,
    EmptyList,
};