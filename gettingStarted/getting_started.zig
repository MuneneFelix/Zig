const std = @import("std");

pub fn main() void{
    std.debug.print("Hello Felix \n", .{});
    print_err("No Error");
}

pub fn print_err(const err: []const u8) const{
    std.debug.print("Error: {s} \n", .{err});
}